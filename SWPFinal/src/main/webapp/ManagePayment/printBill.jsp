<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Model.Order" %>
<%@ page import="Model.OrderDetail" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Print Invoice</title>
    <style>
        .invoice-box {
            max-width: 800px;
            margin: auto;
            padding: 30px;
            border: 1px solid #eee;
            font-size: 16px;
            line-height: 24px;
            font-family: 'Helvetica', sans-serif;
        }
        .hidden-print {
            display: block;
        }
        @media print {
            .hidden-print {
                display: none;
            }
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            padding: 10px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        h1 {
            text-align: center;
            font-size: 24px;
            margin-bottom: 20px;
        }
        p {
            margin: 10px 0;
        }
        .total {
            font-weight: bold;
            font-size: 18px;
        }
        .button {
            padding: 10px 20px;
            margin: 5px;
            background-color: #4CAF50;
            color: white;
            border: none;
            cursor: pointer;
        }
    </style>
</head>
<body>
    <div class="invoice-box">
        <h1>Restaurant Invoice</h1>
        <%
            Order order = (Order) request.getAttribute("order");
            String formattedDate = (String) request.getAttribute("formattedDate");
            Map<String, String> pendingCashOrder = (Map<String, String>) request.getAttribute("pendingCashOrder");
            Boolean autoPrint = (Boolean) request.getAttribute("autoPrint");
            if (order != null) {
        %>
        <p>Invoice ID: <%= order.getOrderId() %></p>
        <p>Date: <%= formattedDate %></p>
        <p>Customer Phone: <%= order.getCustomerPhone() %></p>
        <%
            if (order.getCustomerId() != null) {
        %>
        <p>Customer Name: <%= order.getCustomerId() %></p>
        <%
            }
        %>

        <table border="1">
            <thead>
                <tr>
                    <th>Item Name</th>
                    <th>Quantity</th>
                    <th>Unit Price</th>
                    <th>Subtotal</th>
                </tr>
            </thead>
            <tbody>
                <%
                    List<OrderDetail> orderDetails = order.getOrderDetails();
                    if (orderDetails != null) {
                        for (OrderDetail detail : orderDetails) {
                            double unitPrice = detail.getSubtotal() / detail.getQuantity();
                %>
                <tr>
                    <td><%= detail.getDishName() %></td>
                    <td><%= detail.getQuantity() %></td>
                    <td><%= String.format("%.2f", unitPrice) %></td>
                    <td><%= String.format("%.2f", detail.getSubtotal()) %></td>
                </tr>
                <%
                        }
                    }
                %>
            </tbody>
        </table>

        <p>Total Before Discount: <%= String.format("%.2f", order.getTotal()) %> VND</p>
        <%
            if (pendingCashOrder != null && pendingCashOrder.containsKey("finalPrice")) {
        %>
        <p class="total">Total After Discount: <%= String.format("%.2f", Double.parseDouble(pendingCashOrder.get("finalPrice"))) %> VND</p>
        <%
            } else {
        %>
        <p class="total">Total After Discount: <%= String.format("%.2f", order.getFinalPrice()) %> VND</p>
        <%
            }
            if (order.getCouponId() != null) {
        %>
        <p>Discount Code: <%= order.getCouponId() %></p>
        <%
            }
        %>

        <%
            if (pendingCashOrder != null && "Processing".equals(order.getOrderStatus())) {
        %>
        <form action="/printBill" method="post" class="hidden-print">
            <input type="hidden" name="action" value="printInvoice">
            <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
            <button type="submit" class="button">Print Invoice</button>
        </form>
        <%
            } else {
        %>
        <button class="hidden-print button" onclick="window.print()">Print</button>
        <%
            }
        %>
        <a href="/payment?action=listOrders" class="hidden-print">Back</a>
        <%
            } else {
        %>
        <p>Invoice not found.</p>
        <%
            }
        %>

        <%-- Script để tự động in khi có autoPrint --%>
        <%
            if (autoPrint != null && autoPrint) {
        %>
        <script>
            window.onload = function() {
                window.print();
            }
        </script>
        <%
            }
        %>
    </div>
</body>
</html>