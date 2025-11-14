package DAO;

import Model.InventoryItem;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class InventoryDAO extends DB.DBContext {

    private static final Logger LOGGER = Logger.getLogger(CouponDAO.class.getName());

    public List<InventoryItem> getAllInventoryItem() {
        String sql = "SELECT * FROM Inventory WHERE isDeleted = 0";
        List<InventoryItem> inventoryItemList = new ArrayList<>();
        try (PreparedStatement st = getConnection().prepareStatement(sql)) {
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    InventoryItem inventoryItem = new InventoryItem(
                            rs.getString("ItemId"),
                            rs.getString("ItemName"),
                            rs.getString("ItemType"),
                            rs.getDouble("ItemPrice"),
                            rs.getDouble("ItemQuantity"),
                            rs.getString("ItemUnit"),
                            rs.getString("ItemDescription")
                    );
                    //    System.out.println("--- InventoryItem Item " + rowCount + " ---");
                    System.out.println("ItemId: " + inventoryItem.getItemId());
                    System.out.println("ItemName: " + inventoryItem.getItemName());
                    System.out.println("ItemType: " + inventoryItem.getItemType());
                    System.out.println("ItemPrice: " + inventoryItem.getItemPrice());
                    System.out.println("ItemQuantity: " + inventoryItem.getItemQuantity());
                    System.out.println("ItemUnit: " + inventoryItem.getItemUnit());
                    System.out.println("ItemDescription: " + inventoryItem.getItemDescription());
                    System.out.println("-----------------------");
                    inventoryItemList.add(inventoryItem);
                }
                return inventoryItemList;
            }

        } catch (Exception e) {
            System.out.println("Error when querying by ID: " + e.getMessage());
        }
        return null;
    }

    public InventoryItem getInventoryItemById(String itemId) {
        String sql = "SELECT * FROM Inventory WHERE ItemId = ?";
        try (PreparedStatement st = getConnection().prepareStatement(sql)) {
            st.setString(1, itemId);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    InventoryItem inventoryItem = new InventoryItem(
                            rs.getString("ItemId"),
                            rs.getString("ItemName"),
                            rs.getString("ItemType"),
                            rs.getDouble("ItemPrice"),
                            rs.getInt("ItemQuantity"),
                            rs.getString("ItemUnit"),
                            rs.getString("ItemDescription")
                    );
                    return inventoryItem;
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi lấy Inventory Item theo ID: " + e.getMessage());
            e.printStackTrace();
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(InventoryDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
        return null;
    }

    public String generateNextInventoryId() throws SQLException, ClassNotFoundException {
        String lastInventoryId = getLastInventoryIdFromDB();
        int nextNumber = 1; // Số bắt đầu nếu chưa có coupon nào

        if (lastInventoryId != null && !lastInventoryId.isEmpty()) {
            try {
                String numberPart = lastInventoryId.substring(2); // Loại bỏ "CP"
                nextNumber = Integer.parseInt(numberPart) + 1;
            } catch (NumberFormatException e) {
                // Xử lý lỗi nếu phần số không đúng định dạng (ví dụ: log lỗi hoặc ném exception)
                System.err.println("Lỗi định dạng CouponId cuối cùng: " + lastInventoryId);
                // Trong trường hợp lỗi định dạng, vẫn nên tạo mã mới bắt đầu từ CP001 để đảm bảo tiếp tục hoạt động
                return "000";
            }
        }

        // Định dạng số thành chuỗi 3 chữ số (ví dụ: 1 -> "001", 10 -> "010", 100 -> "100")
        String numberStr = String.format("%03d", nextNumber);
        return "IN" + numberStr; // **Sửa thành "CP" thay vì "CO"**
    }

    private String getLastInventoryIdFromDB() throws SQLException, ClassNotFoundException {
        String lastCouponId = null;
        // **Sửa câu SQL cho đúng tên bảng và cột, và dùng TOP 1 cho SQL Server**
        String sql = "SELECT TOP 1 ItemId FROM [db1].[dbo].[Inventory] ORDER BY ItemId DESC";
        Connection connection = null; // Khai báo connection để quản lý đóng kết nối trong finally
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            connection = getConnection(); // Gọi phương thức getConnection() để lấy Connection - **Cần đảm bảo getConnection() được implement đúng**
            preparedStatement = connection.prepareStatement(sql);
            resultSet = preparedStatement.executeQuery();

            if (resultSet.next()) {
                lastCouponId = resultSet.getString("ItemId"); // **Sửa thành "CouponId" cho đúng tên cột**
            }
        } catch (SQLException e) {
            e.printStackTrace(); // In lỗi hoặc xử lý lỗi kết nối database
            throw e; // Re-throw để servlet xử lý nếu cần
        } finally {
            // Đóng resources trong finally block để đảm bảo giải phóng kết nối và resources
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (preparedStatement != null) {
                try {
                    preparedStatement.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return lastCouponId;
    }

    public void addNewInventoryItem(InventoryItem inventory) { // Changed parameter type to Model.InventoryItem
        String sql = "INSERT INTO [dbo].[Inventory] (ItemId,ItemName, ItemType, ItemPrice, ItemQuantity, ItemUnit, ItemDescription) " // Updated column names to InventoryItem properties
                + "VALUES ( ?, ?, ?, ?, ?, ?,?)"; // Updated number of placeholders to match the number of columns
        try (PreparedStatement st = getConnection().prepareStatement(sql)) { // Try-with-resources để tự động đóng PreparedStatement
            st.setString(1, inventory.getItemId());
            st.setString(2, inventory.getItemName());
            st.setString(3, inventory.getItemType());
            st.setDouble(4, inventory.getItemPrice());
            st.setDouble(5, inventory.getItemQuantity());
            st.setString(6, inventory.getItemUnit());
            st.setString(7, inventory.getItemDescription());

            System.out.println("Câu truy vấn SQL đang thực thi:");
            System.out.println(sql);
            System.out.println("Tham số:");
            System.out.println("  @P1 (ItemId): " + inventory.getItemId());
            System.out.println("  @P2 (ItemName): " + inventory.getItemName());
            System.out.println("  @P3 (ItemType): " + inventory.getItemType());
            System.out.println("  @P4 (ItemPrice): " + inventory.getItemPrice());
            System.out.println("  @P5 (ItemQuantity): " + inventory.getItemQuantity());
            System.out.println("  @P6 (ItemUnit): " + inventory.getItemUnit());
            System.out.println("  @P7 (ItemDescription): " + inventory.getItemDescription());
            int rowsInserted = st.executeUpdate();
            if (rowsInserted > 0) {
                System.out.println("Thêm mới Item thành công!");
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Lỗi khi thêm mới Item: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void updateInventoryItem(InventoryItem updatedItem) {
        String sql = "UPDATE Inventory SET itemName = ?, itemType = ?, itemPrice = ?, itemQuantity = ?, itemUnit = ?, itemDescription = ? WHERE itemId = ?";
        try (PreparedStatement st = getConnection().prepareStatement(sql)) {

            st.setString(1, updatedItem.getItemName());
            st.setString(2, updatedItem.getItemType());
            st.setDouble(3, updatedItem.getItemPrice());
            st.setDouble(4, updatedItem.getItemQuantity());
            st.setString(5, updatedItem.getItemUnit());
            st.setString(6, updatedItem.getItemDescription());
            st.setString(7, updatedItem.getItemId());
            // In thông tin để kiểm tra trước khi thực hiện update
            System.out.println("--- Thông tin Inventory Item trước khi UPDATE ---");
            System.out.println("Item ID (WHERE Clause): " + updatedItem.getItemId());
            System.out.println("Item Name: " + updatedItem.getItemName());
            System.out.println("Item Type: " + updatedItem.getItemType());
            System.out.println("Item Price: " + updatedItem.getItemPrice());
            System.out.println("Item Quantity: " + updatedItem.getItemQuantity());
            System.out.println("Item Unit: " + updatedItem.getItemUnit());
            System.out.println("Item Description: " + updatedItem.getItemDescription());
            System.out.println("----------------------------------------------");

            int rowsUpdated = st.executeUpdate();
            if (rowsUpdated > 0) {
                System.out.println("Cập nhật Inventory Item ID = " + updatedItem.getItemId() + " thành công!");
            } else {
                System.out.println("Không tìm thấy Inventory Item ID = " + updatedItem.getItemId() + " để cập nhật.");
            }

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Lỗi cập nhật Inventory Item: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void deleteInventoryItemById(String itemId) throws ClassNotFoundException {
        try {
            // Modified to update IsDeleted instead of deleting
            String sql = "UPDATE [Inventory] SET IsDeleted = 1 WHERE itemId=?";
            PreparedStatement pst = getConnection().prepareStatement(sql);
            pst.setString(1, itemId);
            pst.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
//
//    public String isInventoryItemExist(String itemName) {
//        String sql = "SELECT ItemID FROM Inventory WHERE LOWER(ItemName) = LOWER(?) AND isDeleted=0";
//        try (PreparedStatement st = getConnection().prepareStatement(sql)) {
//            st.setString(1, itemName);
//            try (ResultSet rs = st.executeQuery()) {
//                if (rs.next()) {
//                    // Nếu tìm thấy item, trả về ItemID
//                    System.out.println("NGUYEN THANH PHAT");
//                    return rs.getString("ItemID");
//
//                } else {
//
//                    return "None";
//                }
//            }
//        } catch (SQLException e) {
//            System.err.println("Lỗi kiểm tra Inventory Item theo tên: " + e.getMessage());
//            e.printStackTrace();
//        } catch (ClassNotFoundException ex) {
//            Logger.getLogger(InventoryDAO.class.getName()).log(Level.SEVERE, null, ex);
//        }
//        return "None";
//    }

    public boolean isInventoryItemExistForAdd(String itemName) {
        String sql = "SELECT 1 FROM Inventory WHERE LOWER(ItemName) = LOWER(?) AND isDeleted=0"; // Chỉ cần SELECT 1 để kiểm tra sự tồn tại
        try (PreparedStatement st = getConnection().prepareStatement(sql)) {
            st.setString(1, itemName);
            try (ResultSet rs = st.executeQuery()) {
                if (rs.next()) {
                    // Nếu tìm thấy item, trả về true
                    System.out.println("NGUYEN THANH PHAT"); // Có thể bỏ dòng này vì không cần thiết cho logic true/false
                    return true;
                } else {
                    return false;
                }
            }
        } catch (SQLException e) {
            System.err.println("Lỗi kiểm tra Inventory Item theo tên: " + e.getMessage());
            e.printStackTrace();
            return false; // Trả về false khi có lỗi SQL
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(InventoryDAO.class.getName()).log(Level.SEVERE, null, ex);
            return false; // Trả về false khi có lỗi ClassNotFoundException
        }
    }

    public boolean isInventoryItemExists(String itemId, String excludeItemId) throws SQLException, ClassNotFoundException {
        String sql = excludeItemId == null || excludeItemId.isEmpty()
                ? "SELECT COUNT(*) FROM Inventory WHERE ItemId = ? AND isDeleted = 0"
                : "SELECT COUNT(*) FROM Inventory WHERE ItemId = ? AND ItemId != ? AND isDeleted = 0";
        try (Connection conn = getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, itemId);
            if (excludeItemId != null && !excludeItemId.isEmpty()) {
                stmt.setString(2, excludeItemId);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking InventoryItem existence: {0}", e.getMessage());
            throw e;
        }
        return false;
    }

    public boolean isInventoryItemExistForUpdate(String itemName, String itemId) {
        String sql = "SELECT 1 FROM Inventory WHERE LOWER(ItemName) = LOWER(?) AND isDeleted=0";
        if (itemId != null && !itemId.isEmpty()) {
            sql += " AND ItemId != ?"; // Loại trừ bản ghi đang cập nhật
        }
        try (PreparedStatement st = getConnection().prepareStatement(sql)) {
            st.setString(1, itemName);
            if (itemId != null && !itemId.isEmpty()) {
                st.setString(2, itemId); // Set tham số itemId
            }
            try (ResultSet rs = st.executeQuery()) {
                return rs.next(); // Trả về true nếu tìm thấy item khác có tên trùng
            }
        } catch (SQLException e) {
            System.err.println("Lỗi kiểm tra Inventory Item (UPDATE) theo tên: " + e.getMessage());
            e.printStackTrace();
            return false;
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(InventoryDAO.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }

}
