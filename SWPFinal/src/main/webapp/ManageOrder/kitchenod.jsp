<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Model.Order, Model.OrderDetail, Model.Account" %>
<%
    Account account = (Account) session.getAttribute("account");
    if (session == null || account == null || !"Kitchen staff".equals(account.getUserRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }
    Order order = (Order) request.getAttribute("order");
    if (order == null) {
        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
        return;
    }
%>
<html>
<head>
    <title>Order Details - <%= order.getOrderId() %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
         body {
            font-family: 'Roboto', sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            min-height: 100vh;
        }
        .container-fluid {
            display: flex;
            min-height: 100vh;
            padding: 0;
        }
        /* Sidebar (Matched with Table List) */
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
        .sidebar .nav.flex-column {
            list-style: none; /* Remove bullet points */
            padding: 0; /* Remove default padding */
            margin: 0; /* Remove default margin */
        }
        /* Main Content */
        .main-content {
            margin-left: 250px;
            padding: 30px;
            width: 100%;
            background-color: #f4f7fa;
        }
        .container {
            background: #fff;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
            max-width: 800px;
            margin: 0 auto;
        }
        h1 {
            font-size: 28px;
            color: #2c3e50;
            margin-bottom: 20px;
            font-weight: 600;
        }
        p {
            font-size: 16px;
            margin: 10px 0;
            line-height: 1.5;
        }
        p strong {
            color: #34495e;
        }
        .order-details {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
            border-radius: 8px;
            overflow: hidden;
            margin-top: 20px;
        }
        .order-details th, .order-details td {
            padding: 12px 15px;
            border: 1px solid #e0e6ed;
            text-align: left;
            font-size: 14px;
        }
        .order-details th {
            background: linear-gradient(90deg, #4CAF50, #45a049);
            color: #fff;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .order-details tr:nth-child(even) {
            background-color: #fafafa;
        }
        .order-details tr:hover {
            background-color: #f1f5f9;
            transition: background 0.3s;
        }
        .button {
            padding: 8px 15px;
            border: none;
            border-radius: 5px;
            color: #fff;
            cursor: pointer;
            font-size: 14px;
            transition: transform 0.2s, opacity 0.2s;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
            text-decoration: none;
            display: inline-block;
        }
        .btn-success {
            background: linear-gradient(90deg, #4CAF50, #45a049);
        }
        .btn-primary {
            background: linear-gradient(90deg, #2196F3, #1e88e5);
        }
        .button:hover {
            transform: translateY(-2px);
            opacity: 0.9;
        }
        .error { color: #e74c3c; font-weight: 600; text-align: center; margin: 10px 0; }
        .success { color: #2ecc71; font-weight: 600; text-align: center; margin: 10px 0; }
        .button-group { margin-top: 20px; text-align: center; }
        @media (max-width: 768px) {
            .sidebar { width: 200px; }
            .main-content { margin-left: 200px; }
            .order-details th, .order-details td { font-size: 12px; padding: 8px; }
        }
        @media (max-width: 576px) {
            .sidebar { width: 100%; height: auto; position: relative; }
            .main-content { margin-left: 0; padding: 15px; }
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <!-- Sidebar -->
        <div class="sidebar">
            <h4>Kitchen</h4>
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/kitchen" class="nav-link active">
                        <i class="fas fa-list"></i> Order List
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
                    <a href="${pageContext.request.contextPath}/LoginPage.jsp" class="nav-link">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </li>
            </ul>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <div class="container">
                <h1>Order Details: <%= order.getOrderId() %></h1>
                <p><strong>Table:</strong> <%= order.getTableId() %></p>
                <p><strong>Order Date:</strong> <%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(order.getOrderDate()) %></p>
                <p><strong>Description:</strong> <%= order.getOrderDescription() != null ? order.getOrderDescription() : "No description" %></p>
                <p><strong>Status:</strong> <%= order.getOrderStatus() %></p>
                
                <% if (request.getAttribute("errorMessage") != null) { %>
                    <p class="error"><%= request.getAttribute("errorMessage") %></p>
                <% } %>
                <% if (request.getAttribute("successMessage") != null) { %>
                    <p class="success"><%= request.getAttribute("successMessage") %></p>
                <% } %>
                
                <table class="order-details">
                    <tr>
                        <th>Dish Name</th>
                        <th>Quantity</th>
                        <th>Unit Price</th>
                        <th>Subtotal</th>
                    </tr>
                    <% if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) { %>
                        <% for (OrderDetail detail : order.getOrderDetails()) { %>
                            <tr>
                                <td><%= detail.getDishName() %></td>
                                <td><%= detail.getQuantity() %></td>
                                <td><%= String.format("%,.0f ₫", detail.getSubtotal() / detail.getQuantity()) %></td>
                                <td><%= String.format("%,.0f ₫", detail.getSubtotal()) %></td>
                            </tr>
                        <% } %>
                    <% } else { %>
                        <tr><td colspan="4">No dishes added yet.</td></tr>
                    <% } %>
                </table>
                <div class="button-group">
                    <% if ("Pending".equals(order.getOrderStatus())) { %>
                        <form action="${pageContext.request.contextPath}/kitchen" method="post" style="display: inline;">
                            <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                            <input type="hidden" name="newStatus" value="Processing">
                            <button type="submit" class="button btn-success">Change to Processing</button>
                        </form>
                    <% } else if ("Processing".equals(order.getOrderStatus())) { %>
                        <form action="${pageContext.request.contextPath}/kitchen" method="post" style="display: inline;">
                            <input type="hidden" name="orderId" value="<%= order.getOrderId() %>">
                            <input type="hidden" name="newStatus" value="Completed">
                        </form>
                    <% } %>
                    <a href="${pageContext.request.contextPath}/kitchen" class="button btn-primary" style="margin-left: 10px;">Back</a>
                </div>
            </div>
        </div>
    </div>
</body>
</html>