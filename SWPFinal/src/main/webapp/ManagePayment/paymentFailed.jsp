<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Thanh toán thất bại</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 600px; margin: 0 auto; background: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.1); text-align: center; }
        h1 { color: #f44336; }
        p { font-size: 16px; color: #333; }
        .button { padding: 12px 20px; margin: 5px; border: none; border-radius: 5px; color: white; cursor: pointer; font-size: 16px; background-color: #2196F3; }
        .button:hover { opacity: 0.9; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Thanh toán thất bại!</h1>
        <p>Giao dịch thanh toán qua VNPay không thành công.</p>
        <p>Lý do: <%= request.getParameter("message") != null ? request.getParameter("message") : "Không xác định" %></p>
        <%
            String orderId = request.getParameter("orderId");
            if (orderId != null && !orderId.isEmpty()) {
        %>
        <p>Đơn hàng: <strong><%= orderId %></strong></p>
        <button class="button" onclick="window.location.href='/payment?action=viewOrder&orderId=<%= orderId %>'">Quay lại chi tiết đơn hàng</button>
        <%
            } else {
        %>
        <button class="button" onclick="window.location.href='/payment?action=listOrders'">Quay lại danh sách đơn hàng</button>
        <%
            }
        %>
    </div>
</body>
</html>