<%@page import="java.util.List"%>
<%@page import="Model.Table"%>
<%@page import="DAO.TableDAO"%>
<%@page import="Model.Account"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    if (session == null || session.getAttribute("account") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    Account account = (Account) session.getAttribute("account");
    String UserRole = account.getUserRole();

    List<Integer> floorNumbers = (List<Integer>) request.getAttribute("floorNumberList");
    List<Table> allTables = (List<Table>) request.getAttribute("tableList");

    int pageSize = 20;
    int totalTables = (allTables != null) ? allTables.size() : 0;
    int totalPages = (totalTables == 0) ? 1 : (int) Math.ceil((double) totalTables / pageSize);
    int currentPage = 1;

    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) {
                currentPage = 1;
            }
            if (currentPage > totalPages) {
                currentPage = totalPages;
            }
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }

    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, totalTables);
    List<Table> tables = (allTables != null && startIndex < totalTables) ? allTables.subList(startIndex, endIndex) : List.of();
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Table Management - Admin Dashboard</title>

        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

        <!-- Bootstrap 5 CSS -->
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

        <!-- Font Awesome -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" integrity="sha512-9usAa10IRO0HhonpyAIVpjrylPvoDwiPUiKdWk5t3PyolY1cOd4DSE0Ga+ri4AuTroPR5aQvXU9xC6qOPnzFeg==" crossorigin="anonymous" referrerpolicy="no-referrer" />

        <!-- SweetAlert2 -->
        <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

        <style>
            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f8f9fa;
            }

            .sidebar {
                background: linear-gradient(to bottom, #2C3E50, #34495E);
                color: white;
                height: 100vh;
                position: sticky;
                top: 0;
                overflow-y: auto;
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

            .main-content-area {
                padding: 20px;
                 margin-left: 16.67%;
            }

            .content-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 20px;
                flex-wrap: nowrap;
            }

            .search-filter {
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .search-bar input {
                padding: 8px 12px;
                border: 1px solid #ccc;
                border-radius: 3px;
                width: 250px;
            }

            .filter-bar select {
                padding: 8px 12px;
                border: 1px solid #ccc;
                border-radius: 3px;
                width: 150px;
            }

            .header-buttons .btn-info {
                background-color: #007bff;
                color: white;
                border: none;
                padding: 8px 15px;
                border-radius: 5px;
                cursor: pointer;
            }

            .header-buttons .btn-info:hover {
                background-color: #0056b3;
            }

            .table-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
                gap: 15px;
                margin-bottom: 20px;
            }

            .table-item {
                border: 1px solid #ddd;
                padding: 15px;
                border-radius: 5px;
                background-color: white;
                display: flex;
                flex-direction: column;
                justify-content: space-between;
                min-height: 120px;
                position: relative;
                box-shadow: 0 1px 3px rgba(0,0,0,0.1);
                transition: transform 0.2s ease-in-out;
            }

            .table-item:hover {
                transform: translateY(-3px);
            }

            .table-item.available {
                border-left: 5px solid #28a745;
                background-color: #f8f9fa;
            }

            .table-item.occupied {
                border-left: 5px solid #ffc107;
                background-color: #fff9e6;
            }

            .table-item.reserved {
                border-left: 5px solid #0dcaf0;
                background-color: #e7f8fc;
            }

            .table-info {
                text-align: left;
                margin-bottom: 10px;
                font-size: 0.9rem;
            }

            .table-info div {
                margin-bottom: 3px;
            }

            .table-id, .table-floor {
                font-weight: bold;
                color: #343a40;
            }

            .table-status span {
                font-weight: bold;
                padding: 2px 6px;
                border-radius: 3px;
                font-size: 0.85rem;
            }

            .table-item.available .table-status span {
                background-color: #28a745;
                color: white;
            }

            .table-item.occupied .table-status span {
                background-color: #ffc107;
                color: #333;
            }

            .table-item.reserved .table-status span {
                background-color: #0dcaf0;
                color: white;
            }

            .table-buttons {
                position: absolute;
                top: 10px;
                right: 10px;
                display: flex;
                gap: 5px;
            }

            .table-buttons a {
                padding: 5px;
                border: none;
                text-decoration: none;
                border-radius: 50%;
                width: 30px;
                height: 30px;
                display: flex;
                align-items: center;
                justify-content: center;
                color: white;
                transition: background-color 0.2s ease;
            }

            .table-buttons a.btn-edit-table {
                background-color: #0d6efd;
            }

            .table-buttons a.btn-edit-table:hover {
                background-color: #0b5ed7;
            }

            .table-buttons a.btn-delete-table {
                background-color: #dc3545;
            }

            .table-buttons a.btn-delete-table:hover {
                background-color: #c82333;
            }

            .table-buttons a i {
                font-size: 14px;
                margin: 0;
            }

            .no-data {
                grid-column: 1 / -1;
                text-align: center;
                padding: 40px;
                color: #6c757d;
                background-color: #f8f9fa;
                border: 1px dashed #dee2e6;
                border-radius: 5px;
            }

            .no-data i {
                font-size: 2.5em;
                display: block;
                margin-bottom: 15px;
            }

            .no-data a {
                color: #0d6efd;
                text-decoration: underline;
                cursor: pointer;
            }

            .text-left.mb-4 {
                overflow: hidden;
                background: linear-gradient(to right, #2C3E50, #42A5F5);
                padding: 1rem;
                color: white;
                margin-left: -24px !important;
                margin-top: -25px !important;
                margin-right: -25px !important;
            }

            .modal-header {
                background-color: #f7f7f0;
            }

            .modal-form-container input[type="text"],
            .modal-form-container input[type="number"],
            .modal-form-container select {
                width: calc(100% - 22px);
                padding: 10px;
                border: 1px solid #ccc;
                border-radius: 4px;
                box-sizing: border-box;
                font-size: 14px;
            }

            .is-invalid {
                border-color: #dc3545 !important;
                padding-right: calc(1.5em + 0.75rem);
                background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12' width='12' height='12' fill='none' stroke='%23dc3545'%3e%3ccircle cx='6' cy='6' r='4.5'/%3e%3cpath stroke-linejoin='round' d='M5.8 3.6h.4L6 6.5z'/%3e%3ccircle cx='6' cy='8.2' r='.6' fill='%23dc3545' stroke='none'/%3e%3c/svg%3e");
                background-repeat: no-repeat;
                background-position: right calc(0.375em + 0.1875rem) center;
                background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
            }

            .invalid-feedback {
                display: none;
                width: 100%;
                margin-top: 0.25rem;
                font-size: 0.875em;
                color: #dc3545;
            }

            .is-invalid ~ .invalid-feedback {
                display: block;
            }

            .pagination {
                display: flex;
                justify-content: center;
                list-style: none;
                padding: 0;
                margin-top: 30px;
            }

            .pagination li {
                margin: 0 3px;
            }

            .pagination a, .pagination span {
                padding: 6px 12px;
                border: 1px solid #dee2e6;
                text-decoration: none;
                color: #0d6efd;
                background-color: #fff;
                border-radius: .25rem;
                transition: background-color 0.2s ease, color 0.2s ease;
                font-size: 0.9rem;
            }

            .pagination a:hover {
                background-color: #e9ecef;
                color: #0a58ca;
            }

            .pagination a.active {
                background-color: #0d6efd;
                color: white;
                border-color: #0d6efd;
                font-weight: bold;
            }

            .pagination .disabled span {
                color: #6c757d;
                pointer-events: none;
                background-color: #e9ecef;
            }

            @media (max-width: 768px) {
                .content-header {
                    flex-direction: column;
                    align-items: stretch;
                }
                .search-filter {
                    flex-direction: column;
                    width: 100%;
                }
                .search-bar input, .filter-bar select {
                    width: 100%;
                    margin-bottom: 10px;
                }
                .header-buttons {
                    width: 100%;
                    text-align: center;
                }
                .header-buttons .btn-info {
                    width: 100%;
                }
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
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewAccountList" class="nav-link"><i class="fas fa-users me-2"></i>Employee Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewTableList" class="nav-link active"><i class="fas fa-building me-2"></i>Table Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewOrderList" class="nav-link"><i class="fas fa-shopping-cart me-2"></i>Order Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewCustomerList" class="nav-link"><i class="fas fa-user-friends me-2"></i>Customer Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewCouponController" class="nav-link"><i class="fas fa-tag me-2"></i>Coupon Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewInventoryController" class="nav-link"><i class="fas fa-boxes me-2"></i>Inventory Management</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/view-notifications" class="nav-link"><i class="fas fa-bell me-2"></i>View Notifications</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/create-notification" class="nav-link"><i class="fas fa-plus me-2"></i>Create Notification</a></li>
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/logout" class="nav-link"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                </ul>
            </div>

            <!-- Main Content -->
            <div class="col-md-10 p-4 main-content-area">
                <div class="text-left mb-4">
                    <h4>Table Management</h4>
                </div>
                <div class="container-fluid">
                    <div class="content-header">
                        <div class="search-filter">
                            <div class="search-bar">
                                <input type="text" id="searchInput" placeholder="Search by ID or Seats">
                            </div>
                            <div class="filter-bar">
                                <select id="statusFilter">
                                    <option value="">All Status</option>
                                    <option value="Available">Available</option>
                                    <option value="Occupied">Occupied</option>
                                    <option value="Reserved">Reserved</option>
                                </select>
                            </div>
                            <div class="filter-bar">
                                <select id="floorFilter">
                                    <option value="all">All Floors</option>
                                    <% if (floorNumbers != null && !floorNumbers.isEmpty()) {
                                            for (Integer floor : floorNumbers) {%>
                                    <option value="<%= floor%>">Floor <%= floor%></option>
                                    <% }
                                        } %>
                                </select>
                            </div>
                        </div>
                        <div class="header-buttons">
                            <button class="btn btn-info add-table-btn" data-bs-toggle="modal" data-bs-target="#createTableModal"><i class="fas fa-plus"></i> Create</button>
                        </div>
                    </div>

                    <div class="table-grid" id="tableGrid">
                        <% if (tables != null && !tables.isEmpty()) {
                                for (Table table : tables) {
                                    String tableClass = "table-item";
                                    String statusText = table.getTableStatus();
                                    if ("Available".equalsIgnoreCase(statusText)) {
                                        tableClass += " available";
                                    } else if ("Occupied".equalsIgnoreCase(statusText)) {
                                        tableClass += " occupied";
                                    } else if ("Reserved".equalsIgnoreCase(statusText)) {
                                        tableClass += " reserved";
                                    }%>
                        <div class="<%= tableClass%>" id="tableItem-<%= table.getTableId()%>">
                            <div class="table-info">
                                <div class="table-id">ID: <%= table.getTableId()%></div>
                                <div class="table-floor">Floor: <%= table.getFloorNumber()%></div>
                                <div class="table-seats">Seats: <%= table.getNumberOfSeats()%></div>
                                <div class="table-status">Status: <span><%= statusText%></span></div>
                            </div>
                            <div class="table-buttons">
                                <a href="#" class="btn-edit-table edit-table-btn" data-bs-toggle="modal" data-bs-target="#editTableModal"
                                   data-tableid="<%= table.getTableId()%>" data-floornumber="<%= table.getFloorNumber()%>"
                                   data-numberofseats="<%= table.getNumberOfSeats()%>" data-tablestatus="<%= table.getTableStatus()%>">
                                    <i class="fas fa-edit"></i>
                                </a>
                                <a href="#" class="btn-delete-table" onclick="confirmDelete('<%= table.getTableId()%>', '<%= table.getTableStatus()%>')">
                                    <i class="fas fa-trash-alt"></i>
                                </a>
                            </div>
                        </div>
                        <% }
                        } else { %>
                        <div class="no-data">
                            <i class="fas fa-chair"></i>
                            <% if (totalTables == 0) { %>
                            <span>NO TABLES FOUND.<br> CLICK <a href="#" data-bs-toggle="modal" data-bs-target="#createTableModal">HERE</a> TO ADD A NEW TABLE.</span>
                                <% } else { %>
                            <span>NO TABLES MATCH CURRENT FILTERS OR PAGE.</span>
                            <% } %>
                        </div>
                        <% } %>
                    </div>

                    <!-- Container cho phân trang động -->
                    <nav aria-label="Table navigation">
                        <ul class="pagination justify-content-center"></ul>
                    </nav>
                </div>
            </div>
        </div>

        <!-- Modal Create Table -->
        <div class="modal fade" id="createTableModal" tabindex="-1" aria-labelledby="createTableModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="createTableModalLabel">Create New Table</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="modal-form-container">
                            <form id="createTableForm" novalidate>
                                <div class="mb-3">
                                    <label for="CreateFloorNumber" class="form-label">Floor Number</label>
                                    <input type="number" id="CreateFloorNumber" name="floorNumber" min="1" class="form-control" placeholder="Enter floor number">
                                    <div class="invalid-feedback"></div>
                                </div>
                                <div class="mb-3">
                                    <label for="CreateNumberOfSeats" class="form-label">Number Of Seats</label>
                                    <input type="number" id="CreateNumberOfSeats" name="numberOfSeats" min="1" class="form-control" placeholder="Enter number of seats">
                                    <div class="invalid-feedback"></div>
                                </div>
                                <div class="mb-3">
                                    <label for="CreateTableStatus" class="form-label">Initial Status</label>
                                    <select id="CreateTableStatus" name="tableStatus" class="form-control">
                                        <option value="Available">Available</option>
                                        <option value="Reserved">Reserved</option>
                                        <option value="Occupied">Occupied</option>
                                    </select>
                                    <div class="invalid-feedback"></div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                    <button type="submit" class="btn btn-primary">Create Table</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal Edit Table -->
        <div class="modal fade" id="editTableModal" tabindex="-1" aria-labelledby="editTableModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="editTableModalLabel">Edit Table Details</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="modal-form-container">
                            <form id="editTableForm" novalidate>
                                <input type="hidden" id="EditTableIdHidden" name="TableIdHidden">
                                <div class="mb-3">
                                    <label for="EditTableId" class="form-label">Table ID</label>
                                    <input type="text" id="EditTableId" name="TableId" class="form-control" readonly>
                                    <div class="invalid-feedback"></div>
                                </div>
                                <div class="mb-3">
                                    <label for="EditFloorNumber" class="form-label">Floor Number</label>
                                    <input type="number" id="EditFloorNumber" name="FloorNumber" class="form-control" min="1" placeholder="Enter floor number">
                                    <div class="invalid-feedback"></div>
                                </div>
                                <div class="mb-3">
                                    <label for="EditNumberOfSeats" class="form-label">Number Of Seats</label>
                                    <input type="number" id="EditNumberOfSeats" name="NumberOfSeats" min="1" class="form-control" placeholder="Enter number of seats">
                                    <div class="invalid-feedback"></div>
                                </div>
                                <div class="mb-3">
                                    <label for="EditTableStatus" class="form-label">Table Status</label>
                                    <select id="EditTableStatus" name="TableStatus" class="form-control">
                                        <option value="Available">Available</option>
                                        <option value="Occupied">Occupied</option>
                                        <option value="Reserved">Reserved</option>
                                    </select>
                                    <div class="invalid-feedback"></div>
                                </div>
                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                    <button type="submit" class="btn btn-primary">Save Changes</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bootstrap 5.3.0 JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>

        <script>
                                    const allTables = [
            <%
            List<Table> allTablesForJs = (List<Table>) request.getAttribute("tableList");
            if (allTablesForJs != null) {
                for (int i = 0; i < allTablesForJs.size(); i++) {
                    Table table = allTablesForJs.get(i);
                    out.print("{");
                    out.print("\"tableId\": \"" + table.getTableId() + "\",");
                    out.print("\"floorNumber\": \"" + table.getFloorNumber() + "\",");
                    out.print("\"numberOfSeats\": \"" + table.getNumberOfSeats() + "\",");
                    out.print("\"tableStatus\": \"" + table.getTableStatus() + "\"");
                    out.print("}");
                    if (i < allTablesForJs.size() - 1) {
                        out.print(",");
                    }
                }
            }
            %>
                                    ];

                                    $(document).ready(function () {
                                        // Gắn sự kiện cho search và filter
                                        $('#searchInput').on('keyup', filterTables);
                                        $('#statusFilter').on('change', filterTables);
                                        $('#floorFilter').on('change', filterTables);

                                        // Xử lý form tạo bàn mới
                                        $('#createTableForm').submit(function (event) {
                                            event.preventDefault();
                                            if (!validateCreateTableForm())
                                                return;
                                            var formData = $(this).serialize();
                                            $.ajax({
                                                url: 'CreateTable',
                                                type: 'POST',
                                                data: formData,
                                                dataType: 'json',
                                                success: function (response) {
                                                    if (response.success) {
                                                        $('#createTableModal').modal('hide');
                                                        Swal.fire({
                                                            icon: 'success',
                                                            title: 'Success!',
                                                            text: 'Table created successfully.',
                                                            timer: 2000,
                                                            showConfirmButton: false
                                                        }).then(() => {
                                                            location.reload();
                                                        });
                                                    } else {
                                                        if (response.errors) {
                                                            for (let field in response.errors) {
                                                                displayError('Create' + field.charAt(0).toUpperCase() + field.slice(1), response.errors[field]);
                                                            }
                                                        } else {
                                                            Swal.fire('Error!', response.message || 'Failed to create table.', 'error');
                                                        }
                                                    }
                                                },
                                                error: function (xhr, status, error) {
                                                    Swal.fire('Error!', 'An error occurred while creating the table.', 'error');
                                                }
                                            });
                                        });

                                        // Xử lý form chỉnh sửa bàn
                                        $('#editTableForm').submit(function (event) {
                                            event.preventDefault();
                                            if (!validateEditTableForm())
                                                return;
                                            var formData = $(this).serialize();
                                            $.ajax({
                                                url: 'UpdateTable',
                                                type: 'POST',
                                                data: formData,
                                                dataType: 'json',
                                                success: function (response) {
                                                    if (response.success) {
                                                        $('#editTableModal').modal('hide');
                                                        Swal.fire({
                                                            icon: 'success',
                                                            title: 'Success!',
                                                            text: 'Table updated successfully.',
                                                            timer: 2000,
                                                            showConfirmButton: false
                                                        }).then(() => {
                                                            location.reload();
                                                        });
                                                    } else {
                                                        if (response.errors) {
                                                            for (let field in response.errors) {
                                                                displayError('Edit' + field.charAt(0).toUpperCase() + field.slice(1), response.errors[field]);
                                                            }
                                                        } else {
                                                            Swal.fire('Error!', response.message || 'Failed to update table.', 'error');
                                                        }
                                                    }
                                                },
                                                error: function (xhr, status, error) {
                                                    Swal.fire('Error!', 'An error occurred while updating the table.', 'error');
                                                }
                                            });
                                        });

                                        // Xử lý nút chỉnh sửa bàn
                                        $(document).on('click', '.edit-table-btn', function () {
                                            var tableId = $(this).data('tableid');
                                            var floorNumber = $(this).data('floornumber');
                                            var numberOfSeats = $(this).data('numberofseats');
                                            var tableStatus = $(this).data('tablestatus');
                                            $('#EditTableIdHidden').val(tableId);
                                            $('#EditTableId').val(tableId);
                                            $('#EditFloorNumber').val(floorNumber);
                                            $('#EditNumberOfSeats').val(numberOfSeats);
                                            $('#EditTableStatus').val(tableStatus);
                                            clearErrors('editTableForm');
                                        });

                                        // Xóa lỗi khi người dùng nhập dữ liệu
                                        $('#createTableForm input, #createTableForm select').on('input change', function () {
                                            clearErrors('createTableForm');
                                        });

                                        $('#editTableForm input, #editTableForm select').on('input change', function () {
                                            clearErrors('editTableForm');
                                        });

                                        // Gọi filterTables ngay khi trang được tải để áp dụng bộ lọc từ URL (nếu có)
                                        filterTables();
                                    });

                                    function filterTables() {
                                        console.log("filterTables được gọi");
                                        const searchText = $('#searchInput').val().toLowerCase();
                                        const selectedStatus = $('#statusFilter').val();
                                        const selectedFloor = $('#floorFilter').val();
                                        console.log("Search:", searchText, "Status:", selectedStatus, "Floor:", selectedFloor);

                                        // Lọc danh sách bàn
                                        const filteredTables = allTables.filter(table => {
                                            const matchesSearch = String(table.tableId).toLowerCase().includes(searchText) ||
                                                    String(table.numberOfSeats).toLowerCase().includes(searchText);
                                            const matchesStatus = selectedStatus === '' || table.tableStatus === selectedStatus;
                                            const matchesFloor = selectedFloor === 'all' || String(table.floorNumber) === selectedFloor;
                                            return matchesSearch && matchesStatus && matchesFloor;
                                        });

                                        // Cập nhật giao diện với danh sách đã lọc
                                        const pageSize = 20;
                                        const totalTables = filteredTables.length;
                                        const totalPages = Math.ceil(totalTables / pageSize);
                                        let currentPage = 1;

                                        const pageParam = new URLSearchParams(window.location.search).get("page");
                                        if (pageParam) {
                                            currentPage = parseInt(pageParam) || 1;
                                            if (currentPage < 1)
                                                currentPage = 1;
                                            if (currentPage > totalPages)
                                                currentPage = totalPages;
                                        }

                                        const startIndex = (currentPage - 1) * pageSize;
                                        const endIndex = Math.min(startIndex + pageSize, totalTables);
                                        const paginatedTables = filteredTables.slice(startIndex, endIndex);

                                        const tableGrid = $('#tableGrid');
                                        tableGrid.empty();

                                        if (paginatedTables.length > 0) {
                                            paginatedTables.forEach(table => {
                                                let tableClass = "table-item";
                                                let statusText = table.tableStatus;
                                                if ("Available" === statusText) {
                                                    tableClass += " available";
                                                } else if ("Occupied" === statusText) {
                                                    tableClass += " occupied";
                                                } else if ("Reserved" === statusText) {
                                                    tableClass += " reserved";
                                                }

                                                const tableHtml = '<div class="' + tableClass + '" id="tableItem-' + table.tableId + '">' +
                                                        '<div class="table-info">' +
                                                        '<div class="table-id">ID: ' + table.tableId + '</div>' +
                                                        '<div class="table-floor">Floor: ' + table.floorNumber + '</div>' +
                                                        '<div class="table-seats">Seats: ' + table.numberOfSeats + '</div>' +
                                                        '<div class="table-status">Status: <span>' + statusText + '</span></div>' +
                                                        '</div>' +
                                                        '<div class="table-buttons">' +
                                                        '<a href="#" class="btn-edit-table edit-table-btn" data-bs-toggle="modal" data-bs-target="#editTableModal"' +
                                                        ' data-tableid="' + table.tableId + '" data-floornumber="' + table.floorNumber + '"' +
                                                        ' data-numberofseats="' + table.numberOfSeats + '" data-tablestatus="' + table.tableStatus + '">' +
                                                        '<i class="fas fa-edit"></i>' +
                                                        '</a>' +
                                                        '<a href="#" class="btn-delete-table" onclick="confirmDelete(\'' + table.tableId + '\', \'' + table.tableStatus + '\')">' +
                                                        '<i class="fas fa-trash-alt"></i>' +
                                                        '</a>' +
                                                        '</div>' +
                                                        '</div>';
                                                tableGrid.append(tableHtml);
                                            });
                                        } else {
                                            tableGrid.append(
                                                    '<div class="no-data">' +
                                                    '<i class="fas fa-chair"></i>' +
                                                    '<span>NO TABLES MATCH CURRENT FILTERS OR PAGE.</span>' +
                                                    '</div>'
                                                    );
                                        }

                                        // Cập nhật phân trang
                                        const pagination = $('nav[aria-label="Table navigation"]');
                                        pagination.show();
                                        const paginationUl = pagination.find('ul');
                                        paginationUl.empty();

                                        if (totalPages > 1) {
                                            let paginationHtml = '<li class="page-item ' + (currentPage <= 1 ? "disabled" : "") + '">' +
                                                    '<a class="page-link" href="?page=' + (currentPage - 1) + getFilterParams() + '" aria-label="Previous">' +
                                                    '<span aria-hidden="true">«</span>' +
                                                    '</a>' +
                                                    '</li>';
                                            const startPage = Math.max(1, currentPage - 2);
                                            const endPage = Math.min(totalPages, currentPage + 2);

                                            if (startPage > 1) {
                                                paginationHtml += '<li class="page-item"><a class="page-link" href="?page=1' + getFilterParams() + '">1</a></li>';
                                                if (startPage > 2) {
                                                    paginationHtml += '<li class="page-item disabled"><span class="page-link">...</span></li>';
                                                }
                                            }

                                            for (let i = startPage; i <= endPage; i++) {
                                                paginationHtml += '<li class="page-item ' + (currentPage === i ? "active" : "") + '">' +
                                                        '<a class="page-link" href="?page=' + i + getFilterParams() + '">' + i + '</a>' +
                                                        '</li>';
                                            }

                                            if (endPage < totalPages) {
                                                if (endPage < totalPages - 1) {
                                                    paginationHtml += '<li class="page-item disabled"><span class="page-link">...</span></li>';
                                                }
                                                paginationHtml += '<li class="page-item"><a class="page-link" href="?page=' + totalPages + getFilterParams() + '">' + totalPages + '</a></li>';
                                            }

                                            paginationHtml += '<li class="page-item ' + (currentPage >= totalPages ? "disabled" : "") + '">' +
                                                    '<a class="page-link" href="?page=' + (currentPage + 1) + getFilterParams() + '" aria-label="Next">' +
                                                    '<span aria-hidden="true">»</span>' +
                                                    '</a>' +
                                                    '</li>';
                                            paginationUl.html(paginationHtml);
                                        } else {
                                            pagination.hide();
                                        }
                                    }

                                    function getFilterParams() {
                                        const searchText = $('#searchInput').val();
                                        const selectedStatus = $('#statusFilter').val();
                                        const selectedFloor = $('#floorFilter').val();
                                        let params = '';
                                        if (searchText)
                                            params += '&search=' + encodeURIComponent(searchText);
                                        if (selectedStatus)
                                            params += '&status=' + encodeURIComponent(selectedStatus);
                                        if (selectedFloor && selectedFloor !== 'all')
                                            params += '&floor=' + encodeURIComponent(selectedFloor);
                                        return params;
                                    }

                                    function displayError(fieldId, errorMessage) {
                                        const $field = $('#' + fieldId);
                                        $field.addClass('is-invalid');
                                        $field.siblings('.invalid-feedback').text(errorMessage);
                                    }

                                    function clearErrors(formId) {
                                        $('#' + formId + ' .is-invalid').removeClass('is-invalid');
                                        $('#' + formId + ' .invalid-feedback').text('');
                                    }

                                    function validateCreateTableForm() {
                                        clearErrors('createTableForm');
                                        let isValid = true;
                                        const floorNumber = $('#CreateFloorNumber').val().trim();
                                        const numberOfSeats = $('#CreateNumberOfSeats').val().trim();
                                        const tableStatus = $('#CreateTableStatus').val();
                                        if (!floorNumber || isNaN(floorNumber) || parseInt(floorNumber) <= 0) {
                                            displayError('CreateFloorNumber', 'Please enter a valid positive floor number.');
                                            isValid = false;
                                        }
                                        if (!numberOfSeats || isNaN(numberOfSeats) || parseInt(numberOfSeats) <= 0) {
                                            displayError('CreateNumberOfSeats', 'Please enter a valid positive number of seats.');
                                            isValid = false;
                                        }
                                        if (!tableStatus) {
                                            displayError('CreateTableStatus', 'Please select a table status.');
                                            isValid = false;
                                        }
                                        return isValid;
                                    }

                                    function validateEditTableForm() {
                                        clearErrors('editTableForm');
                                        let isValid = true;
                                        const floorNumber = $('#EditFloorNumber').val().trim();
                                        const numberOfSeats = $('#EditNumberOfSeats').val().trim();
                                        const tableStatus = $('#EditTableStatus').val();
                                        if (!floorNumber || isNaN(floorNumber) || parseInt(floorNumber) <= 0) {
                                            displayError('EditFloorNumber', 'Please enter a valid positive floor number.');
                                            isValid = false;
                                        }
                                        if (!numberOfSeats || isNaN(numberOfSeats) || parseInt(numberOfSeats) <= 0) {
                                            displayError('EditNumberOfSeats', 'Please enter a valid positive number of seats.');
                                            isValid = false;
                                        }
                                        if (!tableStatus) {
                                            displayError('EditTableStatus', 'Please select a table status.');
                                            isValid = false;
                                        }
                                        return isValid;
                                    }

                                    function confirmDelete(tableId, tableStatus) {
                                        Swal.fire({
                                            title: 'Are you sure?',
                                            text: 'You are about to delete Table ID: ' + tableId + '. This action cannot be undone!',
                                            icon: 'warning',
                                            showCancelButton: true,
                                            confirmButtonColor: '#dc3545',
                                            cancelButtonColor: '#6c757d',
                                            confirmButtonText: 'Yes, delete it!'
                                        }).then((result) => {
                                            if (result.isConfirmed) {
                                                if (tableStatus.toLowerCase() === 'reserved') {
                                                    Swal.fire('Error!', 'The table is reserved and cannot be deleted.', 'error');
                                                    return;
                                                } else if (tableStatus.toLowerCase() === 'occupied') {
                                                    Swal.fire('Error!', 'The table is occupied and cannot be deleted.', 'error');
                                                    return;
                                                }

                                                $.ajax({
                                                    url: 'DeleteTable',
                                                    type: 'POST',
                                                    data: {TableId: tableId},
                                                    dataType: 'json',
                                                    success: function (response) {
                                                        if (response.success) {
                                                            Swal.fire({
                                                                icon: 'success',
                                                                title: 'Success!',
                                                                text: 'Table deleted successfully.',
                                                                timer: 2000,
                                                                showConfirmButton: false
                                                            }).then(() => {
                                                                location.reload();
                                                            });
                                                        } else {
                                                            Swal.fire('Error!', response.message || 'Failed to delete table.', 'error');
                                                        }
                                                    },
                                                    error: function (xhr, status, error) {
                                                        Swal.fire('Error!', 'An error occurred while deleting the table.', 'error');
                                                    }
                                                });
                                            }
                                        });
                                    }
        </script>
    </body>
</html>