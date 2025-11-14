<%@page import="Model.Account"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Model.Dish, java.util.List" %>
<%
    if (session == null || session.getAttribute("account") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    Account account = (Account) session.getAttribute("account");
    String UserRole = account.getUserRole();
    List<Dish> dishes = (List<Dish>) request.getAttribute("dishes");
    String returnTo = (String) request.getAttribute("returnTo");
    if (returnTo == null) {
        returnTo = "listTables"; // Default to listTables if returnTo is not specified
    }
%>
<html>
<head>
    <title>Select Dishes</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
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
            margin-left: 250px; /* Space for sidebar */
            padding: 30px;
            width: 100%;
           
            display: flex;
            justify-content: center;
            align-items: center;
            
        }
        .container {
            background: #fff;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            width: 100%;
        }
        h1 {
            color: #2c3e50;
            text-align: center;
            margin-bottom: 20px;
            font-size: 28px;
            font-weight: 600;
        }
        .dish-list {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        .dish-list th, .dish-list td {
            padding: 12px 15px;
            border: 1px solid #e0e0e0;
            text-align: left;
            font-size: 14px;
        }
        .dish-list th {
            background-color: #4CAF50;
            color: white;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .dish-list td {
            background-color: #fff;
            color: #333;
        }
        .dish-list tr:hover td {
            background-color: #f9f9f9;
            transition: background-color 0.3s;
        }
        .button {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            color: white;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        .button:hover {
            opacity: 0.9;
            transform: translateY(-2px);
        }
        .btn-primary {
            background-color: #007bff;
        }
        .btn-success {
            background-color: #28a745;
        }
        .error {
            color: #dc3545;
            text-align: center;
            margin-bottom: 15px;
            font-size: 14px;
            font-weight: 500;
        }
        input[type="number"] {
            width: 70px;
            padding: 6px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px;
            text-align: center;
        }
        input[type="number"]:focus {
            border-color: #007bff;
            outline: none;
            box-shadow: 0 0 5px rgba(0, 123, 255, 0.3);
        }
        .button-group {
            text-align: center;
            margin-top: 25px;
        }
        @media (max-width: 768px) {
            .sidebar {
                width: 200px;
            }
            .content {
                margin-left: 200px;
            }
            .container {
                padding: 15px;
            }
            .dish-list th, .dish-list td {
                padding: 8px;
                font-size: 12px;
            }
            input[type="number"] {
                width: 50px;
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
                padding: 15px;
            }
            .dish-list {
                font-size: 12px;
            }
            .button {
                padding: 8px 15px;
                font-size: 12px;
            }
        }
    </style>
</head>
<body>
    <div class="d-flex">
        <!-- Sidebar -->
        <% if ("Waiter".equals(UserRole)) { %>
        <div class="sidebar">
            <h4>Waiter</h4>
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/order?action=listTables" class="nav-link active">
                        <i class="fas fa-building"></i> Table List
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
        <% } %>

        <!-- Main Content -->
        <div class="content">
            <div class="container">
                <h1>Select Dishes for Table <%= request.getAttribute("tableId") %></h1>
                <% if (request.getAttribute("error") != null) { %>
                    <p class="error"><%= request.getAttribute("error") %></p>
                <% } %>
                <form action="${pageContext.request.contextPath}/order" method="post">
                    <input type="hidden" name="action" value="submitOrder">
                    <input type="hidden" name="tableId" value="<%= request.getAttribute("tableId") %>">
                    <table class="dish-list">
                        <tr>
                            <th>Dish Name</th>
                            <th>Type</th>
                            <th>Price</th>
                            <th>Description</th>
                            <th>Quantity</th>
                        </tr>
                        <% if (dishes != null && !dishes.isEmpty()) { %>
                            <% for (Dish dish : dishes) { %>
                                <tr>
                                    <td><%= dish.getDishName() %></td>
                                    <td><%= dish.getDishType() %></td>
                                    <td><%= dish.getDishPrice() %> VNĐ</td>
                                    <td><%= dish.getDishDescription() %></td>
                                    <td>
                                        <input type="number" name="quantity_<%= dish.getDishId() %>" min="0" value="0">
                                    </td>
                                </tr>
                            <% } %>
                        <% } else { %>
                            <tr>
                                <td colspan="5" style="text-align: center;">No dishes available.</td>
                            </tr>
                        <% } %>
                    </table>
                    <div class="button-group">
                        <button type="submit" class="button btn-success">Add to Order</button>
                        <%
                            String returnUrl;
                            if ("tableOverview".equals(returnTo)) {
                                returnUrl = request.getContextPath() + "/order?action=tableOverview&tableId=" + request.getAttribute("tableId");
                            } else {
                                returnUrl = request.getContextPath() + "/order?action=listTables";
                            }
                        %>
                        <a href="<%= returnUrl %>" class="button btn-primary" style="margin-left: 10px;">Back</a>
                    </div>
                </form>
            </div>
        </div>
    </div>
</body>
</html>