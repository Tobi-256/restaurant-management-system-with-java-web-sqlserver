package DAO;

import DB.DBContext;
import Model.Table;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class TableDAO {

    private String sql;

    public TableDAO() {
        // Không khởi tạo Connection ở đây nữa
    }

    public ResultSet getAllTable() throws SQLException, ClassNotFoundException {
        ResultSet rs = null;
        try (Connection conn = DBContext.getConnection();
             Statement st = conn.createStatement()) {
            sql = "SELECT * FROM [Table] WHERE IsDeleted = 0";
            rs = st.executeQuery(sql);
            // Không đóng ResultSet ở đây vì nó sẽ được sử dụng bên ngoài
            return rs;
        } catch (SQLException ex) {
            Logger.getLogger(TableDAO.class.getName()).log(Level.SEVERE, "Error fetching all tables", ex);
            throw ex;
        }
    }

    public List<Table> getAllTables() throws SQLException, ClassNotFoundException {
        List<Table> tables = new ArrayList<>();
        String sql = "SELECT TableId, TableStatus, NumberOfSeats, FloorNumber FROM [Table] WHERE IsDeleted = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Table table = new Table();
                table.setTableId(rs.getString("TableId"));
                table.setTableStatus(rs.getString("TableStatus"));
                table.setNumberOfSeats(rs.getInt("NumberOfSeats"));
                table.setFloorNumber(rs.getInt("FloorNumber"));
                tables.add(table);
            }
            Logger.getLogger(TableDAO.class.getName()).log(Level.INFO, "Found {0} tables", tables.size());
        } catch (SQLException ex) {
            Logger.getLogger(TableDAO.class.getName()).log(Level.SEVERE, "Error fetching all tables", ex);
            throw ex;
        }
        return tables;
    }

    public List<Table> getAvailableTables() throws SQLException, ClassNotFoundException {
        List<Table> tables = new ArrayList<>();
        String sql = "SELECT TableId, TableStatus, NumberOfSeats, FloorNumber FROM [Table] WHERE TableStatus = 'Available' AND IsDeleted = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {
            while (rs.next()) {
                Table table = new Table();
                table.setTableId(rs.getString("TableId"));
                table.setTableStatus(rs.getString("TableStatus"));
                table.setNumberOfSeats(rs.getInt("NumberOfSeats"));
                table.setFloorNumber(rs.getInt("FloorNumber"));
                tables.add(table);
            }
            Logger.getLogger(TableDAO.class.getName()).log(Level.INFO, "Found {0} available tables", tables.size());
        } catch (SQLException ex) {
            Logger.getLogger(TableDAO.class.getName()).log(Level.SEVERE, "Error fetching available tables", ex);
            throw ex;
        }
        return tables;
    }

    public void updateTableStatus(String tableId, String status) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE [Table] SET TableStatus = ? WHERE TableId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, status);
            pstmt.setString(2, tableId);
            pstmt.executeUpdate();
            Logger.getLogger(TableDAO.class.getName()).log(Level.INFO, "Updated table {0} status to {1}", new Object[]{tableId, status});
        } catch (SQLException ex) {
            Logger.getLogger(TableDAO.class.getName()).log(Level.SEVERE, "Error updating table status", ex);
            throw ex;
        }
    }

    private String getNextTableId(int floorNumber) throws SQLException, ClassNotFoundException {
        String maxId = null;
        String nextId = null;
        try (Connection conn = DBContext.getConnection();
             PreparedStatement getMaxId = conn.prepareStatement("SELECT MAX(TableId) AS MaxId FROM [Table] WHERE FloorNumber = ?")) {
            getMaxId.setInt(1, floorNumber);
            try (ResultSet rs = getMaxId.executeQuery()) {
                if (rs.next()) {
                    maxId = rs.getString("MaxId");
                }
            }

            String prefix = "TA" + floorNumber;
            if (maxId == null) {
                nextId = prefix + "01";
            } else {
                String numericPart = maxId.substring(prefix.length());
                int nextNumber = Integer.parseInt(numericPart) + 1;
                nextId = prefix + String.format("%02d", nextNumber);
            }
        } catch (SQLException ex) {
            Logger.getLogger(TableDAO.class.getName()).log(Level.SEVERE, "Error generating next table ID", ex);
            throw ex;
        }
        return nextId;
    }

    public int createTable(Table newInfo) throws SQLException, ClassNotFoundException {
        int count = 0;
        try (Connection conn = DBContext.getConnection()) {
            int floorNumber = newInfo.getFloorNumber();
            String newTableId = getNextTableId(floorNumber);

            sql = "INSERT INTO [Table] (TableId, TableStatus, NumberOfSeats, FloorNumber) VALUES (?, ?, ?, ?)";
            try (PreparedStatement pst = conn.prepareStatement(sql)) {
                pst.setString(1, newTableId);
                pst.setString(2, newInfo.getTableStatus());
                pst.setInt(3, newInfo.getNumberOfSeats());
                pst.setInt(4, newInfo.getFloorNumber());
                count = pst.executeUpdate();
            }
        } catch (SQLException ex) {
            Logger.getLogger(TableDAO.class.getName()).log(Level.SEVERE, "Error creating table", ex);
            throw ex;
        }
        return count;
    }

    public int updateTable(String id, Table newInfo) throws SQLException, ClassNotFoundException {
        int count = 0;
        String newTableId = id;

        try (Connection conn = DBContext.getConnection()) {
            Table existingTable = getTableById(id);
            if (existingTable == null) {
                return 0;
            }
            int oldFloorNumber = existingTable.getFloorNumber();
            int newFloorNumber = newInfo.getFloorNumber();

            if (oldFloorNumber != newFloorNumber) {
                String potentialNewTableId = getNextTableId(newFloorNumber);
                if (isTableIdExists(potentialNewTableId)) {
                    int suffixNumber = Integer.parseInt(potentialNewTableId.substring(potentialNewTableId.length() - 2));
                    while (isTableIdExists("TA" + newFloorNumber + String.format("%02d", suffixNumber))) {
                        suffixNumber++;
                        if (suffixNumber > 99) {
                            throw new SQLException("Không thể tạo ID bàn mới, hết số thứ tự trên tầng " + newFloorNumber);
                        }
                    }
                    newTableId = "TA" + newFloorNumber + String.format("%02d", suffixNumber);
                } else {
                    newTableId = potentialNewTableId;
                }
            }

            sql = "UPDATE [Table] SET TableId=?, TableStatus=?, NumberOfSeats=?, FloorNumber=? WHERE TableId=?";
            try (PreparedStatement pst = conn.prepareStatement(sql)) {
                pst.setString(1, newTableId);
                pst.setString(2, newInfo.getTableStatus());
                pst.setInt(3, newInfo.getNumberOfSeats());
                pst.setInt(4, newInfo.getFloorNumber());
                pst.setString(5, id);
                count = pst.executeUpdate();
            }
        } catch (SQLException ex) {
            Logger.getLogger(TableDAO.class.getName()).log(Level.SEVERE, "Error updating table", ex);
            throw ex;
        }
        return count;
    }

    private boolean isTableIdExists(String tableId) throws SQLException, ClassNotFoundException {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement checkPst = conn.prepareStatement("SELECT 1 FROM [Table] WHERE TableId = ?")) {
            checkPst.setString(1, tableId);
            try (ResultSet rs = checkPst.executeQuery()) {
                return rs.next();
            }
        }
    }

    public Table getTableById(String tableId) throws SQLException, ClassNotFoundException {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement getPst = conn.prepareStatement("SELECT TableId, TableStatus, NumberOfSeats, FloorNumber FROM [Table] WHERE TableId = ?")) {
            getPst.setString(1, tableId);
            try (ResultSet rs = getPst.executeQuery()) {
                if (rs.next()) {
                    Table table = new Table();
                    table.setTableId(rs.getString("TableId"));
                    table.setTableStatus(rs.getString("TableStatus"));
                    table.setNumberOfSeats(rs.getInt("NumberOfSeats"));
                    table.setFloorNumber(rs.getInt("FloorNumber"));
                    return table;
                }
            }
        }
        return null;
    }

    public List<Integer> getFloorNumbers() throws SQLException, ClassNotFoundException {
        List<Integer> floorNumbers = new ArrayList<>();
        try (Connection conn = DBContext.getConnection();
             PreparedStatement pst = conn.prepareStatement("SELECT DISTINCT FloorNumber FROM [Table] WHERE IsDeleted = 0 ORDER BY FloorNumber ASC");
             ResultSet rs = pst.executeQuery()) {
            while (rs.next()) {
                floorNumbers.add(rs.getInt("FloorNumber"));
            }
        } catch (SQLException ex) {
            Logger.getLogger(TableDAO.class.getName()).log(Level.SEVERE, "Error fetching floor numbers", ex);
            throw ex;
        }
        return floorNumbers;
    }

    public int deleteTable(String id) throws SQLException, ClassNotFoundException {
        int count = 0;
        try (Connection conn = DBContext.getConnection();
             PreparedStatement pst = conn.prepareStatement("UPDATE [Table] SET IsDeleted = 1 WHERE TableId=?")) {
            pst.setString(1, id);
            count = pst.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(TableDAO.class.getName()).log(Level.SEVERE, "Error deleting table", ex);
            throw ex;
        }
        return count;
    }

    public boolean hasOrder(String tableId) throws SQLException, ClassNotFoundException {
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT COUNT(*) FROM [Order] WHERE TableId = ? AND OrderStatus = 'Pending'")) {
            stmt.setString(1, tableId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
}