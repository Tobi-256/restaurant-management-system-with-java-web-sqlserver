<%@ page import="Model.Account" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("account") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    Account account = (Account) session.getAttribute("account");
    String userRole = account.getUserRole();

    if (!"Admin".equals(userRole) && !"Manager".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/view-notifications");
        return;
    }
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Create Notification</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
                font-family: 'Roboto', sans-serif;
                background-color: #f8f9fa;
            }
            .sidebar {
                background: linear-gradient(to bottom, #2C3E50, #34495E);
                color: white;
                height: 100vh;
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
    <div class="col-md-10 p-4">
        <h3>Create Notification</h3>
        <% 
            String message = (String) session.getAttribute("message");
            String errorMessage = (String) session.getAttribute("errorMessage");
            if (message != null) {
        %>
        <div class="alert alert-success"><%= message %></div>
        <% session.removeAttribute("message"); %>
        <% } if (errorMessage != null) { %>
        <div class="alert alert-danger"><%= errorMessage %></div>
        <% session.removeAttribute("errorMessage"); %>
        <% } %>

        <form action="${pageContext.request.contextPath}/create-notification" method="post">
            <div class="mb-3">
                <label for="notificationType" class="form-label">Send to:</label>
                <select class="form-select" id="notificationType" name="notificationType" onchange="toggleOptions(this)">
                    <option value="all">All Users</option>
                    <option value="role">Specific Role</option>
                    <option value="individual">Specific User</option>
                </select>
            </div>
            <div class="mb-3" id="roleOption" style="display:none;">
                <label for="role" class="form-label">Select Role:</label>
                <select class="form-select" id="role" name="role">
                    <% if ("Admin".equals(userRole)) { %>
                    <option value="Manager">Manager</option>
                    <% } %>
                    <option value="Cashier">Cashier</option>
                    <option value="Waiter">Waiter</option>
                    <option value="kitchen staff">Kitchen staff</option>
                </select>
            </div>
            <div class="mb-3" id="userOption" style="display:none;">
                <label for="UserId" class="form-label">Select User:</label>
                <select class="form-select" id="UserId" name="UserId">
                    <% List<Model.Account> accounts = (List<Model.Account>) request.getAttribute("accounts");
                       if (accounts != null) {
                           for (Model.Account acc : accounts) { %>
                    <option value="<%= acc.getUserId() %>"><%= acc.getUserName() %> (<%= acc.getUserRole() %>)</option>
                    <% } } %>
                </select>
            </div>
            <div class="mb-3">
                <label for="content" class="form-label">Content:</label>
                <textarea class="form-control" id="content" name="content" rows="3" required></textarea>
            </div>
            <button type="submit" class="btn btn-primary">Create Notification</button>
        </form>
    </div>
</div>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function toggleOptions(select) {
        document.getElementById("roleOption").style.display = select.value === "role" ? "block" : "none";
        document.getElementById("userOption").style.display = select.value === "individual" ? "block" : "none";
    }
</script>
</body>
</html>