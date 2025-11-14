<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Model.Order" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Thanh toán thành công</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); text-align: center; }
        h1 { color: #4CAF50; }
        p { font-size: 16px; color: #333; }
        .button { padding: 12px 20px; margin: 5px; border: none; border-radius: 5px; color: white; cursor: pointer; font-size: 16px; }
        .button.print { background-color: #4CAF50; }
        .button.back { background-color: #2196F3; }
        .button:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Thanh toán thành công!</h1>
        <%
            Order order = (Order) request.getAttribute("order");
            if (order != null) {
        %>
        <p>Đơn hàng <strong><%= order.getOrderId() %></strong> đã được thanh toán thành công qua VNPay.</p>
        <p>Tổng tiền trước giảm giá: <%= String.format("%.2f", order.getTotal()) %> VND</p>
        <p>Tổng tiền sau giảm giá: <%= String.format("%.2f", order.getFinalPrice()) %> VND</p>
        <%
            } else {
        %>
        <p>Thanh toán đã hoàn tất, nhưng không tìm thấy thông tin đơn hàng.</p>
        <%
            }
        %>
        <button class="button print" onclick="window.location.href='/printBill?orderId=<%= order != null ? order.getOrderId() : "" %>'">In hóa đơn</button>
        <button class="button back" onclick="window.location.href='/payment?action=listOrders'">Quay lại danh sách đơn hàng</button>
    </div>
</body>
</html>