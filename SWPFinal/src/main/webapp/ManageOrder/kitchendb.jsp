<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Model.Order, Model.OrderDetail, Model.Account, java.util.List" %>
<%
    Account account = (Account) session.getAttribute("account");
    if (session == null || account == null || !"Kitchen staff".equals(account.getUserRole())) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }
    List<Order> pendingOrders = (List<Order>) request.getAttribute("pendingOrders");
%>
<html>
<head>
    <title>Kitchen Dashboard</title>
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
            max-width: 1200px;
            margin: 0 auto;
        }
        h1 {
            font-size: 28px;
            color: #2c3e50;
            margin-bottom: 20px;
            font-weight: 600;
        }
        h3 {
            font-size: 20px;
            color: #34495e;
            margin-bottom: 15px;
        }
        .order-list {
            width: 100%;
            border-collapse: collapse;
            background: #fff;
            border-radius: 8px;
            overflow: hidden;
        }
        .order-list th, .order-list td {
            padding: 12px 15px;
            border: 1px solid #e0e6ed;
            text-align: left;
            font-size: 14px;
        }
        .order-list th {
            background: linear-gradient(90deg, #4CAF50, #45a049);
            color: #fff;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .order-list tr:nth-child(even) {
            background-color: #fafafa;
        }
        .order-list tr:hover {
            background-color: #f1f5f9;
            transition: background 0.3s;
        }
        .pending { background-color: #fff9c4; }
        .processing { background-color: #ffe0b2; }
        .button {
            padding: 8px 15px;
            border: none;
            border-radius: 5px;
            color: #fff;
            cursor: pointer;
            text-decoration: none;
            font-size: 14px;
            transition: transform 0.2s, opacity 0.2s;
            box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
        }
        .btn-primary {
            background: linear-gradient(90deg, #2196F3, #1e88e5);
        }
        .button:hover {
            transform: translateY(-2px);
            opacity: 0.9;
        }
        @media (max-width: 768px) {
            .sidebar { width: 200px; }
            .main-content { margin-left: 200px; }
            .order-list th, .order-list td { font-size: 12px; padding: 8px; }
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
                <h1>Kitchen Dashboard</h1>
                <h3>List of Pending Orders</h3>
                <table class="order-list">
                    <tr>
                        <th>Order ID</th>
                        <% if ("Kitchen staff".equals(account.getUserRole())) { %>
                            <th>Order Date</th>
                            <th>Dish List</th>
                            <th>Description</th>
                        <% } %>
                        <th>Status</th>
                        <th>Action</th>
                    </tr>
                    <% if (pendingOrders != null && !pendingOrders.isEmpty()) { %>
                        <% for (Order order : pendingOrders) { %>
                            <tr class="<%= "Pending".equals(order.getOrderStatus()) ? "pending" : "processing" %>">
                                <td><%= order.getOrderId() %></td>
                                <% if ("Kitchen staff".equals(account.getUserRole())) { %>
                                    <td><%= new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(order.getOrderDate()) %></td>
                                    <td>
                                        <% if (order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) { %>
                                            <% for (OrderDetail detail : order.getOrderDetails()) { %>
                                                <%= detail.getDishName() %> (<%= detail.getQuantity() %>),
                                            <% } %>
                                        <% } else { %>
                                            No dishes yet
                                        <% } %>
                                    </td>
                                    <td><%= order.getOrderDescription() != null ? order.getOrderDescription() : "No description" %></td>
                                <% } %>
                                <td><%= order.getOrderStatus() %></td>
                                <td>
                                    <a href="${pageContext.request.contextPath}/kitchen?action=viewOrder&orderId=<%= order.getOrderId() %>" class="button btn-primary">View Details</a>
                                </td>
                            </tr>
                        <% } %>
                    <% } else { %>
                        <tr><td colspan="<%= "Kitchen staff".equals(account.getUserRole()) ? "6" : "3" %>" style="text-align: center;">No orders are currently pending.</td></tr>
                    <% } %>
                </table>
            </div>
        </div>
    </div>
</body>
</html>