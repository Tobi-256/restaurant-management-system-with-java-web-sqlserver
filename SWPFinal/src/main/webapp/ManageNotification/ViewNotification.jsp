<%@ page import="Model.Notification" %>
<%@ page import="Model.Account" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
    // Declare canDelete as a page-level variable
    private boolean canDelete(String userRole) {
        return "Admin".equals(userRole) || "Manager".equals(userRole);
    }
%>
<%
    if (session == null || session.getAttribute("account") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    Account account = (Account) session.getAttribute("account");
    String UserRole = account.getUserRole();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Notifications</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
           body {
                font-family: 'Roboto', sans-serif;
                background-color: #f8f9fa;
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

        .content-area {
            margin-left: 250px;
            padding: 20px;
            min-height: 100vh;
            background-color: #f8f9fa;
        }
        /* side admin*/
         .sidebar-admin {
                background: linear-gradient(to bottom, #2C3E50, #34495E);
                color: white;
                height: 100vh;
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
            .sidebar-admin h4 {
                font-size: 1.5rem;
            }
            .sidebar-admin .nav-link {
                font-size: 0.9rem;
            }

        .notification-list {
            list-style: none;
            padding: 0;
        }

        .notification-item {
            border: 1px solid #ddd;
            border-radius: 5px;
            margin-bottom: 10px;
            padding: 15px;
            background-color: #fff;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }

        .notification-checkbox, #selectAll, #deleteSelectedBtn {
            display: none;
        }

        .notification-content p {
            margin: 5px 0;
        }

        .notification-content strong {
            color: #343a40;
        }

        .notification-content small {
            color: #6c757d;
        }

        @media (max-width: 768px) {
            .sidebar {
                width: 200px;
            }
            .content-area {
                margin-left: 200px;
            }
        }

        @media (max-width: 576px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }
            .content-area {
                margin-left: 0;
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
                    <a href="${pageContext.request.contextPath}/order?action=listTables" class="nav-link">
                        <i class="fas fa-building"></i> Table List
                    </a>
                </li>
                
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/view-notifications" class="nav-link active">
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
        <% } else if ("Kitchen staff".equals(UserRole)) { %>
        <div class="sidebar">
            <h4>Kitchen</h4>
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/kitchen" class="nav-link">
                        <i class="fas fa-list"></i> Order List
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/view-notifications" class="nav-link active">
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
        <% } else if ("Cashier".equals(UserRole)) { %>
        <div class="sidebar">
            <h4>Cashier </h4>
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/payment?action=listOrders" class="nav-link">
                        <i class="fas fa-money-bill"></i> Payment
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/view-notifications" class="nav-link active">
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
        <% } else { %>
        <div class="sidebar-admin col-md-2 p-3">
            <h4 class="text-center mb-4"><%= UserRole %></h4>
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
                <li class="nav-item"><a href="${pageContext.request.contextPath}/view-notifications" class="nav-link active"><i class="fas fa-bell me-2"></i>View Notifications</a></li>
                <% if ("Admin".equals(UserRole) || "Manager".equals(UserRole)) { %>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/create-notification" class="nav-link"><i class="fas fa-plus me-2"></i>Create Notification</a></li>
                <% } %>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/logout" class="nav-link"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
            </ul>
        </div>
        <% } %>

        <!-- Main Content -->
        <div class="content-area col-md-10 p-4">
            <h3>Your Notifications</h3>
            <%
                String message = (String) session.getAttribute("message");
                String errorMessage = (String) session.getAttribute("errorMessage");
                if (message != null) {
            %>
            <div class="alert alert-success"><%= message %></div>
            <% session.removeAttribute("message"); %>
            <% }
                if (errorMessage != null) { %>
            <div class="alert alert-danger"><%= errorMessage %></div>
            <% session.removeAttribute("errorMessage"); %>
            <% } %>

            <% if (canDelete(UserRole)) { %>
            <form action="${pageContext.request.contextPath}/DeleteNotification" method="post" id="deleteForm">
                <button type="button" class="btn btn-danger btn-sm mt-2" id="enableDeleteBtn">
                    <i class="fas fa-trash me-1"></i> Enable Delete
                </button>
                <div class="select-all-container" style="display: none;" id="selectControls">
                    <div class="form-check">
                        <input type="checkbox" class="form-check-input" id="selectAll">
                        <label class="form-check-label" for="selectAll">Select All</label>
                    </div>
                    <button type="submit" class="btn btn-danger btn-sm mt-2" id="deleteSelectedBtn"
                            onclick="return confirm('Are you sure you want to delete the selected notifications?')">
                        <i class="fas fa-trash me-1"></i> Delete Selected
                    </button>
                </div>
            <% } %>

            <ul class="notification-list">
                <%
                    List<Notification> notifications = (List<Notification>) request.getAttribute("notifications");
                    if (notifications != null && !notifications.isEmpty()) {
                        for (Notification notification : notifications) {
                %>
                <li class="notification-item">
                    <div class="form-check" style="display: none;">
                        <input type="checkbox" class="form-check-input notification-checkbox"
                               name="notificationIds" value="<%= notification.getNotificationId() %>">
                    </div>
                    <div class="notification-content">
                        <p><strong><%= notification.getNotificationContent() %></strong></p>
                        <p><small>Created at: <%= new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(notification.getNotificationCreateAt()) %></small></p>
                        <% if (notification.getUserId() != null && notification.getUserName() != null) { %>
                        <p><small>For: <%= notification.getUserName() %> (<%= notification.getUserId() %>)</small></p>
                        <% } else if (notification.getUserRole() != null) { %>
                        <p><small>For Role: <%= notification.getUserRole() %></small></p>
                        <% } else { %>
                        <p><small>For: All Users</small></p>
                        <% } %>
                    </div>
                </li>
                <%
                    } // End for loop
                } else {
                %>
                <p>No notifications available.</p>
                <% } %>
            </ul>
            <% if (canDelete(UserRole)) { %>
            </form>
            <% } %>
        </div>
    </div>

    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        $(document).ready(function () {
            // Show/hide checkboxes and delete buttons
            $('#enableDeleteBtn').click(function () {
                $('.notification-checkbox').show();
                $('#selectAll').show();
                $('#deleteSelectedBtn').show();
                $(this).hide(); // Hide Enable Delete button
                $('.form-check').show();
                $('#selectControls').show();
            });

            // Handle Select All checkbox
            $('#selectAll').click(function () {
                $('.notification-checkbox').prop('checked', this.checked);
            });

            // Handle individual checkbox changes
            $('.notification-checkbox').change(function () {
                var allChecked = true;
                $('.notification-checkbox').each(function () {
                    if (!this.checked) {
                        allChecked = false;
                        return false; // Exit the loop early if one is unchecked
                    }
                });
                $('#selectAll').prop('checked', allChecked);
            });

            // Prevent form submission if no checkboxes are selected
            $('#deleteForm').submit(function (e) {
                if ($('.notification-checkbox:checked').length === 0) {
                    alert('Please select at least one notification to delete.');
                    e.preventDefault();
                }
            });
        });
    </script>
</body>
</html>