package DAO;

import DB.DBContext;
import Model.Order;
import Model.OrderDetail;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class OrderDAO {

    private static final Logger logger = Logger.getLogger(OrderDAO.class.getName());

    public String getOrderIdByTableId(String tableId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT OrderId FROM [Order] WHERE TableId = ? AND OrderStatus = 'Pending'";
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, tableId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getString("OrderId");
                }
            }
        }
        return null;
    }

    public Order getOrderByTableId(String tableId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM [Order] WHERE TableId = ? AND OrderStatus IN ('Pending', 'Processing')";
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, tableId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getString("OrderId"));
                    order.setUserId(rs.getString("UserId"));
                    order.setTableId(rs.getString("TableId"));
                    order.setCustomerId(rs.getString("CustomerId"));
                    order.setOrderStatus(rs.getString("OrderStatus"));
                    order.setOrderType(rs.getString("OrderType"));
                    order.setOrderDate(rs.getTimestamp("OrderDate"));
                    order.setTotal(rs.getDouble("Total"));
                    order.setFinalPrice(rs.getDouble("FinalPrice"));
                    order.setCustomerPhone(rs.getString("CustomerPhone"));
                    order.setOrderDetails(getOrderDetailsByOrderId(order.getOrderId()));
                    return order;
                }
            }
        }
        return null;
    }

    public List<OrderDetail> getOrderDetailsByOrderId(String orderId) throws SQLException, ClassNotFoundException {
        List<OrderDetail> details = new ArrayList<>();
        String sql = "SELECT OrderDetailId, DishList FROM OrderDetail WHERE OrderId = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    String orderDetailId = rs.getString("OrderDetailId");
                    String dishListJson = rs.getString("DishList");
                    ObjectMapper mapper = new ObjectMapper();
                    List<OrderDetail> dishList = mapper.readValue(dishListJson, new TypeReference<List<OrderDetail>>() {});
                    for (OrderDetail detail : dishList) {
                        detail.setOrderDetailId(orderDetailId);
                        detail.setOrderId(orderId);
                        details.add(detail);
                    }
                }
            }
        } catch (Exception e) {
            logger.log(Level.SEVERE, "Error parsing DishList: " + e.getMessage(), e);
            throw new SQLException("Error parsing DishList", e);
        }
        return details;
    }

    public Order getOrderById(String orderId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT * FROM [Order] WHERE OrderId = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, orderId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getString("OrderId"));
                    order.setUserId(rs.getString("UserId"));
                    order.setTableId(rs.getString("TableId"));
                    order.setCustomerId(rs.getString("CustomerId"));
                    order.setOrderStatus(rs.getString("OrderStatus"));
                    order.setOrderType(rs.getString("OrderType"));
                    order.setOrderDate(rs.getTimestamp("OrderDate"));
                    order.setTotal(rs.getDouble("Total"));
                    order.setFinalPrice(rs.getDouble("FinalPrice"));
                    order.setCustomerPhone(rs.getString("CustomerPhone"));
                    order.setOrderDescription(rs.getString("OrderDescription"));
                    order.setCouponId(rs.getString("CouponId"));
                    order.setOrderDetails(getOrderDetailsByOrderId(orderId));
                    return order;
                }
            }
        }
        return null;
    }

    public List<Order> getPendingOrders() throws SQLException, ClassNotFoundException {
        List<Order> orders = new ArrayList<>();
        String sql = "SELECT * FROM [Order] WHERE OrderStatus IN ('Pending', 'Processing') ORDER BY OrderDate ASC";
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getString("OrderId"));
                    order.setOrderDate(rs.getTimestamp("OrderDate"));
                    order.setOrderStatus(rs.getString("OrderStatus"));
                    order.setTableId(rs.getString("TableId"));
                    order.setOrderDescription(rs.getString("OrderDescription"));
                    order.setTotal(rs.getDouble("Total"));
                    order.setFinalPrice(rs.getDouble("FinalPrice"));
                    order.setOrderDetails(getOrderDetailsByOrderId(rs.getString("OrderId")));
                    orders.add(order);
                }
            }
        }
        return orders;
    }

    public String generateUniqueOrderDetailId(Connection conn) throws SQLException {
        String nextId = "OD001";
        String sql = "SELECT MAX(OrderDetailId) as MaxId FROM OrderDetail WITH (UPDLOCK, ROWLOCK)";
        try (PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            if (rs.next() && rs.getString("MaxId") != null) {
                String maxId = rs.getString("MaxId");
                int numericPart = Integer.parseInt(maxId.substring(2)) + 1;
                nextId = "OD" + String.format("%03d", numericPart);
            }
        }
        return nextId;
    }

    public void createOrder(Order order) throws SQLException, ClassNotFoundException {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            String sqlOrder = "INSERT INTO [Order] (OrderId, UserId, CustomerId, OrderDate, OrderStatus, OrderType, TableId, Total, FinalPrice, CustomerPhone, OrderDescription) "
                    + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            try (PreparedStatement pstmtOrder = conn.prepareStatement(sqlOrder)) {
                pstmtOrder.setString(1, order.getOrderId());
                pstmtOrder.setString(2, order.getUserId());
                pstmtOrder.setString(3, order.getCustomerId());
                pstmtOrder.setTimestamp(4, new Timestamp(order.getOrderDate().getTime()));
                pstmtOrder.setString(5, order.getOrderStatus());
                pstmtOrder.setString(6, order.getOrderType());
                pstmtOrder.setString(7, order.getTableId());
                pstmtOrder.setDouble(8, order.getTotal());
                pstmtOrder.setDouble(9, order.getFinalPrice());
                pstmtOrder.setString(10, order.getCustomerPhone());
                pstmtOrder.setString(11, order.getOrderDescription());
                pstmtOrder.executeUpdate();
            }

            if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) {
                String orderDetailId = generateUniqueOrderDetailId(conn);
                ObjectMapper mapper = new ObjectMapper();
                String dishListJson = mapper.writeValueAsString(order.getOrderDetails());
                double total = order.getOrderDetails().stream().mapToDouble(OrderDetail::getSubtotal).sum();

                String sqlOrderDetail = "INSERT INTO OrderDetail (OrderDetailId, OrderId, DishList, Total) "
                        + "VALUES (?, ?, ?, ?)";
                try (PreparedStatement pstmtOrderDetail = conn.prepareStatement(sqlOrderDetail)) {
                    pstmtOrderDetail.setString(1, orderDetailId);
                    pstmtOrderDetail.setString(2, order.getOrderId());
                    pstmtOrderDetail.setString(3, dishListJson);
                    pstmtOrderDetail.setDouble(4, total);
                    pstmtOrderDetail.executeUpdate();
                }
                logger.info("Added OrderDetail: " + orderDetailId + " with DishList: " + dishListJson);
            }

            conn.commit();
            logger.log(Level.INFO, "Successfully created Order: {0}", order.getOrderId());
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    logger.log(Level.SEVERE, "Rollback failed: " + rollbackEx.getMessage(), rollbackEx);
                }
            }
            logger.log(Level.SEVERE, "Error creating Order: " + e.getMessage(), e);
            throw new SQLException("Error creating Order", e);
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
    }

    public void updateOrder(Order order) throws SQLException, ClassNotFoundException {
        String sql = "UPDATE [Order] SET UserId = ?, TableId = ?, CustomerId = ?, OrderStatus = ?, OrderType = ?, OrderDate = ?, Total = ?, FinalPrice = ?, CustomerPhone = ?, OrderDescription = ?, CouponId = ? WHERE OrderId = ?";
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, order.getUserId());
            stmt.setString(2, order.getTableId());
            stmt.setString(3, order.getCustomerId());
            stmt.setString(4, order.getOrderStatus());
            stmt.setString(5, order.getOrderType());
            stmt.setTimestamp(6, new java.sql.Timestamp(order.getOrderDate().getTime()));
            stmt.setDouble(7, order.getTotal());
            stmt.setDouble(8, order.getFinalPrice());
            stmt.setString(9, order.getCustomerPhone());
            stmt.setString(10, order.getOrderDescription());
            stmt.setString(11, order.getCouponId());
            stmt.setString(12, order.getOrderId());
            stmt.executeUpdate();
            logger.log(Level.INFO, "Updated order with OrderId: {0}", order.getOrderId());
        }
    }

    public List<Order> getOrdersByStatus(String status) throws SQLException, ClassNotFoundException {
        List<Order> orders = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement("SELECT * FROM [Order] WHERE OrderStatus = ?")) {
            stmt.setString(1, status);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getString("OrderId"));
                    order.setUserId(rs.getString("UserId"));
                    order.setCustomerId(rs.getString("CustomerId"));
                    order.setOrderDate(rs.getTimestamp("OrderDate"));
                    order.setOrderStatus(rs.getString("OrderStatus"));
                    order.setOrderType(rs.getString("OrderType"));
                    order.setTableId(rs.getString("TableId"));
                    order.setCustomerPhone(rs.getString("CustomerPhone"));
                    order.setTotal(rs.getDouble("Total"));
                    order.setFinalPrice(rs.getDouble("FinalPrice"));
                    order.setOrderDescription(rs.getString("OrderDescription"));
                    order.setOrderDetails(getOrderDetailsByOrderId(rs.getString("OrderId")));
                    orders.add(order);
                }
            }
        }
        return orders;
    }

    public List<Order> getAllOrders() throws SQLException, ClassNotFoundException {
        List<Order> orderList = new ArrayList<>();
        try (Connection conn = DBContext.getConnection(); PreparedStatement pstmt = conn.prepareStatement("SELECT * FROM [Order]")) {
            try (ResultSet rs = pstmt.executeQuery()) {
                while (rs.next()) {
                    Order order = new Order();
                    order.setOrderId(rs.getString("OrderId"));
                    order.setUserId(rs.getString("UserId"));
                    order.setCustomerId(rs.getString("CustomerId"));
                    order.setOrderDate(rs.getTimestamp("OrderDate"));
                    order.setOrderStatus(rs.getString("OrderStatus"));
                    order.setOrderType(rs.getString("OrderType"));
                    order.setTableId(rs.getString("TableId"));
                    order.setCustomerPhone(rs.getString("CustomerPhone"));
                    order.setTotal(rs.getDouble("Total"));
                    order.setFinalPrice(rs.getDouble("FinalPrice"));
                    order.setOrderDescription(rs.getString("OrderDescription"));
                    orderList.add(order);
                }
            }
        }
        return orderList;
    }

    public void addOrderDetail(OrderDetail detail) throws SQLException, ClassNotFoundException {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);

            if (detail.getOrderDetailId() == null || detail.getOrderDetailId().isEmpty()) {
                detail.setOrderDetailId(generateUniqueOrderDetailId(conn));
            }

            String sql = "INSERT INTO OrderDetail (OrderDetailId, OrderId, DishId, Quantity, Subtotal, DishName) "
                    + "VALUES (?, ?, ?, ?, ?, ?)";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, detail.getOrderDetailId());
                stmt.setString(2, detail.getOrderId());
                stmt.setString(3, detail.getDishId());
                stmt.setInt(4, detail.getQuantity());
                stmt.setDouble(5, detail.getSubtotal());
                stmt.setString(6, detail.getDishName());
                stmt.executeUpdate();
            }

            updateOrderTotal(detail.getOrderId(), conn);
            conn.commit();
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error adding OrderDetail: {0}", e.getMessage());
            throw e;
        }
    }

    public String generateNextOrderId() throws SQLException, ClassNotFoundException {
        String nextId = "OR001";
        String sql = "SELECT MAX(OrderId) as MaxId FROM [Order] WITH (UPDLOCK, ROWLOCK)";
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(sql); ResultSet rs = stmt.executeQuery()) {
            if (rs.next() && rs.getString("MaxId") != null) {
                String maxId = rs.getString("MaxId");
                int numericPart = Integer.parseInt(maxId.substring(2)) + 1;
                nextId = "OR" + String.format("%03d", numericPart);
            }
        }
        return nextId;
    }

    private void updateOrderTotal(String orderId, Connection conn) throws SQLException {
        String sql = "UPDATE [Order] SET Total = (SELECT SUM(Total) FROM OrderDetail WHERE OrderId = ?) WHERE OrderId = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, orderId);
            stmt.setString(2, orderId);
            stmt.executeUpdate();
        }
    }

    public void updateOrderStatus(String orderId, String newStatus) throws SQLException, ClassNotFoundException {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            Order order = getOrderById(orderId);
            if (order == null) {
                throw new SQLException("Order not found: " + orderId);
            }
            if ("Pending".equals(order.getOrderStatus()) && !"Processing".equals(newStatus) ||
                "Processing".equals(order.getOrderStatus()) && !"Completed".equals(newStatus)) {
                throw new SQLException("Invalid status transition from " + order.getOrderStatus() + " to " + newStatus);
            }

            if ("Processing".equals(newStatus)) {
                List<OrderDetail> details = order.getOrderDetails();
                for (OrderDetail detail : details) {
                    String dishId = detail.getDishId();
                    int quantityOrdered = detail.getQuantity();

                    String sqlIngredients = "SELECT di.ItemId, di.QuantityUsed, i.ItemQuantity " +
                                           "FROM Dish_Inventory di " +
                                           "JOIN Inventory i ON di.ItemId = i.ItemId " +
                                           "WHERE di.DishId = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sqlIngredients)) {
                        stmt.setString(1, dishId);
                        try (ResultSet rs = stmt.executeQuery()) {
                            while (rs.next()) {
                                String itemId = rs.getString("ItemId");
                                double quantityUsedPerDish = rs.getDouble("QuantityUsed");
                                int currentQuantity = rs.getInt("ItemQuantity");

                                double totalQuantityNeeded = quantityUsedPerDish * quantityOrdered;
                                if (currentQuantity < totalQuantityNeeded) {
                                    throw new SQLException("Out of stock: Ingredient " + itemId + " is insufficient for dish " + dishId + ". Needed: " + totalQuantityNeeded + ", Available: " + currentQuantity);
                                }
                            }
                        }
                    }
                }

                for (OrderDetail detail : details) {
                    String dishId = detail.getDishId();
                    int quantityOrdered = detail.getQuantity();

                    String sqlIngredients = "SELECT di.ItemId, di.QuantityUsed " +
                                           "FROM Dish_Inventory di " +
                                           "WHERE di.DishId = ?";
                    try (PreparedStatement stmt = conn.prepareStatement(sqlIngredients)) {
                        stmt.setString(1, dishId);
                        try (ResultSet rs = stmt.executeQuery()) {
                            while (rs.next()) {
                                String itemId = rs.getString("ItemId");
                                double quantityUsedPerDish = rs.getDouble("QuantityUsed");

                                double totalQuantityNeeded = quantityUsedPerDish * quantityOrdered;
                                String sqlUpdateInventory = "UPDATE Inventory SET ItemQuantity = ItemQuantity - ? WHERE ItemId = ?";
                                try (PreparedStatement updateStmt = conn.prepareStatement(sqlUpdateInventory)) {
                                    updateStmt.setDouble(1, totalQuantityNeeded);
                                    updateStmt.setString(2, itemId);
                                    updateStmt.executeUpdate();
                                }
                            }
                        }
                    }
                }
            }

            String sql = "UPDATE [Order] SET OrderStatus = ? WHERE OrderId = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, newStatus);
                stmt.setString(2, orderId);
                stmt.executeUpdate();
            }

            conn.commit();
            logger.log(Level.INFO, "Updated OrderStatus for OrderId: {0} to {1}", new Object[]{orderId, newStatus});
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    logger.log(Level.SEVERE, "Rollback failed: " + rollbackEx.getMessage(), rollbackEx);
                }
            }
            logger.log(Level.SEVERE, "Error updating order status: " + e.getMessage(), e);
            throw e;
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
    }

    public void cancelOrder(String orderId) throws SQLException, ClassNotFoundException {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            String checkSql = "SELECT OrderStatus FROM [Order] WHERE OrderId = ?";
            String status;
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, orderId);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (rs.next()) {
                        status = rs.getString("OrderStatus");
                    } else {
                        throw new SQLException("Order not found: " + orderId);
                    }
                }
            }

            if (!"Pending".equals(status)) {
                throw new SQLException("Cannot cancel order: Status is " + status);
            }

            String deleteDetailsSql = "DELETE FROM OrderDetail WHERE OrderId = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deleteDetailsSql)) {
                stmt.setString(1, orderId);
                stmt.executeUpdate();
            }

            String deleteOrderSql = "DELETE FROM [Order] WHERE OrderId = ?";
            try (PreparedStatement stmt = conn.prepareStatement(deleteOrderSql)) {
                stmt.setString(1, orderId);
                stmt.executeUpdate();
            }

            conn.commit();
            logger.log(Level.INFO, "Cancelled order with OrderId: {0}", orderId);
        } catch (SQLException e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException rollbackEx) {
                    logger.log(Level.SEVERE, "Rollback failed: " + rollbackEx.getMessage(), rollbackEx);
                }
            }
            logger.log(Level.SEVERE, "Error cancelling order: " + e.getMessage(), e);
            throw e;
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
    }

    public void completeOrder(String tableId) throws SQLException, ClassNotFoundException {
        String orderId = getOrderIdByTableId(tableId);
        if (orderId != null) {
            updateOrderStatus(orderId, "Completed");
        } else {
            throw new SQLException("No pending order found for table: " + tableId);
        }
    }

    public void updateOrderCustomer(String orderId, String customerId) throws SQLException, ClassNotFoundException {
        try (Connection conn = DBContext.getConnection(); PreparedStatement stmt = conn.prepareStatement(
                "UPDATE [Order] SET CustomerId = ? WHERE OrderId = ?")) {
            stmt.setString(1, customerId);
            stmt.setString(2, orderId);
            stmt.executeUpdate();
        }
    }

    public void deleteOrderDetail(String orderDetailId) throws SQLException, ClassNotFoundException {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String orderIdSql = "SELECT OrderId FROM OrderDetail WHERE OrderDetailId = ?";
                String orderId;
                try (PreparedStatement stmt = conn.prepareStatement(orderIdSql)) {
                    stmt.setString(1, orderDetailId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        orderId = rs.next() ? rs.getString("OrderId") : null;
                    }
                }

                String sql = "DELETE FROM OrderDetail WHERE OrderDetailId = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, orderDetailId);
                    stmt.executeUpdate();
                }

                if (orderId != null) {
                    updateOrderTotal(orderId, conn);
                }
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    public void updateOrderDetailQuantity(String orderDetailId, int newQuantity) throws SQLException, ClassNotFoundException {
        try (Connection conn = DBContext.getConnection()) {
            conn.setAutoCommit(false);
            try {
                String sql = "SELECT OrderId, DishId FROM OrderDetail WHERE OrderDetailId = ?";
                String orderId;
                String dishId;
                try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                    stmt.setString(1, orderDetailId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        if (rs.next()) {
                            orderId = rs.getString("OrderId");
                            dishId = rs.getString("DishId");
                        } else {
                            throw new SQLException("OrderDetail not found");
                        }
                    }
                }

                double dishPrice = getDishPrice(dishId, conn);
                double newSubtotal = dishPrice * newQuantity;

                String updateSql = "UPDATE OrderDetail SET Quantity = ?, Subtotal = ? WHERE OrderDetailId = ?";
                try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                    stmt.setInt(1, newQuantity);
                    stmt.setDouble(2, newSubtotal);
                    stmt.setString(3, orderDetailId);
                    stmt.executeUpdate();
                }

                updateOrderTotal(orderId, conn);
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                throw e;
            }
        }
    }

    private double getDishPrice(String dishId, Connection conn) throws SQLException {
        String sql = "SELECT DishPrice FROM Dish WHERE DishId = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, dishId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getDouble("DishPrice");
                } else {
                    throw new SQLException("Dish not found: " + dishId);
                }
            }
        }
    }

    public void checkInventoryForOrder(List<OrderDetail> details) throws SQLException, ClassNotFoundException {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            
            if (details == null || details.isEmpty()) {
                throw new SQLException("No dishes in the order.");
            }

            for (OrderDetail detail : details) {
                String dishId = detail.getDishId();
                int quantityOrdered = detail.getQuantity();

                String sqlIngredients = "SELECT di.ItemId, di.QuantityUsed, i.ItemQuantity " +
                                       "FROM Dish_Inventory di " +
                                       "JOIN Inventory i ON di.ItemId = i.ItemId " +
                                       "WHERE di.DishId = ?";
                try (PreparedStatement stmt = conn.prepareStatement(sqlIngredients)) {
                    stmt.setString(1, dishId);
                    try (ResultSet rs = stmt.executeQuery()) {
                        while (rs.next()) {
                            String itemId = rs.getString("ItemId");
                            double quantityUsedPerDish = rs.getDouble("QuantityUsed");
                            int currentQuantity = rs.getInt("ItemQuantity");

                            double totalQuantityNeeded = quantityUsedPerDish * quantityOrdered;
                            if (currentQuantity < totalQuantityNeeded) {
                                throw new SQLException("Out of stock: Ingredient " + itemId + " is insufficient for dish " + dishId + ". Needed: " + totalQuantityNeeded + ", Available: " + currentQuantity);
                            }
                        }
                    }
                }
            }
        } catch (SQLException e) {
            logger.log(Level.SEVERE, "Error checking inventory: " + e.getMessage(), e);
            throw e;
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
    }
}