package DAO;

import Model.Order;
import Model.OrderDetail;
import Model.Coupon;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PaymentDAO {
    private Connection getConnection() throws SQLException {
        return DriverManager.getConnection("jdbc:sqlserver://localhost:1433;databaseName=restaurant", "sa", "password");
    }

    // Lấy thông tin hóa đơn để in, bao gồm Order, OrderDetails và Coupon
    public Order getOrderForPrint(String orderId) {
        Order order = null;
        String orderQuery = "SELECT o.*, c.DiscountAmount FROM [Order] o " +
                           "LEFT JOIN Coupon c ON o.CouponId = c.CouponId " +
                           "WHERE o.OrderId = ?";
        String detailQuery = "SELECT * FROM OrderDetail WHERE OrderId = ?";

        try (Connection conn = getConnection();
             PreparedStatement orderPs = conn.prepareStatement(orderQuery);
             PreparedStatement detailPs = conn.prepareStatement(detailQuery)) {

            // Lấy thông tin Order và Coupon
            orderPs.setString(1, orderId);
            ResultSet orderRs = orderPs.executeQuery();
            if (orderRs.next()) {
                order = new Order();
                order.setOrderId(orderRs.getString("OrderId"));
                order.setUserId(orderRs.getString("UserId"));
                order.setCustomerId(orderRs.getString("CustomerId"));
                order.setOrderDate(orderRs.getTimestamp("OrderDate"));
                order.setOrderStatus(orderRs.getString("OrderStatus"));
                order.setOrderType(orderRs.getString("OrderType"));
                order.setOrderDescription(orderRs.getString("OrderDescription"));
                order.setCouponId(orderRs.getString("CouponId"));
                order.setTableId(orderRs.getString("TableId"));
                order.setCustomerPhone(orderRs.getString("CustomerPhone"));
                order.setTotal(orderRs.getDouble("Total"));

                // Nếu có Coupon, tính toán giảm giá
                if (order.getCouponId() != null) {
                    double discountAmount = orderRs.getDouble("DiscountAmount");
                    order.setTotal(order.getTotal() - discountAmount); // Giảm giá từ tổng tiền
                }
            }

            // Lấy danh sách OrderDetail
            if (order != null) {
                detailPs.setString(1, orderId);
                ResultSet detailRs = detailPs.executeQuery();
                List<OrderDetail> orderDetails = new ArrayList<>();
                while (detailRs.next()) {
                    OrderDetail detail = new OrderDetail();
                    detail.setOrderDetailId(detailRs.getString("OrderDetailId"));
                    detail.setOrderId(detailRs.getString("OrderId"));
                    detail.setDishId(detailRs.getString("DishId"));
                    detail.setQuantity(detailRs.getInt("Quantity"));
                    detail.setSubtotal(detailRs.getDouble("Subtotal"));
                    detail.setDishName(detailRs.getString("DishName"));
                    detail.setQuantityUsed(detailRs.getInt("QuantityUsed"));
                    orderDetails.add(detail);
                }
                order.setOrderDetails(orderDetails);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }
        return order;
    }
}