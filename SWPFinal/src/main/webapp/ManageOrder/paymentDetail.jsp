<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Model.Order, Model.OrderDetail, Model.Coupon, java.util.List, Model.Account" %>
<html>
<head>
    <title>Payment - Order Details</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body { 
            font-family: 'Roboto', sans-serif; 
            margin: 0; 
            background-color: #f8f9fa; 
            padding: 0;
            display: flex;
            justify-content: center;
            min-height: 100vh;
        }
        .d-flex {
            display: flex;
            width: 100%;
            max-width: 1200px;
            margin: 0 auto;
        }
        h1 { 
            color: #333; 
            text-align: center; 
            margin-bottom: 20px;
        }
        .container { 
            width: 100%;
            max-width: 800px; 
            background: #fff; 
            padding: 20px; 
            border-radius: 8px; 
            box-shadow: 0 0 10px rgba(0,0,0,0.1); 
            margin: 0 auto;
        }
        .order-table { 
            width: 100%; 
            border-collapse: collapse; 
            margin-bottom: 20px; 
        }
        .order-table th, .order-table td { 
            border: 1px solid #ddd; 
            padding: 10px; 
            text-align: left; 
        }
        .order-table th { 
            background-color: #4CAF50; 
            color: white; 
        }
        .order-table td {
            background-color: #fff;
        }
        .order-table tr:nth-child(even) {
            background-color: #f9f9f9;
        }
        .button { 
            padding: 12px 20px; 
            margin: 5px; 
            border: none; 
            border-radius: 5px; 
            color: white; 
            cursor: pointer; 
            font-size: 16px; 
            transition: opacity 0.2s;
        }
        .button.pay { 
            background-color: #4CAF50; 
        }
        .button.back { 
            background-color: #f44336; 
        }
        .button:hover { 
            opacity: 0.9; 
        }
        .coupon-section { 
            margin-top: 20px; 
            padding: 15px; 
            background-color: #f9f9f9; 
            border-radius: 5px; 
            text-align: center;
        }
        .coupon-section h2 {
            font-size: 1.2rem;
            margin-bottom: 10px;
        }
        .coupon-section select { 
            padding: 8px; 
            margin: 5px 0; 
            width: 200px; 
        }
        .debug { 
            color: red; 
            font-size: 12px; 
            margin-top: 10px; 
            text-align: center;
        }
        .message { 
            color: green; 
            font-size: 14px; 
            margin-bottom: 10px; 
            text-align: center;
        }
        .status-message { 
            font-size: 14px; 
            margin-bottom: 10px; 
            text-align: center;
        }
        .status-pending { 
            color: #ff9800; 
        }
        .modal { 
            display: none; 
            position: fixed; 
            z-index: 1; 
            left: 0; 
            top: 0; 
            width: 100%; 
            height: 100%; 
            background-color: rgba(0,0,0,0.4); 
        }
        .modal-content { 
            background-color: #fff; 
            margin: 15% auto; 
            padding: 20px; 
            border: 1px solid #888; 
            width: 300px; 
            text-align: center; 
            border-radius: 5px; 
        }
        .modal-button { 
            padding: 10px 20px; 
            margin: 5px; 
            border: none; 
            border-radius: 5px; 
            color: white; 
            cursor: pointer; 
        }
        .modal-button.cash { 
            background-color: #4CAF50; 
        }
        .modal-button.online { 
            background-color: #2196F3; 
        }
        .sidebar {
            height: 100vh;
            width: 250px;
            position: fixed;
            top: 0;
            left: 0;
            background-color: #343a40;
            padding-top: 20px;
            transition: 0.3s;
            z-index: 1000;
            color: white;
        }
        .sidebar .nav-link {
            color: #fff;
            padding: 15px 25px;
            text-decoration: none;
            display: flex;
            align-items: center;
            transition: 0.3s;
            font-size: 16px;
        }
        .sidebar .nav-link i {
            margin-right: 10px;
            width: 20px;
            text-align: center;
        }
        .sidebar .nav-link:hover {
            background-color: #495057;
            color: #fff;
        }
        .sidebar .nav-link.active {
            background-color: #007bff;
            color: #fff;
        }
        .sidebar h4 {
            color: #fff;
            text-align: center;
            padding: 20px 0;
            margin: 0;
            font-size: 24px;
            font-weight: 600;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }
        .content {
            padding: 20px;
            margin-left: 250px;
            flex-grow: 1;
            display: flex;
            justify-content: center;
            align-items: flex-start;
        }
        @media (max-width: 768px) {
            .sidebar {
                width: 200px;
            }
            .content {
                margin-left: 200px;
            }
        }
        @media (max-width: 576px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }
            .content {
                margin-left: 0;
            }
            .d-flex {
                flex-direction: column;
                align-items: center;
            }
        }
    </style>
