<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.HttpSession" %>
<%@ page import="Model.Account" %>
<%@ page import="Model.Revenue" %>
<%@ page import="java.util.List" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    if (session == null || session.getAttribute("account") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    Account account = (Account) session.getAttribute("account");
    String userRole = account.getUserRole();
    if (!"Admin".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    DecimalFormat currencyFormat = new DecimalFormat("#,### VNĐ");
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Revenue - Restaurant Management</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
       
        .container-fluid {
            display: flex;
            height: 100vh;
            margin: 0; /* Loại bỏ margin mặc định */
            padding: 0; /* Loại bỏ padding mặc định */
        }
         body {
            font-family: 'Roboto', sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
            height: 100vh;
            overflow: hidden; /* Ngăn cuộn toàn trang */
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
            flex-grow: 1;
            display: flex;
            flex-direction: column;
            height: 100vh;
            background-color: #ffffff;
            box-shadow: inset 0 0 10px rgba(0, 0, 0, 0.05);
        }
        .header {
            padding: 1rem;
                color: white;
                margin-bottom: 20px;
                margin-left: -25px; /* Extend to edge */
                margin-right: -20px; /* Extend to edge */
                margin-top: -24px; /* Extend to edge */
                border-radius: 0; /* Remove rounding if needed */
            background: linear-gradient(to right, #2C3E50, #42A5F5);
            
        }
        .header h3 {
           font-size: 24px;
        }
        .filter-section {
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 15px;
            background-color: #f1f3f5;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .filter-section label {
            font-size: 1rem;
            font-weight: 500;
            color: #34495E;
            margin-right: 10px;
        }
        .filter-section select {
            width: 150px;
            padding: 8px;
            border-radius: 6px;
            border: 1px solid #ced4da;
            font-size: 1rem;
        }
        .stats-section {
            padding: 15px;
            background-color: #f1f3f5;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .card-stats {
            background: linear-gradient(to right, #4CAF50, #81C784);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }
        .card-stats i {
            font-size: 2rem;
            margin-bottom: 10px;
        }
        .card-stats h5 {
            font-size: 1.1rem;
            font-weight: 500;
            margin: 5px 0;
        }
        .card-stats p {
            font-size: 1.5rem;
            font-weight: 600;
            margin: 0;
        }
        .chart-section {
            flex-grow: 1;
            padding: 15px;
            background-color: #f1f3f5;
            border-radius: 8px;
            display: flex;
            flex-direction: column;
        }
        .chart-section h5 {
            font-size: 1.2rem;
            font-weight: 500;
            color: #34495E;
            margin-bottom: 15px;
        }
        .chart-container {
            flex-grow: 1;
            max-height: 450px; /* Giới hạn chiều cao biểu đồ */
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="sidebar col-md-2 p-3">
            <h4 class="text-center mb-4">Admin</h4>
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

        <div class="content-area">
            <div class="header">
                <h3>View Revenue</h3>
            </div>

            <!-- Bộ lọc thời gian -->
            <div class="filter-section">
                <div class="d-flex align-items-center">
                    <label for="period">Select Period:</label>
                    <form action="${pageContext.request.contextPath}/view-revenue" method="get">
                        <select name="period" id="period" class="form-select" onchange="this.form.submit()">
                            <option value="hour" <%= "hour".equals(request.getAttribute("period")) ? "selected" : "" %>>Hour</option>
                            <option value="day" <%= "day".equals(request.getAttribute("period")) ? "selected" : "" %>>Day</option>
                            <option value="week" <%= "week".equals(request.getAttribute("period")) ? "selected" : "" %>>Week</option>
                            <option value="month" <%= "month".equals(request.getAttribute("period")) ? "selected" : "" %>>Month</option>
                            <option value="year" <%= "year".equals(request.getAttribute("period")) ? "selected" : "" %>>Year</option>
                        </select>
                    </form>
                </div>
            </div>

            <!-- Tổng doanh thu -->
            <div class="stats-section">
                <div class="row">
                    <div class="col-md-4">
                        <div class="card-stats">
                            <i class="fas fa-dollar-sign"></i>
                            <h5>Total Revenue (<%= request.getAttribute("period") %>)</h5>
                            <p><%= currencyFormat.format(request.getAttribute("totalRevenue")) %></p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Biểu đồ doanh thu -->
            <div class="chart-section">
                <h5>Revenue by <%= request.getAttribute("period") %></h5>
                <div class="chart-container">
                    <canvas id="revenueChart"></canvas>
                </div>
            </div>
        </div>
    </div>

    <!-- Chart.js Script -->
    <script>
        const revenueCtx = document.getElementById('revenueChart').getContext('2d');
        const revenueData = {
            labels: [<% List<Revenue> revenueByPeriod = (List<Revenue>) request.getAttribute("revenueByPeriod");
                        if (revenueByPeriod != null && !revenueByPeriod.isEmpty()) {
                            for (Revenue revenue : revenueByPeriod) { %>
                                '<%= revenue.getRevenueId() %>',
                        <% } } %>],
            datasets: [{
                label: 'Revenue (VNĐ)',
                data: [<% if (revenueByPeriod != null && !revenueByPeriod.isEmpty()) {
                            for (Revenue revenue : revenueByPeriod) { %>
                                <%= revenue.getTotalRevenue() %>,
                        <% } } %>],
                backgroundColor: 'rgba(76, 175, 80, 0.2)',
                borderColor: '#4CAF50',
                borderWidth: 2,
                fill: true
            }]
        };
        const revenueChart = new Chart(revenueCtx, {
            type: 'bar',
            data: revenueData,
            options: {
                responsive: true,
                maintainAspectRatio: false, /* Cho phép biểu đồ co giãn theo container */
                plugins: {
                    legend: { display: true }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        title: { display: true, text: 'Revenue (VNĐ)' }
                    },
                    x: {
                        title: { display: true, text: '<%= request.getAttribute("period") %>' }
                    }
                }
            }
        });
    </script>
</body>
</html>