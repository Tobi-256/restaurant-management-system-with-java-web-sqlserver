<%@page import="Model.Dish"%>
<%@page import="Model.DishInventory"%>
<%@page import="Model.InventoryItem"%>
<%@page import="Model.Account"%>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("account") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    Account account = (Account) session.getAttribute("account");
    String UserRole = account.getUserRole();

    Dish dish = (Dish) request.getAttribute("dish");
    List<DishInventory> dishIngredients = (List<DishInventory>) request.getAttribute("dishIngredients");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Dish Detail</title>
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
            .content-area {
                padding: 20px;
            }
            .error {
                color: red;
            }
            .success {
                color: green;
            }
            .detail-group {
                margin-bottom: 15px;
                display: flex;
                align-items: center;
            }
            .detail-group label {
                font-weight: bold;
                margin-right: 10px;
                width: 150px;
                flex-shrink: 0;
            }
            img {
                max-width: 200px;
                margin-top: 10px;
            }
            .ingredient-list {
                max-height: 500px;
                overflow-y: auto;
                background-color: #fff;
                padding: 10px;
                border: 1px solid #ddd;
                border-radius: 5px;
            }
            .ingredient-item {
                margin-bottom: 10px;
            }
        </style>
    </head>
    <body>
        <div class="d-flex">
            <!-- Sidebar -->
            <div class="sidebar col-md-2 p-3">
                <h4 class="text-center mb-4">Admin</h4>
                <ul class="nav flex-column">
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/dashboard" class="nav-link"><i class="fas fa-home me-2"></i>Dashboard</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/view-revenue" class="nav-link"><i class="fas fa-chart-line me-2"></i>View Revenue</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/viewalldish" class="nav-link"><i class="fas fa-list-alt me-2"></i>Menu Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/addnewdish" class="nav-link"><i class="fas fa-plus me-2"></i>Add New Dish</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewAccountList" class="nav-link"><i class="fas fa-users me-2"></i>Employee Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewTableList" class="nav-link"><i class="fas fa-building me-2"></i>Table Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewOrderList" class="nav-link"><i class="fas fa-shopping-cart me-2"></i>Order Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewCustomerList" class="nav-link"><i class="fas fa-user-friends me-2"></i>Customer Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewCouponController" class="nav-link"><i class="fas fa-tag me-2"></i>Coupon Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewInventoryController" class="nav-link"><i class="fas fa-boxes me-2"></i>Inventory Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/view-notifications" class="nav-link"><i class="fas fa-bell me-2"></i>View Notifications</a></li>
                        <% if ("Admin".equals(UserRole) || "Manager".equals(UserRole)) { %>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/create-notification" class="nav-link"><i class="fas fa-plus me-2"></i>Create Notification</a></li>
                        <% } %>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/logout" class="nav-link"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                </ul>
            </div>

            <!-- Main Content -->
            <div class="col-md-10 p-4 content-area">
                <h3>Dish Detail</h3>
                <% if (dish != null) {%>
                <div class="row">
                    <!-- Left Column: Dish Details -->
                    <div class="col-md-6">
                        <div class="detail-group">
                            <label>Dish Name:</label>
                            <span><%= dish.getDishName()%></span>
                        </div>
                        <div class="detail-group">
                            <label>Dish Type:</label>
                            <span><%= dish.getDishType()%></span>
                        </div>
                        <div class="detail-group">
                            <label>Price:</label>
                            <span><%= dish.getDishPrice()%> VNĐ</span>
                        </div>
                        <div class="detail-group">
                            <label>Description:</label>
                            <span><%= dish.getDishDescription() != null ? dish.getDishDescription() : "No description"%></span>
                        </div>

                        <div class="detail-group">
                            <label>Status:</label>
                            <span><%= dish.getDishStatus()%></span>
                        </div>
                        <div class="detail-group">
                            <label>Ingredient Status:</label>
                            <span><%= dish.getIngredientStatus()%></span>
                        </div>
                        <!-- ... Phần đầu giữ nguyên ... -->
                        <div class="detail-group">
    <label>Image:</label>
    <div>
        <img src="<%= dish != null && dish.getDishImage() != null ? request.getContextPath() + dish.getDishImage() : "" %>" alt="Dish Image">
    </div>
</div>                        <!-- ... Phần còn lại giữ nguyên ... -->
                        <div class="mt-3">
                            <a href="${pageContext.request.contextPath}/viewalldish" class="btn btn-secondary">Back to Menu</a>
                        </div>
                    </div>

                    <!-- Right Column: Ingredients -->
                    <div class="col-md-6">
                        <h4>Ingredients</h4>
                        <div class="ingredient-list">
                            <%
                                if (dishIngredients != null && !dishIngredients.isEmpty()) {
                                    for (DishInventory ingredient : dishIngredients) {
                                        InventoryItem item = new DAO.MenuDAO().getInventoryItemById(ingredient.getItemId());
                            %>
                            <div class="ingredient-item">
                                <span><%= item.getItemName()%>: <%= ingredient.getQuantityUsed()%> <%= item.getItemUnit()%></span>
                            </div>
                            <%
                                }
                            } else {
                            %>
                            <p class="error">No ingredients found for this dish.</p>
                            <%
                                }
                            %>
                        </div>
                    </div>
                </div>
                <% } else { %>
                <p class="error">Dish not found.</p>
                <a href="${pageContext.request.contextPath}/viewalldish" class="btn btn-secondary">Back to Menu</a>
                <% }%>
            </div>
        </div>
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>