</head>
<body>
    <%
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
            return;
        }
        String userRole = account.getUserRole();
        
        String message = (String) request.getAttribute("message");
        if (message != null) {
            System.out.println("Message content: " + message);
        }
    %>
    <div class="d-flex">
        <!-- Sidebar -->
        <div class="sidebar">
            <h4>Cashier</h4>
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/payment?action=listOrders" class="nav-link active">
                        <i class="fas fa-money-bill"></i> Payment
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/view-notifications" class="nav-link">
                        <i class="fas fa-bell"></i> View Notifications
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/viewAccountDetail" class="nav-link">
                        <i class="fas fa-user"></i> View Profile
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/logout" class="nav-link">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </li>
            </ul>
        </div>

        <!-- Main Content -->
        <div class="content">
            <div class="container">
                <%
                    Order order = (Order) request.getAttribute("order");
                    if (order != null) {
                        boolean isProcessing = "Processing".equals(order.getOrderStatus());
                        boolean isCompleted = "Completed".equals(order.getOrderStatus());
                %>
                <h1>Order Payment - <%=order.getOrderId()%> (Table <%=order.getTableId() != null ? order.getTableId() : "Takeaway"%>)</h1>
                <%
                    if (message != null) {
                %>
                <p class="message"><%=message%></p>
                <%
                    }
                    if ("Pending".equals(order.getOrderStatus())) {
                %>
                <p class="status-message status-pending">The order is in 'Pending' status. Payment cannot be processed at this time.</p>
                <%
                    }
                    List<OrderDetail> details = order.getOrderDetails();
                    if (details != null && !details.isEmpty()) {
                %>
                <table class="order-table">
                    <tr>
                        <th>Dish Name</th>
                        <th>Quantity</th>
                        <th>Subtotal</th>
                    </tr>
                    <%
                        for (OrderDetail detail : details) {
                    %>
                    <tr>
                        <td><%=detail.getDishName() != null ? detail.getDishName() : "No Name"%></td>
                        <td><%=detail.getQuantity() != 0 ? detail.getQuantity() : "N/A"%></td>
                        <td><%=String.format("%.2f", detail.getSubtotal())%> VND</td>
                    </tr>
                    <%
                        }
                    %>
                    <tr>
                        <td colspan="2"><strong>Total (before coupon)</strong></td>
                        <td><strong><%=String.format("%.2f", order.getTotal())%> VND</strong></td>
                    </tr>
                    <%
                        if (isCompleted) {
                    %>
                    <tr>
                        <td colspan="2"><strong>Total (after coupon)</strong></td>
                        <td><strong><%=String.format("%.2f", order.getFinalPrice())%> VND</strong></td>
                    </tr>
                    <%
                        }
                    %>
                </table>
                <%
                    } else {
                %>
                <p class="debug">No order details available.</p>
                <%
                    }
                %>

                <div class="coupon-section">
                    <h2>Apply Coupon Code</h2>
                    <%
                        List<Coupon> coupons = (List<Coupon>) request.getAttribute("coupons");
                        if (isProcessing && coupons != null) {
                    %>
                    <form id="couponForm">
                        <input type="hidden" name="orderId" value="<%=order.getOrderId()%>">
                        <input type="hidden" name="tableId" value="<%=order.getTableId() != null ? order.getTableId() : ""%>">
                        <select name="couponId" id="couponSelect">
                            <option value="">-- Select Coupon --</option>
                            <%
                                if (!coupons.isEmpty()) {
                                    for (Coupon coupon : coupons) {
                            %>
                            <option value="<%=coupon.getCouponId()%>" <%=order.getCouponId() != null && order.getCouponId().equals(coupon.getCouponId()) ? "selected" : ""%>>
                                <%=coupon.getCouponId()%> - Discount <%=coupon.getDiscountAmount() != null ? coupon.getDiscountAmount() : "N/A"%> VND 
                                (Expires: <%=coupon.getExpirationDate() != null ? coupon.getExpirationDate() : "N/A"%>)
                            </option>
                            <%
                                    }
                                } else {
                            %>
                            <option value="">No coupons available (empty list)</option>
                            <%
                                }
                            %>
                        </select>
                    </form>
                    <%
                        } else {
                    %>
                    <div>Coupons are only displayed when the status is 'Processing'.</div>
                    <%
                        }
                    %>
                </div>

                <div class="order-buttons">
                    <% if (isProcessing && coupons != null) { %>
                        <button type="button" class="button pay" onclick="showPaymentOptions()">Pay</button>
                    <% } %>
                    <button type="button" class="button back" onclick="window.location.href='/payment?action=listOrders'">Back</button>
                </div>

                <div id="paymentModal" class="modal">
                    <div class="modal-content">
                        <h3>Select Payment Method</h3>
                        <form id="payCashForm" action="/payment" method="post">
                            <input type="hidden" name="action" value="payCash">
                            <input type="hidden" name="orderId" value="<%=order.getOrderId()%>">
                            <input type="hidden" name="tableId" value="<%=order.getTableId() != null ? order.getTableId() : ""%>">
                            <input type="hidden" name="couponId" id="payCashCouponId">
                            <button type="submit" class="modal-button cash">Pay with Cash</button>
                        </form>
                        <form id="payOnlineForm" action="/payment" method="post">
                            <input type="hidden" name="action" value="payOnline">
                            <input type="hidden" name="orderId" value="<%=order.getOrderId()%>">
                            <input type="hidden" name="tableId" value="<%=order.getTableId() != null ? order.getTableId() : ""%>">
                            <input type="hidden" name="couponId" id="payOnlineCouponId">
                            <button type="submit" class="modal-button online">Pay Online</button>
                        </form>
                    </div>
                </div>
                <%
                    } else {
                %>
                <p class="debug">Order not found.</p>
                <%
                    }
                %>
            </div>
        </div>
    </div>

    <script>
        function showPaymentOptions() {
            var couponId = document.getElementById("couponSelect").value;
            document.getElementById("payCashCouponId").value = couponId;
            document.getElementById("payOnlineCouponId").value = couponId;
            document.getElementById("paymentModal").style.display = "block";
        }

        window.onclick = function(event) {
            var modal = document.getElementById("paymentModal");
            if (event.target == modal) {
                modal.style.display = "none";
            }
        }
    </script>
</body>
</html>