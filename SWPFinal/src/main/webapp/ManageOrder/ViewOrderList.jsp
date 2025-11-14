<%@page import="java.text.SimpleDateFormat"%>
<%@page import="Model.OrderDetail"%>
<%@page import="DAO.CustomerDAO"%>
<%@page import="DAO.AccountDAO"%>
<%@page import="java.util.ArrayList"%>
<%@page import="Model.Account"%>
<%@page import="DAO.MenuDAO"%>
<%@page import="Model.Dish"%>
<%@page import="java.util.List"%>
<%@page import="Model.Order"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%!
    List<Dish> dishList = null;
%>
<%
    if (session == null || session.getAttribute("account") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    Account account = (Account) session.getAttribute("account");
    String UserRole = account.getUserRole();

    MenuDAO menuDAO = new MenuDAO();
    try {
        dishList = menuDAO.getAllDishes();
    } catch (Exception e) {
        e.printStackTrace();
        dishList = new ArrayList<>();
    }
    request.setAttribute("dishList", dishList);

    AccountDAO accountDAO = new AccountDAO();
    CustomerDAO customerDAO = new CustomerDAO();
    SimpleDateFormat timeFormat = new SimpleDateFormat("dd/MM/yyyy HH:mm");
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Order Management</title>
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
        .content-area h3{
             overflow: hidden;
                background: linear-gradient(to right, #2C3E50, #42A5F5);
                padding: 1rem;
                color: white;
                 margin-left: -24px !important;
                margin-top: -25px !important;
                margin-right: -25px !important;
                padding-bottom: 27px;
                font-size: 24px;
        }
        .error { color: red; }
        .success { color: green; }
        .table {
            width: 100%;
            margin-bottom: 1rem;
            background-color: #fff;
        }
        .table th, .table td {
            padding: 10px;
            vertical-align: middle;
            text-align: left;
            font-size: 0.9rem;
        }
        .table thead th {
            background-color: #343a40;
            color: white;
            border-color: #454d55;
        }
        .table-hover tbody tr:hover {
            background-color: #f1f1f1;
        }
        .table-bordered {
            border: 1px solid #dee2e6;
        }
        .table-bordered th, .table-bordered td {
            border: 1px solid #dee2e6;
        }
        .pagination {
            display: flex;
            justify-content: center;
            gap: 5px;
            margin-top: 15px;
        }
        .pagination button {
            padding: 5px 10px;
            border: 1px solid #ddd;
            background: white;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.9rem;
        }
        .pagination button:disabled {
            background: #f0f0f0;
            cursor: not-allowed;
        }
        .pagination button.active {
            background: #4CAF50;
            color: white;
            border-color: #4CAF50;
        }
        .controls-container {
            display: flex;
            align-items: center;
            gap: 15px;
            margin-bottom: 15px;
        }
        .controls-container form {
            flex: 1;
            display: flex;
            gap: 10px;
        }
    </style>
</head>
<body>
    <div class="d-flex">
        <div class="sidebar col-md-2 p-3">
            <h4 class="text-center mb-4">Admin</h4>
            <ul class="nav flex-column">
                <li class="nav-item"><a href="${pageContext.request.contextPath}/dashboard" class="nav-link"><i class="fas fa-home me-2"></i>Dashboard</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/view-revenue" class="nav-link"><i class="fas fa-chart-line me-2"></i>View Revenue</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/viewalldish" class="nav-link"><i class="fas fa-list-alt me-2"></i>Menu Management</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewAccountList" class="nav-link"><i class="fas fa-users me-2"></i>Employee Management</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewTableList" class="nav-link"><i class="fas fa-building me-2"></i>Table Management</a></li>
                <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewOrderList" class="nav-link active"><i class="fas fa-shopping-cart me-2"></i>Order Management</a></li>
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
        <div class="col-md-10 p-4 content-area">
            <h3>Order Management</h3>
            <% if (request.getSession().getAttribute("message") != null) {%>
            <div class="alert alert-success" id="successMessage">
                <%= request.getSession().getAttribute("message")%>
            </div>
            <% request.getSession().removeAttribute("message"); %>
            <% } %>
            <% if (request.getSession().getAttribute("errorMessage") != null) {%>
            <div class="alert alert-danger" id="errorMessage">
                <%= request.getSession().getAttribute("errorMessage")%>
            </div>
            <% request.getSession().removeAttribute("errorMessage"); %>
            <% } %>

            <div class="controls-container">
                <form id="searchForm" class="row g-3">
                    <div class="col-auto">
                        <input type="text" class="form-control" id="searchInput" placeholder="Enter order ID, username, customer name, or status">
                    </div>
                    <div class="col-auto">
                        <select class="form-select" id="filterStatus" name="filterStatus">
                            <option value="">All Status</option>
                            <option value="Pending">Pending</option>
                            <option value="Completed">Completed</option>
                            <option value="Cancelled">Cancelled</option>
                        </select>
                    </div>
                    <div class="col-auto">
                        <select class="form-select" id="sortOption" name="sortOption">
                            <option value="">Sort</option>
                            <option value="date-asc">Order Date: Oldest to Newest</option>
                            <option value="date-desc">Order Date: Newest to Oldest</option>
                        </select>
                    </div>
                </form>
            </div>

            <div id="orderListContainer">
                <%
                    List<Order> orderList = (List<Order>) request.getAttribute("orderList");
                    if (orderList != null && !orderList.isEmpty()) {
                %>
                <table class="table table-bordered table-hover">
                    <thead class="thead-dark">
                        <tr>
                            <th>No.</th>
                            <th>Order ID</th>
                            <th>Username</th>
                            <th>Customer Name</th>
                            <th>Order Time</th>
                            <th>Order Status</th>
                            <th>Dishes</th>
                        </tr>
                    </thead>
                    <tbody id="orderTableBody">
                        <%
                            int displayIndex = 1;
                            for (Order order : orderList) {
                                String userName = order.getUserId() != null ? accountDAO.getAccountById(order.getUserId()).getUserName() : "N/A";
                                String customerName = order.getCustomerId() != null ? customerDAO.getCustomerById(order.getCustomerId()).getCustomerName() : "N/A";
                        %>
                        <tr>
                            <td><%= displayIndex++ %></td>
                            <td><%= order.getOrderId() %></td>
                            <td><%= userName %></td>
                            <td><%= customerName %></td>
                            <td><%= timeFormat.format(order.getOrderDate()) %></td>
                            <td><%= order.getOrderStatus() %></td>
                            <td>
                                <%
                                    List<OrderDetail> details = order.getOrderDetails();
                                    if (details != null && !details.isEmpty()) {
                                        StringBuilder dishSummary = new StringBuilder();
                                        for (OrderDetail detail : details) {
                                            dishSummary.append(detail.getDishName()).append(" (").append(detail.getQuantity()).append("), ");
                                        }
                                        out.print(dishSummary.substring(0, dishSummary.length() - 2));
                                    } else {
                                        out.print("No dishes");
                                    }
                                %>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <div class="pagination" id="pagination"></div>
                <% } else { %>
                <p class="text-muted">No orders available.</p>
                <% } %>
            </div>
        </div>
    </div>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        $(document).ready(function () {
            const itemsPerPage = 10;
            let currentPage = 1;
            const searchInput = document.getElementById('searchInput');
            const filterStatus = document.getElementById('filterStatus');
            const sortOption = document.getElementById('sortOption');
            const orderTableBody = document.getElementById('orderTableBody');
            const pagination = document.getElementById('pagination');
            const rows = Array.from(orderTableBody.querySelectorAll('tr'));

            function filterAndSortTable() {
                const searchText = searchInput.value.toLowerCase();
                const selectedStatus = filterStatus.value;
                const sortValue = sortOption.value;

                let filteredRows = rows.filter(row => {
                    const orderId = row.cells[1].textContent.toLowerCase();
                    const userName = row.cells[2].textContent.toLowerCase();
                    const customerName = row.cells[3].textContent.toLowerCase();
                    const orderStatus = row.cells[5].textContent;

                    const matchesSearch = orderId.includes(searchText) || userName.includes(searchText) || 
                                        customerName.includes(searchText) || orderStatus.toLowerCase().includes(searchText);
                    const matchesStatus = selectedStatus === '' || orderStatus === selectedStatus;

                    return matchesSearch && matchesStatus;
                });

                if (sortValue) {
                    const [sortField, sortDirection] = sortValue.split('-');
                    if (sortField === 'date') {
                        filteredRows.sort((a, b) => {
                            const dateA = new Date(a.cells[4].textContent.split(' ').reverse().join(' '));
                            const dateB = new Date(b.cells[4].textContent.split(' ').reverse().join(' '));
                            return sortDirection === 'asc' ? dateA - dateB : dateB - dateA;
                        });
                    }
                }

                renderTable(filteredRows);
            }

            function renderTable(filteredRows) {
                const start = (currentPage - 1) * itemsPerPage;
                const end = start + itemsPerPage;
                const paginatedRows = filteredRows.slice(start, end);

                orderTableBody.innerHTML = '';
                paginatedRows.forEach(row => orderTableBody.appendChild(row));

                renderPagination(filteredRows.length);
            }

            function renderPagination(totalItems) {
                const totalPages = Math.ceil(totalItems / itemsPerPage);
                pagination.innerHTML = '';

                const prevButton = document.createElement('button');
                prevButton.textContent = 'Previous';
                prevButton.disabled = currentPage === 1;
                prevButton.onclick = function () {
                    if (currentPage > 1) {
                        currentPage--;
                        filterAndSortTable();
                    }
                };
                pagination.appendChild(prevButton);

                for (let i = 1; i <= totalPages; i++) {
                    const pageButton = document.createElement('button');
                    pageButton.textContent = i;
                    pageButton.className = i === currentPage ? 'active' : '';
                    pageButton.onclick = function () {
                        currentPage = i;
                        filterAndSortTable();
                    };
                    pagination.appendChild(pageButton);
                }

                const nextButton = document.createElement('button');
                nextButton.textContent = 'Next';
                nextButton.disabled = currentPage === totalPages;
                nextButton.onclick = function () {
                    if (currentPage < totalPages) {
                        currentPage++;
                        filterAndSortTable();
                    }
                };
                pagination.appendChild(nextButton);
            }

            filterAndSortTable();

            searchInput.addEventListener('keyup', filterAndSortTable);
            filterStatus.addEventListener('change', filterAndSortTable);
            sortOption.addEventListener('change', filterAndSortTable);

            setTimeout(function() {
                $('#successMessage').fadeOut('slow');
                $('#errorMessage').fadeOut('slow');
            }, 10000);
        });
    </script>
</body>
</html>