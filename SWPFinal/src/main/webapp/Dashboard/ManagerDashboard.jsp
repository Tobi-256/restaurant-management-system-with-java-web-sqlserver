<%@page import="Model.Revenue"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="Model.Account" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%
    if (session == null || session.getAttribute("account") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    Account account = (Account) session.getAttribute("account");
    String userRole = account.getUserRole();
    String userName = account.getUserName();

    if (!"Admin".equals(userRole) && !"Manager".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    DecimalFormat currencyFormat = new DecimalFormat("#,###VNĐ");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= userRole %> Dashboard - Restaurant Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f8f9fa;
            }

            .sidebar {
                background: linear-gradient(to bottom, #2C3E50, #34495E);
                color: white;
                height: 100vh;
                position: sticky; /* Keep sidebar fixed */
                top: 0;
                 position: fixed;
                width: 16.67%;
            }

            .sidebar a {
                color: white;
                text-decoration: none;
            }

            .sidebar a:hover {
                background-color: #1A252F;
            }

            .sidebar .nav-link {
                font-size: 0.9rem;
            }

            .sidebar h4 {
                font-size: 1.5rem;
            }
        .content-area {
            margin-left: 16.67%;
            padding: 20px;
        }
        .card-stats {
            background: linear-gradient(to right, #4CAF50, #81C784);
            color: white;
        }
        .card-stats i {
            font-size: 2rem;
        }
        .chart-container {
            position: relative;
            height: 300px;
        }
    </style>
</head>
<body>
    <div class="d-flex">
        <div class="sidebar col-md-2 p-3">
            <h4 class="text-center mb-4"><%= userRole %></h4>
            <ul class="nav flex-column">
                <li class="nav-item"><a href="${pageContext.request.contextPath}/dashboard" class="nav-link"><i class="fas fa-home me-2"></i>Dashboard</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/view-revenue" class="nav-link"><i class="fas fa-chart-line me-2"></i>View Revenue</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/viewalldish" class="nav-link"><i class="fas fa-list-alt me-2"></i>Menu Management</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewAccountList" class="nav-link"><i class="fas fa-users me-2"></i>Employee Management</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewTableList" class="nav-link"><i class="fas fa-building me-2"></i>Table Management</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewOrderList" class="nav-link"><i class="fas fa-shopping-cart me-2"></i>Order Management</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewCustomerList" class="nav-link"><i class="fas fa-user-friends me-2"></i>Customer Management</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewCouponController" class="nav-link"><i class="fas fa-tag me-2"></i>Coupon Management</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewInventoryController" class="nav-link"><i class="fas fa-boxes me-2"></i>Inventory Management</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/view-notifications" class="nav-link"><i class="fas fa-bell me-2"></i>View Notifications</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/create-notification" class="nav-link"><i class="fas fa-plus me-2"></i>Create Notification</a></li>
           
                <li class="nav-item"><a href="${pageContext.request.contextPath}/logout" class="nav-link"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
            </ul>
        </div>

        <div class="col-md-10 p-4 content-area">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3>Dashboard</h3>
                <div class="d-flex align-items-center">
                    <span class="me-2">Hello, <%= userName %></span>
                    <%
                        String userImage = account.getUserImage();
                        String imagePath = request.getContextPath() + "/ManageAccount/account_img/" + userImage;
                        out.println("<img src='" + imagePath + "' alt='User Image' class='rounded-circle me-2' style='width: 40px; height: 40px;'>");
                    %>
                    <a href="${pageContext.request.contextPath}/viewAccountDetail" class="btn btn-sm btn-primary">View Profile</a>
                </div>
            </div>

            <!-- Quick Stats -->
            <div class="row mb-4">
                <div class="col-md-3">
                    <div class="card card-stats p-3 text-center">
                        <i class="fas fa-dollar-sign"></i>
                        <h5 class="mt-2">Today's Revenue</h5>
                        <p class="mb-0"><%= currencyFormat.format(request.getAttribute("todayRevenue") != null ? (Double) request.getAttribute("todayRevenue") : 000.0) %></p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card card-stats p-3 text-center" style="background: linear-gradient(to right, #FF9800, #FFB74D);">
                        <i class="fas fa-shopping-cart"></i>
                        <h5 class="mt-2">New Orders</h5>
                        <p class="mb-0"><%= request.getAttribute("newOrders") %> orders</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card card-stats p-3 text-center" style="background: linear-gradient(to right, #03A9F4, #4FC3F7);">
                        <i class="fas fa-utensils"></i>
                        <h5 class="mt-2">Dishes for Sale</h5>
                        <p class="mb-0"><%= request.getAttribute("dishesForSale") %> dishes</p>
                    </div>
                </div>
                <div class="col-md-3">
                    <div class="card card-stats p-3 text-center" style="background: linear-gradient(to right, #E91E63, #F06292);">
                        <i class="fas fa-users"></i>
                        <h5 class="mt-2">Active Employees</h5>
                        <p class="mb-0"><%= request.getAttribute("activeEmployees") %> employees</p>
                    </div>
                </div>
            </div>

            <!-- Revenue Chart -->
            <div class="row mb-4">
                <div class="col-md-8">
                    <div class="card p-4">
                        <h5>Revenue Chart (Last 7 Days)</h5>
                        <canvas id="revenueChart" class="chart-container"></canvas>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="card p-4">
                        <h5>Top Selling Dishes</h5>
                        <canvas id="topItemsChart" class="chart-container"></canvas>
                    </div>
                </div>
            </div>

            <!-- Recent Orders Table -->
            <div class="row">
                <div class="col-md-12">
                    <div class="card p-4">
                        <h5>Recent Orders</h5>
                        <table class="table table-striped">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Customer Name</th>
                                    <th>Total Amount</th>
                                    <th>Status</th>
                                    <th>Time</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% List<Map<String, Object>> recentOrders = (List<Map<String, Object>>) request.getAttribute("recentOrders");
                                   if (recentOrders != null) {
                                       for (Map<String, Object> order : recentOrders) { %>
                                <tr>
                                    <td><%= order.get("OrderId") %></td>
                                    <td><%= order.get("CustomerName") %></td>
                                    <td><%= currencyFormat.format(order.get("TotalAmount")) %></td>
                                    <td>
                                        <% String status = (String) order.get("OrderStatus");
                                           if ("Pending".equals(status)) { %>
                                        <span class="badge bg-warning">Pending</span>
                                        <% } else if ("Completed".equals(status)) { %>
                                        <span class="badge bg-success">Completed</span>
                                        <% } else { %>
                                        <span class="badge bg-secondary"><%= status %></span>
                                        <% } %>
                                    </td>
                                    <td><%= dateFormat.format(order.get("OrderDate")) %></td>
                                </tr>
                                <% } } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Chart.js Scripts -->
    <script>
    // Revenue Chart
    const revenueCtx = document.getElementById('revenueChart').getContext('2d');
    const revenueData = {
        labels: [<% List<Revenue> revenueData = (List<Revenue>) request.getAttribute("revenueData");
                    if (revenueData != null && !revenueData.isEmpty()) {
                        for (Revenue revenue : revenueData) { %>
                            '<%= revenue.getRevenueId() %>', // Dùng RevenueId làm nhãn
                    <% } } %>],
        datasets: [{
            label: 'Revenue (VNĐ)',
            data: [<% if (revenueData != null && !revenueData.isEmpty()) {
                        for (Revenue revenue : revenueData) { %>
                            <%= revenue.getTotalRevenue() %>,
                    <% } } %>],
            borderColor: '#4CAF50',
            backgroundColor: 'rgba(76, 175, 80, 0.2)',
            borderWidth: 2,
            fill: true
        }]
    };
    const revenueChart = new Chart(revenueCtx, {
        type: 'line',
        data: revenueData,
        options: {
            responsive: true,
            plugins: {
                legend: { display: true }
            }
        }
    });

    // Top Items Chart
    const topItemsCtx = document.getElementById('topItemsChart').getContext('2d');
    const topItemsData = {
        labels: [<% Map<String, Integer> topDishes = (Map<String, Integer>) request.getAttribute("topDishes");
                    if (topDishes != null && !topDishes.isEmpty()) {
                        for (String dishName : topDishes.keySet()) { %>
                            '<%= dishName %>',
                    <% } } %>],
        datasets: [{
            data: [<% if (topDishes != null && !topDishes.isEmpty()) {
                        for (Integer quantity : topDishes.values()) { %>
                            <%= quantity %>,
                    <% } } %>],
            backgroundColor: ['#4CAF50', '#FF9800', '#03A9F4', '#E91E63', '#9C27B0']
        }]
    };
    const topItemsChart = new Chart(topItemsCtx, {
        type: 'pie',
        data: topItemsData,
        options: {
            responsive: true,
            plugins: {
                legend: { display: true }
            }
        }
    });
    </script>
</body>
</html>