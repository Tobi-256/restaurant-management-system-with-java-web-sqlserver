package DAO;

import DB.DBContext;
import Model.Customer;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CustomerDAO {

    private static final Logger LOGGER = Logger.getLogger(CustomerDAO.class.getName());

    // Thêm khách hàng mới và trả về CustomerId
    public String createCustomer(Customer customer) throws SQLException, ClassNotFoundException {
    String customerId = "CU001"; // Giá trị mặc định
    String sqlMaxId = "SELECT MAX(CustomerId) as MaxId FROM Customer WITH (UPDLOCK, ROWLOCK)";
    String sqlInsert = "INSERT INTO Customer (CustomerId, CustomerName, CustomerPhone, NumberOfPayment, IsDeleted) VALUES (?, ?, ?, ?, ?)";

    try (Connection conn = DBContext.getConnection()) {
        conn.setAutoCommit(false);

        try (PreparedStatement stmtMaxId = conn.prepareStatement(sqlMaxId);
             ResultSet rs = stmtMaxId.executeQuery()) {
            if (rs.next() && rs.getString("MaxId") != null) {
                String maxId = rs.getString("MaxId");
                int numericPart = Integer.parseInt(maxId.substring(2)) + 1;
                customerId = "CU" + String.format("%03d", numericPart);
            }
        }

        try (PreparedStatement stmtInsert = conn.prepareStatement(sqlInsert)) {
            stmtInsert.setString(1, customerId);
            stmtInsert.setString(2, customer.getCustomerName());
            stmtInsert.setString(3, customer.getCustomerPhone());
            stmtInsert.setInt(4, customer.getNumberOfPayment());
            stmtInsert.setBoolean(5, false); // IsDeleted = 0
            stmtInsert.executeUpdate();
        }

        conn.commit();
        LOGGER.log(Level.INFO, "Created customer with ID: {0}", customerId);
        return customerId;
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error adding customer: {0}", e.getMessage());
        throw e;
    }
}

    // Giữ nguyên generateNextCustomerId nếu cần dùng riêng ở nơi khác
    public String generateNextCustomerId() throws SQLException, ClassNotFoundException {
        String nextId = "CU001";
        String sql = "SELECT MAX(CustomerId) as MaxId FROM Customer WITH (UPDLOCK, ROWLOCK)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next() && rs.getString("MaxId") != null) {
                String maxId = rs.getString("MaxId");
                int numericPart = Integer.parseInt(maxId.substring(2)) + 1;
                nextId = "CU" + String.format("%03d", numericPart);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error generating next customer ID: {0}", e.getMessage());
            throw e;
        }
        return nextId;
    }

    public List<Customer> getAllCustomers() throws SQLException, ClassNotFoundException {
    List<Customer> customers = new ArrayList<>();
    String sql = "SELECT CustomerId, CustomerName, CustomerPhone, NumberOfPayment, IsDeleted FROM Customer WHERE IsDeleted = 0";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement stmt = conn.prepareStatement(sql);
         ResultSet rs = stmt.executeQuery()) {
        while (rs.next()) {
            Customer customer = new Customer();
            customer.setCustomerId(rs.getString("CustomerId"));
            customer.setCustomerName(rs.getString("CustomerName"));
            customer.setCustomerPhone(rs.getString("CustomerPhone"));
            customer.setNumberOfPayment(rs.getInt("NumberOfPayment"));
            customer.setIsDeleted(rs.getBoolean("IsDeleted"));
            customers.add(customer);
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error retrieving all customers: {0}", e.getMessage());
        throw e;
    }
    return customers;
}

    public Customer getCustomerById(String customerId) throws SQLException, ClassNotFoundException {
    String query = "SELECT CustomerId, CustomerName, CustomerPhone, NumberOfPayment, IsDeleted FROM Customer WHERE CustomerId = ? AND IsDeleted = 0";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        ps.setString(1, customerId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return new Customer(
                        rs.getString("CustomerId"),
                        rs.getString("CustomerName"),
                        rs.getString("CustomerPhone"),
                        rs.getInt("NumberOfPayment"),
                        rs.getBoolean("IsDeleted")
                );
            }
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error retrieving customer by ID: {0}", e.getMessage());
        throw e;
    }
    return null;
}

    public boolean updateCustomer(Customer customer) throws SQLException, ClassNotFoundException {
    String query = "UPDATE Customer SET CustomerName = ?, CustomerPhone = ?, NumberOfPayment = ? WHERE CustomerId = ? AND IsDeleted = 0";
    try (Connection conn = DBContext.getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        ps.setString(1, customer.getCustomerName());
        ps.setString(2, customer.getCustomerPhone());
        ps.setInt(3, customer.getNumberOfPayment());
        ps.setString(4, customer.getCustomerId());
        return ps.executeUpdate() > 0;
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error updating customer: {0}", e.getMessage());
        throw e;
    }
}

    // Cập nhật deleteCustomer để đặt CustomerId trong Order thành NULL trước khi xóa
   public boolean deleteCustomer(String customerId) throws SQLException, ClassNotFoundException {
    try (Connection conn = DBContext.getConnection()) {
        conn.setAutoCommit(false); // Bắt đầu transaction

        // Đặt CustomerId thành NULL trong bảng Order
        String updateOrderSql = "UPDATE [Order] SET CustomerId = NULL WHERE CustomerId = ?";
        try (PreparedStatement updateStmt = conn.prepareStatement(updateOrderSql)) {
            updateStmt.setString(1, customerId);
            updateStmt.executeUpdate();
        }

        // Đánh dấu khách hàng là đã xóa
        String updateCustomerSql = "UPDATE Customer SET IsDeleted = 1 WHERE CustomerId = ?";
        try (PreparedStatement updateStmt = conn.prepareStatement(updateCustomerSql)) {
            updateStmt.setString(1, customerId);
            int rowsAffected = updateStmt.executeUpdate();
            conn.commit();
            return rowsAffected > 0;
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error deleting customer: {0}", e.getMessage());
        throw e;
    }
}

    // Cũ: incrementNumberOfPayment không kiểm tra trạng thái đơn hàng
    public void incrementNumberOfPayment(String customerId) throws SQLException, ClassNotFoundException {
        if (customerId == null || customerId.isEmpty()) {
            return;
        }
        String sql = "UPDATE Customer SET NumberOfPayment = NumberOfPayment + 1 WHERE CustomerId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, customerId);
            stmt.executeUpdate();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error incrementing number of payment: {0}", e.getMessage());
            throw e;
        }
    }

    // Mới: Tăng NumberOfPayment khi đơn hàng hoàn tất thanh toán
    public void incrementNumberOfPaymentOnOrderCompletion(String orderId) throws SQLException, ClassNotFoundException {
        String checkOrderSql = "SELECT CustomerId FROM [Order] WHERE OrderId = ? AND OrderStatus = 'Completed'";
        String updateCustomerSql = "UPDATE Customer SET NumberOfPayment = NumberOfPayment + 1 WHERE CustomerId = ?";

        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false); // Bắt đầu transaction

            String customerId = null;
            try (PreparedStatement checkStmt = conn.prepareStatement(checkOrderSql)) {
                checkStmt.setString(1, orderId);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next()) {
                        customerId = rs.getString("CustomerId");
                    }
                }
            }

            if (customerId != null && !customerId.isEmpty()) {
                try (PreparedStatement updateStmt = conn.prepareStatement(updateCustomerSql)) {
                    updateStmt.setString(1, customerId);
                    int rowsAffected = updateStmt.executeUpdate();
                    if (rowsAffected > 0) {
                        LOGGER.log(Level.INFO, "Incremented NumberOfPayment for CustomerId: {0}", customerId);
                    }
                }
            }

            conn.commit();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error incrementing NumberOfPayment: {0}", e.getMessage());
            throw e;
        }
    }

    public boolean isPhoneExists(String phone, String excludeCustomerId) throws SQLException, ClassNotFoundException {
        String sql = excludeCustomerId == null || excludeCustomerId.isEmpty()
                ? "SELECT COUNT(*) FROM Customer WHERE CustomerPhone = ?"
                : "SELECT COUNT(*) FROM Customer WHERE CustomerPhone = ? AND CustomerId != ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, phone);
            if (excludeCustomerId != null && !excludeCustomerId.isEmpty()) {
                stmt.setString(2, excludeCustomerId);
            }
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking phone existence: {0}", e.getMessage());
            throw e;
        }
        return false;
    }

    // Kiểm tra xem khách hàng có đơn hàng nào không (giữ lại nhưng không dùng trong deleteCustomer)
    public boolean hasOrders(String customerId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT COUNT(*) FROM [Order] WHERE CustomerId = ?";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        }
        return false;
    }
}