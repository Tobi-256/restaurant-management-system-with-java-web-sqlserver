<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Model.Table, Model.Order, java.util.List, Model.Account" %>
<html>
    <head>
        <title>Payment - Table List</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f8f9fa;
                padding: 20px;
                margin: 0;
            }
            .table-container {
                display: flex;
                flex-wrap: wrap; /* Allows wrapping to next line if needed */
                gap: 15px;
                overflow-x: auto; /* Horizontal scrolling if content exceeds width */
            }
            .table-card {
                border: 1px solid #ddd;
                padding: 15px;
                border-radius: 5px;
                background-color: white;
                box-shadow: 0 1px 3px rgba(0,0,0,0.1);
                transition: transform 0.2s ease-in-out;
                min-width: 250px; /* Minimum width for each card */
            }
            .table-card:hover {
                transform: translateY(-3px);
            }
            .table-card.pending {
                border-left: 5px solid #ff9800; /* Orange for Pending */
                background-color: #fff3e0;
            }
            .table-card.processing {
                border-left: 5px solid #4CAF50; /* Green for Processing */
                background-color: #e8f5e9;
            }
            .table-card.no-order {
                border-left: 5px solid #cccccc; /* Gray for no order */
                background-color: #f5f5f5;
            }
            .table-info {
                font-size: 0.9rem;
            }
            .table-info div {
                margin-bottom: 5px;
            }
            .table-status span {
                font-weight: bold;
                padding: 3px 8px;
                border-radius: 3px;
                color: white;
            }
            .table-card.pending .table-status span {
                background-color: #ff9800;
            }
            .table-card.processing .table-status span {
                background-color: #4CAF50;
            }
            .table-card.no-order .table-status span {
                background-color: #cccccc;
                color: #666;
            }
            .table-buttons a {
                padding: 7px 14px;
                border-radius: 5px;
                text-decoration: none;
                color: white;
                background-color: #4CAF50;
                margin-left: 53px;
            }
            .table-buttons a:hover {
                opacity: 0.9;
            }
            .table-buttons .disabled {
                background-color: #cccccc;
                cursor: not-allowed;
                pointer-events: none;
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
                    <h1 class="mb-4">Table List</h1>
                    <%
                        List<Table> tables = (List<Table>) request.getAttribute("tables");
                        if (tables != null && !tables.isEmpty()) {
                    %>
                    <div class="table-container">
                        <%
                            for (Table table : tables) {
                                Order order = table.getOrder();
                                String tableClass = "table-card ";
                                String statusText = "No Order";
                                if (order != null) {
                                    tableClass += order.getOrderStatus().equals("Pending") ? "pending" : "processing";
                                    statusText = order.getOrderStatus();
                                } else {
                                    tableClass += "no-order";
                                }
                        %>
                        <div class="<%= tableClass%>">
                            <div class="table-info">
                                <div><strong>Table ID:</strong> <%= table.getTableId()%></div>
                                <div><strong>Floor:</strong> <%= table.getFloorNumber()%></div>
                                <div><strong>Number of Seats:</strong> <%= table.getNumberOfSeats()%></div>
                                <% if (order != null) {%>
                                <div><strong>Order ID:</strong> <%= order.getOrderId()%></div>
                                <div><strong>Total:</strong> <%= String.format("%.2f", order.getTotal())%> VND</div>
                                <% }%>
                                <div class="table-status"><strong>Status:</strong> <span><%= statusText%></span></div>
                            </div>
                            <div class="table-buttons">
                                <% if (order != null) { %>
                                    <a href="payment?action=viewOrder&orderId=<%= order.getOrderId()%>">View & Pay</a>
                                <% } else { %>
                                    <a class="disabled">View & Pay</a>
                                <% } %>
                            </div>
                        </div>
                        <% } %>
                    </div>
                    <% } else { %>
                    <div class="no-tables">
                        <p>No tables in the system.</p>
                    </div>
                    <% }%>
                </div>
            </div>
        </div>
    </body>
</html>