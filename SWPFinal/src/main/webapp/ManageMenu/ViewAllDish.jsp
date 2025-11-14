<%@page import="Model.InventoryItem"%>
<%@page import="Model.Account"%>
<%@ page import="Model.Dish" %>
<%@ page import="Model.DishInventory" %>
<%@ page import="Model.InventoryItem" %>
<%@ page import="java.util.List" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    if (session == null || session.getAttribute("account") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    Account account = (Account) session.getAttribute("account");
    String UserRole = account.getUserRole();
%>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Menu Management</title>
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
     
        .error {
            color: red;
        }
        .success {
            color: green;
        }
        .table {
            width: 100%;
            margin-bottom: 1rem;
            background-color: #fff;
        }
        .table th,
        .table td {
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
        .table-bordered th,
        .table-bordered td {
            border: 1px solid #dee2e6;
        }
        .table th.actions-column,
        .table td.actions-column {
            width: 200px;
            white-space: nowrap;
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
        .controls-container .btn {
            margin: 0;
        }
        .controls-container form {
            flex: 1;
            display: flex;
            gap: 10px;
        }
        /* Phối màu cho các nút trong cột Actions */
        .btn-edit {
            background-color: #f0ad4e; /* Màu vàng cam */
            border-color: #f0ad4e;
            color: white;
            padding: 5px 10px;
            font-size: 0.85rem;
            transition: background-color 0.3s;
        }
        .btn-edit:hover {
            background-color: #ec971f; /* Tối hơn khi hover */
            border-color: #ec971f;
            color: white;
        }
        .btn-delete {
            background-color: #dc3545; /* Màu đỏ */
            border-color: #dc3545;
            color: white;
            padding: 5px 10px;
            font-size: 0.85rem;
            transition: background-color 0.3s;
        }
        .btn-delete:hover {
            background-color: #c82333; /* Tối hơn khi hover */
            border-color: #c82333;
            color: white;
        }
        .btn-detail {
            background-color: #17a2b8; /* Màu xanh dương */
            border-color: #17a2b8;
            color: white;
            padding: 5px 10px;
            font-size: 0.85rem;
            transition: background-color 0.3s;
        }
        .btn-detail:hover {
            background-color: #138496; /* Tối hơn khi hover */
            border-color: #138496;
            color: white;
        }
           .content-title { /* Replaced content-header for title only */
                overflow: hidden;
                background: linear-gradient(to right, #2C3E50, #42A5F5);
                padding: 1rem;
                color: white;
                margin-bottom: 20px;
                margin-left: -25px; /* Extend to edge */
                margin-right: -20px; /* Extend to edge */
                margin-top: -24px; /* Extend to edge */
                border-radius: 0; /* Remove rounding if needed */
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
        <div class="col-md-10 p-4 content-area">
               <div class="content-title">
                    <h4>Menu Management</h4>
                </div>
            
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

            <!-- Controls Container -->
            <div class="controls-container">
                <a href="${pageContext.request.contextPath}/addnewdish" class="btn btn-primary">
                    <i class="fas fa-plus me-2"></i>Add New Dish
                </a>
                <!-- Filter and Sort Form -->
                <form id="searchForm" class="row g-3">
                    <div class="col-auto">
                        <input type="text" class="form-control" id="searchKeyword" name="searchKeyword" placeholder="Enter dish name">
                    </div>
                    <div class="col-auto">
                        <select class="form-select" id="filterStatus" name="filterStatus">
                            <option value="">All Status</option>
                            <option value="Available">Available</option>
                            <option value="Unavailable">Unavailable</option>
                        </select>
                    </div>
                    <div class="col-auto">
                        <select class="form-select" id="filterIngredientStatus" name="filterIngredientStatus">
                            <option value="">All Ingredients</option>
                            <option value="Sufficient">Sufficient</option>
                            <option value="Insufficient">Insufficient</option>
                        </select>
                    </div>
                    <div class="col-auto">
                        <select class="form-select" id="filterDishType" name="filterDishType">
                            <option value="">All Types</option>
                            <option value="Food">Food</option>
                            <option value="Drink">Drink</option>
                        </select>
                    </div>
                    <div class="col-auto">
                        <select class="form-select" id="sortOption" name="sortOption">
                            <option value="">Sort</option>
                            <option value="price-asc">Price: Low to High</option>
                            <option value="price-desc">Price: High to Low</option>
                            <option value="name-asc">Name: A-Z</option>
                            <option value="name-desc">Name: Z-A</option>
                        </select>
                    </div>
                </form>
            </div>

            <div id="dishListContainer">
                <%
                    List<Dish> dishList = (List<Dish>) request.getAttribute("dishList");
                    if (dishList != null && !dishList.isEmpty()) {
                %>
                <table class="table table-bordered table-hover">
                    <thead class="thead-dark">
                        <tr>
                            <th>Dish Name</th>
                            <th>Price</th>
                            <th>Status</th>
                            <th>Ingredients</th>
                            <th class="actions-column">Actions</th>
                        </tr>
                    </thead>
                    <tbody id="dishTableBody">
                        <% for (Dish dish : dishList) { %>
                        <tr data-dish-type="<%= dish.getDishType() %>">
                            <td><%= dish.getDishName() %></td>
                            <td><%= dish.getDishPrice() %> VNĐ</td>
                            <td><%= dish.getDishStatus() %></td>
                            <td><%= dish.getIngredientStatus() %></td>
                            <td class="actions-column">
                                <a href="${pageContext.request.contextPath}/updatedish?dishId=<%= dish.getDishId() %>" class="btn btn-edit">Edit</a>
                                <form action="deletedish" method="post" style="display:inline;" onsubmit="return confirmDelete();">
                                    <input type="hidden" name="dishId" value="<%= dish.getDishId() %>">
                                    <button type="submit" class="btn btn-delete">Delete</button>
                                </form>
                                <a href="${pageContext.request.contextPath}/dishdetail?dishId=<%= dish.getDishId() %>" class="btn btn-detail">Detail</a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
                <div class="pagination" id="pagination"></div>
                <% } else { %>
                <p class="text-muted">No dishes available.</p>
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
            const searchKeyword = document.getElementById('searchKeyword');
            const filterStatus = document.getElementById('filterStatus');
            const filterIngredientStatus = document.getElementById('filterIngredientStatus');
            const filterDishType = document.getElementById('filterDishType');
            const sortOption = document.getElementById('sortOption');
            const dishTableBody = document.getElementById('dishTableBody');
            const pagination = document.getElementById('pagination');
            const rows = Array.from(dishTableBody.querySelectorAll('tr'));

            function filterAndSortTable() {
                const searchText = searchKeyword.value.toLowerCase();
                const selectedStatus = filterStatus.value;
                const selectedIngredientStatus = filterIngredientStatus.value;
                const selectedDishType = filterDishType.value;
                const sortValue = sortOption.value;

                let filteredRows = rows.filter(row => {
                    const dishName = row.cells[0].textContent.toLowerCase();
                    const status = row.cells[2].textContent;
                    const ingredientStatus = row.cells[3].textContent;
                    const dishType = row.getAttribute('data-dish-type');

                    const matchesSearch = dishName.includes(searchText);
                    const matchesStatus = selectedStatus === '' || status.includes(selectedStatus);
                    const matchesIngredientStatus = selectedIngredientStatus === '' || ingredientStatus.includes(selectedIngredientStatus);
                    const matchesDishType = selectedDishType === '' || dishType === selectedDishType;

                    return matchesSearch && matchesStatus && matchesIngredientStatus && matchesDishType;
                });

                if (sortValue) {
                    const [sortField, sortDirection] = sortValue.split('-');
                    if (sortField === 'price') {
                        filteredRows.sort((a, b) => {
                            const priceA = parseFloat(a.cells[1].textContent);
                            const priceB = parseFloat(b.cells[1].textContent);
                            return sortDirection === 'asc' ? priceA - priceB : priceB - priceA;
                        });
                    } else if (sortField === 'name') {
                        filteredRows.sort((a, b) => {
                            const nameA = a.cells[0].textContent.toLowerCase();
                            const nameB = b.cells[0].textContent.toLowerCase();
                            return sortDirection === 'asc' ? nameA.localeCompare(nameB) : nameB.localeCompare(nameA);
                        });
                    }
                }

                renderTable(filteredRows);
            }

            function renderTable(filteredRows) {
                const start = (currentPage - 1) * itemsPerPage;
                const end = start + itemsPerPage;
                const paginatedRows = filteredRows.slice(start, end);

                dishTableBody.innerHTML = '';
                paginatedRows.forEach(row => dishTableBody.appendChild(row));

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

            searchKeyword.addEventListener('keyup', filterAndSortTable);
            filterStatus.addEventListener('change', filterAndSortTable);
            filterIngredientStatus.addEventListener('change', filterAndSortTable);
            filterDishType.addEventListener('change', filterAndSortTable);
            sortOption.addEventListener('change', filterAndSortTable);

            setTimeout(function() {
                $('#successMessage').fadeOut('slow');
                $('#errorMessage').fadeOut('slow');
            }, 10000);
        });

        function confirmDelete() {
            return confirm("Are you sure you want to delete this dish?");
        }
    </script>
</body>
</html>
