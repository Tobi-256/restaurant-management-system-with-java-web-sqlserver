<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="Model.Account" %>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Account Profile</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f8f9fa;
                margin: 0;
                padding: 0;
                overflow-x: hidden; /* Ngăn cuộn ngang */
            }

            /* Sidebar */
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

            .i {
                font-size: 2rem;
            }
            /*sidebar admin*/
            .sidebar-admin {
                background: linear-gradient(to bottom, #2C3E50, #34495E);
                color: white;
                height: 100vh;
                position: sticky; /* Keep sidebar fixed */
                top: 0;
                position: fixed;
                width: 16.67%;
            }

            .sidebar-admin a {
                color: white;
                text-decoration: none;
            }

            .sidebar-admin a:hover {
                background-color: #1A252F;
            }

            .sidebar-admin .nav-link {
                font-size: 0.9rem;
            }

            .sidebar-admin h4 {
                font-size: 1.5rem;
            }


            /* Nội dung chính */
            .content {
                margin-left: 16.67%; /* Đảm bảo không đè lên sidebar */
                padding: 20px;
                width: 83.33%; /* Chiếm phần còn lại của màn hình */
                min-height: 100vh;
                box-sizing: border-box;
            }

            .profile-container {
                max-width: 100%; /* Đảm bảo không vượt quá phần content */
                background: white;
                border-radius: 10px;
                box-shadow: 0 0 20px rgba(0,0,0,0.1);
                padding: 20px;
            }

            .profile-title {
                color: #2C3E50;
                font-weight: 700;
                margin-bottom: 20px;
                border-bottom: 2px solid #007bff;
                padding-bottom: 10px;
                text-align: center;
            }

            .profile-grid {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); /* Cột linh hoạt */
                gap: 15px;
            }

            .profile-item {
                display: flex;
                padding: 10px 0;
                border-bottom: 1px solid #eee;
            }

            .profile-label {
                width: 40%;
                font-weight: 600;
                color: #34495E;
            }

            .profile-value {
                width: 60%;
                color: #555;
            }

            .profile-img {
                max-width: 200px;
                height: auto;
                border-radius: 2%;
                border: 2px solid #007bff;
            }

            .btn-custom {
                padding: 8px 25px;
                border-radius: 20px;
                background: #007bff;
                border: none;
                transition: all 0.3s ease;
            }

            .btn-custom:hover {
                background: #0056b3;
                transform: translateY(-2px);
                box-shadow: 0 5px 15px rgba(0,123,255,0.4);
            }

            /* Responsive */
            @media (max-width: 768px) {
                .profile-grid {
                    grid-template-columns: 1fr; /* Một cột trên màn hình nhỏ */
                }
                .content {
                    margin-left: 0;
                    width: 100%;
                }
            }
        </style>
    </head>
    <body>
        <%
            Account account = (Account) request.getAttribute("account");
            if (account == null) {
                out.println("<p class='text-center text-danger mt-5'>No account information available.</p>");
            } else {
                String userRole = account.getUserRole();
        %>
        <div class="d-flex">
            <!-- Sidebar giữ nguyên -->
            <% if ("Waiter".equals(userRole)) { %>
            <div class="sidebar">
                <h4>Waiter </h4>
                <ul class="nav flex-column">
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/order?action=listTables" class="nav-link ">
                            <i class="fas fa-building"></i> Table List
                        </a>
                    </li>

                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/view-notifications" class="nav-link">
                            <i class="fas fa-bell"></i> View Notifications
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/viewAccountDetail" class="nav-link active">
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
            <% } else if ("Kitchen staff".equals(userRole)) { %>
            <div class="sidebar">
                <h4>Kitchen </h4>
                <ul class="nav flex-column">
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/kitchen" class="nav-link">
                            <i class="fas fa-list"></i> Order List
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/view-notifications" class="nav-link">
                            <i class="fas fa-bell"></i> View Notifications
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/viewAccountDetail" class="nav-link active">
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
            <% } else if ("Cashier".equals(userRole)) { %>
            <div class="sidebar">
                <h4>Cashier</h4>
                <ul class="nav flex-column">
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/payment?action=listOrders" class="nav-link">
                            <i class="fas fa-money-bill"></i> Payment
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/view-notifications" class="nav-link">
                            <i class="fas fa-bell"></i> View Notifications
                        </a>
                    </li>
                    <li class="nav-item">
                        <a href="${pageContext.request.contextPath}/viewAccountDetail" class="nav-link active">
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
            <% } else if ("Admin".equals(userRole)) {%>
            <div class="sidebar-admin col-md-2 p-3">
                <h4 class="text-center mb-4"><%= userRole%></h4>
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
                        <% if ("Admin".equals(userRole) || "Manager".equals(userRole)) { %>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/create-notification" class="nav-link"><i class="fas fa-plus me-2"></i>Create Notification</a></li>
                        <% } %>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/logout" class="nav-link"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                </ul>
            </div>
            <% }%>

            <!-- Main Content -->
            <div class="content">
                <div class="profile-container">
                    <h1 class="profile-title">Account Profile</h1>
                    <div class="profile-grid">
                        <div class="profile-item">
                            <div class="profile-label">User ID</div>
                            <div class="profile-value"><%= account.getUserId()%></div>
                        </div>
                        <div class="profile-item">
                            <div class="profile-label">Email</div>
                            <div class="profile-value"><%= account.getUserEmail()%></div>
                        </div>
                        <div class="profile-item">
                            <div class="profile-label">Phone</div>
                            <div class="profile-value"><%= account.getUserPhone() != null ? account.getUserPhone() : "N/A"%></div>
                        </div>
                        <div class="profile-item">
                            <div class="profile-label">Name</div>
                            <div class="profile-value"><%= account.getUserName()%></div>
                        </div>
                        <div class="profile-item">
                            <div class="profile-label">Role</div>
                            <div class="profile-value"><%= account.getUserRole()%></div>
                        </div>
                        <div class="profile-item">
                            <div class="profile-label">Identity Card</div>
                            <div class="profile-value"><%= account.getIdentityCard() != null ? account.getIdentityCard() : "N/A"%></div>
                        </div>
                        <div class="profile-item">
                            <div class="profile-label">Address</div>
                            <div class="profile-value"><%= account.getUserAddress() != null ? account.getUserAddress() : "N/A"%></div>
                        </div>
                        <div class="profile-item">
                            <div class="profile-label">Image</div>
                            <div class="profile-value">
                                <%
                                    String userImage = account.getUserImage();
                                    if (userImage != null && !userImage.isEmpty()) {
                                        String imagePath = request.getContextPath() + "/ManageAccount/account_img/" + userImage;
                                        out.println("<img src='" + imagePath + "' alt='User Image' class='profile-img'>");
                                    } else {
                                        out.println("N/A");
                                    }
                                %>
                            </div>
                        </div>
                        <div class="profile-item">
                            <div class="profile-label">Status</div>
                            <div class="profile-value">
                                <span class="badge <%= account.isIsDeleted() ? "bg-danger" : "bg-success"%>">
                                    <%= account.isIsDeleted() ? "Deleted" : "Active"%>
                                </span>
                            </div>
                        </div>
                    </div>
                    <div class="text-center mt-4">
                        <a href="javascript:history.back()" class="btn btn-custom text-white">Back</a>
                    </div>
                </div>
            </div>
        </div>
        <%
            }
        %>
    </body>
</html>