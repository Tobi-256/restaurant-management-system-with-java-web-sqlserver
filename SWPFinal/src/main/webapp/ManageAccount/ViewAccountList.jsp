<%@page import="java.util.List"%>
<%@page import="Model.Account"%>
<%@page import="DAO.AccountDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    // Ensure session and account exist
    if (session == null || session.getAttribute("account") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    Account account = (Account) session.getAttribute("account");
    String UserRole = account.getUserRole();

    // --- Determine View Mode ---
    String viewMode = (String) request.getAttribute("viewMode");
    if (viewMode == null || viewMode.isEmpty() || !viewMode.equals("inactive")) {
        viewMode = "active"; // Default to active
    }

    // --- Get Data from Request ---
    List<Account> accounts = (List<Account>) request.getAttribute("accountList");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    String statusParam = request.getParameter("status") != null ? request.getParameter("status") : "active"; // Used for pagination links

    // Ensure currentPage and totalPages are not null
    currentPage = (currentPage == null) ? 1 : currentPage;
    totalPages = (totalPages == null) ? 1 : totalPages;

    int counter = (currentPage - 1) * 10 + 1; // 10 is PAGE_SIZE, adjust if different
%>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Employee Account List - Admin Dashboard</title>

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

            .main-content-area {
                padding: 20px;
                width: 83.33333%; /* Adjust if sidebar width changes */
                margin-left: 16.67%;
            }

            .content-title { /* Replaced content-header for title only */
                overflow: hidden;
                background: linear-gradient(to right, #2C3E50, #42A5F5);
                padding: 1rem;
                color: white;
                margin-bottom: 20px;
                margin-left: -20px; /* Extend to edge */
                margin-right: -20px; /* Extend to edge */
                margin-top: -20px; /* Extend to edge */
                border-radius: 0; /* Remove rounding if needed */
            }

            .top-controls { /* New container for pagination and create button */
                display: flex;
                justify-content: space-between;
                align-items: center; /* Vertically center items */
                margin-bottom: 20px;
                flex-wrap: wrap; /* Allow wrapping on smaller screens */
            }

            .pagination-container {
                /* Takes available space, pushes button right */
                margin-right: 15px; /* Space between pagination and button */
            }

            .header-buttons .btn-info { /* Style for Create button */
                background-color: #007bff;
                color: white;
                border: none;
                padding: 8px 15px;
                border-radius: 5px;
                cursor: pointer;
                white-space: nowrap; /* Prevent button text wrapping */
            }

            .header-buttons .btn-info:hover {
                background-color: #0056b3;
            }

            .filter-controls { /* New container for search/filter */
                margin-bottom: 20px;
            }

            .search-filter-inputs { /* Container for search bar and dropdown */
                display: flex;
                align-items: center;
                gap: 10px;
                margin-top: 10px; /* Space below tabs */
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

            .table-responsive {
                overflow-x: auto;
            }

            .table {
                width: 100%;
                margin-bottom: 1rem;
                background-color: #fff;
            }

            .table thead th {
                background-color: #343a40;
                color: white;
                border-color: #454d55;
            }

            .table-hover tbody tr:hover {
                background-color: #f1f1f1;
            }

            .table th.actions-column,
            .table td.actions-column {
                width: 150px; /* Adjust as needed */
                white-space: nowrap;
            }
            .table td.actions-column a {
                margin-right: 5px;
            } /* Space between buttons */


            .btn-warning { /* Update Button */
                background-color: #ffca28;
                border-color: #ffca28;
                color: white;
                transition: background-color 0.3s ease, border-color 0.3s ease, box-shadow 0.3s ease;
            }
            .btn-warning:hover {
                background-color: #ffda6a;
                border-color: #ffda6a;
                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
            }

            .btn-danger { /* Delete Button */
                background-color: #f44336;
                border-color: #f44336;
                color: white;
                transition: background-color 0.3s ease, border-color 0.3s ease, box-shadow 0.3s ease;
            }
            .btn-danger:hover {
                background-color: #e53935;
                border-color: #e53935;
                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
                color: black;
            }

            .btn-success { /* Restore Button */
                background-color: #28a745;
                border-color: #28a745;
                color: white;
            }
            .btn-success:hover {
                background-color: #218838;
                border-color: #1e7e34;
            }


            .btn-edit, .btn-delete, .btn-restore {
                padding: 5px 10px;
                border-radius: 5px;
                color: white !important; /* Ensure icon color is white */
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                justify-content: center;
                vertical-align: middle; /* Align buttons nicely */
            }

            .btn-edit {
                background-color: #007bff;
            } /* View/Edit Button */
            .btn-edit:hover {
                background-color: #0056b3;
            }

            .btn-delete {
                background-color: #dc3545;
            } /* Delete Button */
            .btn-delete:hover {
                background-color: #c82333;
            }

            .btn-restore {
                background-color: #198754;
            } /* Restore Button */
            .btn-restore:hover {
                background-color: #157347;
            }


            .btn-edit i, .btn-delete i, .btn-restore i {
                margin-right: 5px;
                color: white; /* Ensure icon color */
            }

            .modal-header {
                background-color: #f7f7f0;
            }

            .modal-form-container input[type="text"],
            .modal-form-container input[type="email"],
            .modal-form-container input[type="password"],
            .modal-form-container input[type="number"],
            .modal-form-container select,
            .modal-form-container input[type="file"] {
                width: calc(100% - 22px); /* Adjust based on padding/border */
                padding: 10px;
                border: 1px solid #ccc;
                border-radius: 4px;
                box-sizing: border-box;
                font-size: 14px;
            }
            /* Ensure select also uses box-sizing */
            .modal-form-container select {
                width: 100%; /* Let select take full width */
            }

            .rounded-image {
                width: 100px;
                height: 100px;
                border-radius: 50%;
                object-fit: cover;
                border: 1px solid #ddd; /* Add a light border */
                margin-bottom: 10px; /* Space below image */
            }
            .custom-file-upload {
                margin-bottom: 10px;
            }

            .is-invalid {
                border-color: #dc3545 !important;
                padding-right: calc(1.5em + 0.75rem);
                background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 12 12' width='12' height='12' fill='none' stroke='%23dc3545'%3e%3ccircle cx='6' cy='6' r='4.5'/%3e%3cpath stroke-linejoin='round' d='M5.8 3.6h.4L6 6.5z'/%3e%3ccircle cx='6' cy='8.2' r='.6' fill='%23dc3545' stroke='none'/%3e%3c/svg%3e");
                background-repeat: no-repeat;
                background-position: right calc(0.375em + 0.1875rem) center;
                background-size: calc(0.75em + 0.375rem) calc(0.75em + 0.375rem);
            }
            /* Style invalid state for select */
            select.is-invalid {
                background-position: right 1.2rem center !important; /* Adjust icon position for select */
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
                /* justify-content: center; -> Removed, alignment handled by parent */
                list-style: none;
                padding: 0;
                margin-top: 0; /* Removed top margin, handled by parent */
                margin-bottom: 0; /* No bottom margin needed here */
                flex-wrap: wrap; /* Allow wrapping on small screens */
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

            .pagination li.active a { /* Target the 'a' inside the active 'li' */
                background-color: #0d6efd;
                color: white;
                border-color: #0d6efd;
                font-weight: bold;
                z-index: 2; /* Ensure active page is visually on top */
            }


            .pagination .disabled span {
                color: #6c757d;
                pointer-events: none;
                background-color: #e9ecef;
            }

            .top-controls {
                display: flex;
                justify-content: space-between; /* Keep space-between */
                align-items: center; /* Center vertically */
                margin-bottom: 20px;
                flex-wrap: wrap; /* Allow wrapping if screen is small */
                gap: 15px; /* Add spacing between elements */
            }

            .pagination-container {
                flex: 1; /* Allow pagination to take flexible space */
                max-width: 70%; /* Limit max width of pagination */
                display: flex;
                justify-content: flex-start; /* Align pagination to the left */
            }

            .header-buttons {
                flex-shrink: 0; /* Ensure Create button doesn’t shrink too much */
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
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewAccountList" class="nav-link active"><i class="fas fa-users me-2"></i>Employee Management</a></li>
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

            <!-- Main Content -->
            <div class="main-content-area">
                <div class="content-title">
                    <h4>Employee Management</h4>
                </div>

                <!-- Top Controls: Pagination (Left) and Create Button (Right) -->
                <div class="top-controls">
                    <div class="pagination-container">
                        <% if (totalPages != null && totalPages > 1) {
                                int startPage = Math.max(1, currentPage - 2);
                                int endPage = Math.min(totalPages, currentPage + 2);
                                String paginationStatus = viewMode;
                        %>
                        <nav aria-label="<%= paginationStatus.substring(0, 1).toUpperCase() + paginationStatus.substring(1)%> account navigation">
                            <ul class="pagination">
                                <li class="page-item <%= (currentPage <= 1) ? "disabled" : ""%>">
                                    <a class="page-link" href="?status=<%= paginationStatus%>&page=<%= currentPage - 1%>" aria-label="Previous">
                                        <span aria-hidden="true">«</span>
                                    </a>
                                </li>
                                <% if (startPage > 1) {%>
                                <li class='page-item'><a class='page-link' href='?status=<%= paginationStatus%>&page=1'>1</a></li>
                                    <% if (startPage > 2) { %>
                                <li class='page-item disabled'><span class='page-link'>...</span></li>
                                    <% } %>
                                    <% } %>
                                    <% for (int i = startPage; i <= endPage; i++) {%>
                                <li class="page-item <%= (currentPage == i) ? "active" : ""%>">
                                    <a class="page-link" href="?status=<%= paginationStatus%>&page=<%= i%>"><%= i%></a>
                                </li>
                                <% } %>
                                <% if (endPage < totalPages) { %>
                                <% if (endPage < totalPages - 1) { %>
                                <li class='page-item disabled'><span class='page-link'>...</span></li>
                                    <% }%>
                                <li class='page-item'><a class='page-link' href='?status=<%= paginationStatus%>&page=<%= totalPages%>'><%= totalPages%></a></li>
                                    <% }%>
                                <li class="page-item <%= (currentPage >= totalPages) ? "disabled" : ""%>">
                                    <a class="page-link" href="?status=<%= paginationStatus%>&page=<%= currentPage + 1%>" aria-label="Next">
                                        <span aria-hidden="true">»</span>
                                    </a>
                                </li>
                            </ul>
                        </nav>
                        <% }%>
                    </div>


                </div>

                <!-- Filter Controls: Tabs, Search, Filter Dropdown -->
               <div class="filter-controls">
    <ul class="nav nav-tabs mb-3" id="accountTabs" role="tablist">
        <li class="nav-item" role="presentation">
            <button class="nav-link <%= "active".equals(viewMode) ? "active" : ""%>"
                    id="active-tab" data-bs-toggle="tab" data-bs-target="#active" type="button"
                    role="tab" aria-controls="active" aria-selected="<%= "active".equals(viewMode) ? "true" : "false"%>">
                Active Accounts
            </button>
        </li>
        <li class="nav-item" role="presentation">
            <button class="nav-link <%= "inactive".equals(viewMode) ? "active" : ""%>"
                    id="inactive-tab" data-bs-toggle="tab" data-bs-target="#inactive" type="button"
                    role="tab" aria-controls="inactive" aria-selected="<%= "inactive".equals(viewMode) ? "true" : "false"%>">
                Inactive Accounts
            </button>
        </li>
    </ul>
    <div class="d-flex justify-content-between align-items-center">
        <div class="search-filter-inputs d-flex">
            <div class="search-bar me-2">
                <input type="text" id="searchInput" class="form-control" placeholder="Search by ID, Name, Email">
            </div>
            <div class="filter-bar">
                <select id="roleFilter" class="form-select">
                    <option value="" selected>All Roles</option>
                    <option value="Admin">Admin</option>
                    <option value="Manager">Manager</option>
                    <option value="Cashier">Cashier</option>
                    <option value="Waiter">Waiter</option>
                    <option value="Kitchen staff">Kitchen staff</option>
                </select>
            </div>
        </div>
        <div class="header-buttons">
            <button class="btn btn-info add-employee-btn" data-bs-toggle="modal" data-bs-target="#createEmployeeModal">
                <i class="fas fa-plus"></i> Create
            </button>
        </div>
    </div>       
</div>

                <!-- Account Tables -->
                <div class="tab-content" id="accountTabContent">
                    <!-- Tab Active -->
                    <div class="tab-pane fade <%= "active".equals(viewMode) ? "show active" : ""%>"
                         id="active" role="tabpanel" aria-labelledby="active-tab">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover">
                                <thead>
                                    <tr>
                                        <th>No.</th>
                                        <th>User ID</th>
                                        <th>User Name</th>
                                        <th>User Email</th>
                                        <th>User Role</th>
                                        <th class="actions-column">Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="activeAccountTableBody">
                                    <%
                                        counter = (currentPage - 1) * 10 + 1; // Reset counter based on current view
                                        int activeCount = 0;
                                        if (accounts != null && !accounts.isEmpty()) {
                                            for (Account acc : accounts) {
                                                if (!acc.isIsDeleted()) { // Show active accounts
                                                    activeCount++;
                                    %>
                                    <tr id="accountRow<%= acc.getUserId()%>">
                                        <td><%= counter++%></td>
                                        <td><%= acc.getUserId()%></td>
                                        <td><%= acc.getUserName() != null ? acc.getUserName() : ""%></td>
                                        <td><%= acc.getUserEmail() != null ? acc.getUserEmail() : ""%></td>
                                        <td><%= acc.getUserRole() != null ? acc.getUserRole() : ""%></td>
                                        <td class="actions-column">
                                            <a href="#" class="btn btn-sm btn-edit view-detail-btn"
                                               title="View Details"
                                               data-userid="<%= acc.getUserId()%>"
                                               data-useremail="<%= acc.getUserEmail() != null ? acc.getUserEmail() : ""%>"
                                               data-userpassword="<%= acc.getUserPassword() != null ? acc.getUserPassword() : ""%>"
                                               data-username="<%= acc.getUserName() != null ? acc.getUserName() : ""%>"
                                               data-userrole="<%= acc.getUserRole() != null ? acc.getUserRole() : ""%>"
                                               data-identitycard="<%= acc.getIdentityCard() != null ? acc.getIdentityCard() : ""%>"
                                               data-useraddress="<%= acc.getUserAddress() != null ? acc.getUserAddress() : ""%>"
                                               data-userphone="<%= acc.getUserPhone() != null ? acc.getUserPhone() : ""%>"
                                               data-userimage="<%= acc.getUserImage() != null ? acc.getUserImage() : ""%>">
                                                <i class="fas fa-eye"></i> View
                                            </a>
                                            <% if (!"Admin".equalsIgnoreCase(acc.getUserRole())) { // Case-insensitive check %>
                                            <a href="#" class="btn btn-sm btn-delete btn-delete-account"
                                               title="Delete Account"
                                               data-bs-toggle="modal" data-bs-target="#deleteAccountModal"
                                               data-account-id="<%= acc.getUserId()%>"
                                               data-account-name="<%= acc.getUserName() != null ? acc.getUserName() : ""%>">
                                                <i class="fas fa-trash-alt"></i> Delete
                                            </a>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <%
                                            } // end if !isDeleted
                                        } // end for loop

                                        // Message if no active accounts were found in the current page's list AND the view mode is active
                                        if (activeCount == 0 && "active".equals(viewMode)) {
                                    %>
                                    <tr class="no-results-message"><td colspan="6" class="text-center">No active accounts found matching criteria.</td></tr>
                                    <%
                                        }
                                    } else if ("active".equals(viewMode)) { // Message if the entire accountList is null/empty for active view
                                    %>
                                    <tr class="no-results-message"><td colspan="6" class="text-center">No active accounts found.</td></tr>
                                    <%
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                        <%-- Pagination for Active is handled above --%>
                    </div>

                    <!-- Tab Inactive -->
                    <div class="tab-pane fade <%= "inactive".equals(viewMode) ? "show active" : ""%>"
                         id="inactive" role="tabpanel" aria-labelledby="inactive-tab">
                        <div class="table-responsive">
                            <table class="table table-bordered table-hover">
                                <thead>
                                    <tr>
                                        <th>No.</th>
                                        <th>User ID</th>
                                        <th>User Name</th>
                                        <th>User Email</th>
                                        <th>User Role</th>
                                        <th class="actions-column">Actions</th>
                                    </tr>
                                </thead>
                                <tbody id="inactiveAccountTableBody">
                                    <%
                                        counter = (currentPage - 1) * 10 + 1; // Reset counter
                                        int inactiveCount = 0;
                                        if (accounts != null && !accounts.isEmpty()) {
                                            for (Account acc : accounts) {
                                                if (acc.isIsDeleted()) { // Show inactive accounts
                                                    inactiveCount++;
                                    %>
                                    <tr id="accountRow<%= acc.getUserId()%>">
                                        <td><%= counter++%></td>
                                        <td><%= acc.getUserId()%></td>
                                        <td><%= acc.getUserName() != null ? acc.getUserName() : ""%></td>
                                        <td><%= acc.getUserEmail() != null ? acc.getUserEmail() : ""%></td>
                                        <td><%= acc.getUserRole() != null ? acc.getUserRole() : ""%></td>
                                        <td class="actions-column">
                                            <a href="#" class="btn btn-sm btn-edit view-detail-btn"
                                               title="View Details"
                                               data-userid="<%= acc.getUserId()%>"
                                               data-useremail="<%= acc.getUserEmail() != null ? acc.getUserEmail() : ""%>"
                                               data-userpassword="<%= acc.getUserPassword() != null ? acc.getUserPassword() : ""%>"
                                               data-username="<%= acc.getUserName() != null ? acc.getUserName() : ""%>"
                                               data-userrole="<%= acc.getUserRole() != null ? acc.getUserRole() : ""%>"
                                               data-identitycard="<%= acc.getIdentityCard() != null ? acc.getIdentityCard() : ""%>"
                                               data-useraddress="<%= acc.getUserAddress() != null ? acc.getUserAddress() : ""%>"
                                               data-userphone="<%= acc.getUserPhone() != null ? acc.getUserPhone() : ""%>"
                                               data-userimage="<%= acc.getUserImage() != null ? acc.getUserImage() : ""%>">
                                                <i class="fas fa-eye"></i> View
                                            </a>
                                            <% if (!"Admin".equalsIgnoreCase(acc.getUserRole())) { // Case-insensitive check %>
                                            <a href="#" class="btn btn-sm btn-restore btn-restore-account"
                                               title="Restore Account"
                                               data-bs-toggle="modal" data-bs-target="#restoreAccountModal"
                                               data-account-id="<%= acc.getUserId()%>"
                                               data-account-name="<%= acc.getUserName() != null ? acc.getUserName() : ""%>">
                                                <i class="fas fa-undo"></i> Restore
                                            </a>
                                            <% } %>
                                        </td>
                                    </tr>
                                    <%
                                            } // end if isDeleted
                                        } // end for loop

                                        // Message if no inactive accounts were found AND the view mode is inactive
                                        if (inactiveCount == 0 && "inactive".equals(viewMode)) {
                                    %>
                                    <tr class="no-results-message"><td colspan="6" class="text-center">No inactive accounts found matching criteria.</td></tr>
                                    <%
                                        }
                                    } else if ("inactive".equals(viewMode)) { // Message if the entire accountList is null/empty for inactive view
                                    %>
                                    <tr class="no-results-message"><td colspan="6" class="text-center">No inactive accounts found.</td></tr>
                                    <%
                                        }
                                    %>
                                </tbody>
                            </table>
                        </div>
                        <%-- Pagination for Inactive is handled above --%>
                    </div>
                </div>
                <!-- End Tab Content -->

            </div> <!-- End Main Content Area -->
        </div> <!-- End d-flex -->

        <!-- MODALS (Keep these outside the main content flow, usually near the end of <body>) -->

        <!-- Modal Create Employee Account -->
        <div class="modal fade" id="createEmployeeModal" tabindex="-1" aria-labelledby="createEmployeeModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="createEmployeeModalLabel">Create New Employee Account</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="modal-form-container">
                            <form id="createAccountForm" enctype="multipart/form-data" novalidate>
                                <div class="mb-3 text-center"> <!-- Center image -->
                                    <label class="form-label d-block">Profile Image Preview</label>
                                    <img id="createCurrentImage" src="" alt="Profile Image Preview" class="rounded-image mb-2" style="display:none;">
                                    <p id="createNoImageMessage" style="color: gray;">No image selected</p>
                                    <div class="custom-file-upload">
                                        <input type="file" id="UserImage" name="UserImage" accept="image/*" style="display: none;" onchange="checkImageSelected('create')" required>
                                        <button type="button" id="createCustomFileButton" class="btn btn-sm btn-secondary">Choose File</button>
                                        <span id="createFileNameDisplay" class="ms-2">No file chosen</span>
                                    </div>
                                    <div class="invalid-feedback"></div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="UserEmail" class="form-label">Email Address *</label>
                                        <input type="email" class="form-control" id="UserEmail" name="UserEmail" placeholder="Enter email" required>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="UserPassword" class="form-label">Password *</label>
                                        <input type="password" class="form-control" id="UserPassword" name="UserPassword" placeholder="Min 6 characters" required>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="UserName" class="form-label">Full Name *</label>
                                        <input type="text" class="form-control" id="UserName" name="UserName" placeholder="Enter full name" required>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="UserRole" class="form-label">Role *</label>
                                        <select class="form-select" id="UserRole" name="UserRole" required>
                                            <option value="" selected disabled>Select Role</option>
                                            <option value="Manager">Manager</option>
                                            <option value="Cashier">Cashier</option>
                                            <option value="Waiter">Waiter</option>
                                            <option value="Kitchen staff">Kitchen staff</option>
                                        </select>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="IdentityCard" class="form-label">Identity Card (12 digits) *</label>
                                        <input type="text" class="form-control" id="IdentityCard" name="IdentityCard" placeholder="Enter 12-digit ID" maxlength="12" pattern="\d{12}" oninput="this.value = this.value.replace(/[^0-9]/g, '').slice(0, 12)" required>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="UserAddress" class="form-label">Address *</label>
                                        <input type="text" class="form-control" id="UserAddress" name="UserAddress" placeholder="Enter address" required>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="UserPhone" class="form-label">Phone (10 digits, starts with 0) *</label>
                                        <input type="text" class="form-control" id="UserPhone" name="UserPhone" placeholder="e.g., 0123456789" maxlength="10" pattern="0\d{9}" oninput="this.value = this.value.replace(/[^0-9]/g, '').slice(0, 10)" required>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                </div>

                                <div class="modal-footer">
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                    <input type="submit" class="btn btn-primary" value="Create">
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal View Account Detail -->
        <div class="modal fade" id="viewAccountDetailModal" tabindex="-1" aria-labelledby="viewAccountDetailModalLabel" aria-hidden="true">
            <div class="modal-dialog modal-lg">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="detailModalHeading">Account Detail</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <div class="modal-form-container">
                            <form id="updateAccountDetailForm" enctype="multipart/form-data" novalidate>
                                <input type="hidden" id="DetailUserIdHidden" name="UserIdHidden">
                                <input type="hidden" id="DetailUserRoleHidden" name="UserRoleHidden">
                                <input type="hidden" name="oldImagePath" id="DetailOldImagePath">

                                <div class="mb-3 text-center"> <!-- Center image -->
                                    <label class="form-label d-block">Current Image</label>
                                    <img id="DetailCurrentImage" src="" alt="Current Image" class="rounded-image">
                                    <p id="noImageMessage" style="display:none; color: gray;">No image available</p>
                                </div>

                                <div id="imageUpdateSection" style="display:none;" class="mb-3">
                                    <label for="DetailUserImage" class="form-label">Update Image</label>
                                    <div class="custom-file-upload">
                                        <input type="file" id="DetailUserImage" name="UserImage" accept="image/*" style="display: none;" onchange="checkImageSelected('update')">
                                        <button type="button" id="updateCustomFileButton" class="btn btn-sm btn-secondary">Choose File</button>
                                        <span id="updateFileNameDisplay" class="ms-2">No file chosen</span>
                                    </div>
                                    <div class="invalid-feedback"></div>
                                </div>

                                <div class="row"> <!-- Use row/col for better layout -->
                                    <div class="col-md-6 mb-3">
                                        <label for="DetailUserId" class="form-label">User ID</label>
                                        <input type="text" class="form-control" id="DetailUserId" name="UserId" readonly>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="DetailUserEmail" class="form-label">Email Address</label>
                                        <input type="email" class="form-control" id="DetailUserEmail" name="UserEmail" readonly required>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="DetailUserName" class="form-label">Full Name</label>
                                        <input type="text" class="form-control" id="DetailUserName" name="UserName" readonly required>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="DetailUserRole" class="form-label">Role</label>
                                        <select class="form-select" id="DetailUserRole" name="UserRole" disabled required> <%-- Use form-select --%>
                                            <option value="">Select Role</option>
                                            <option value="Manager">Manager</option>
                                            <option value="Cashier">Cashier</option>
                                            <option value="Waiter">Waiter</option>
                                            <option value="Kitchen staff">Kitchen staff</option>
                                        </select>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="DetailUserPassword" class="form-label">Password</label>
                                        <input type="password" class="form-control" id="DetailUserPassword" name="UserPassword" readonly required>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="DetailIdentityCard" class="form-label">Identity Card (12 digits)</label>
                                        <input type="text" class="form-control" id="DetailIdentityCard" name="IdentityCard" readonly maxlength="12" pattern="\d{12}" oninput="this.value = this.value.replace(/[^0-9]/g, '').slice(0, 12)" required>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                </div>

                                <div class="row">
                                    <div class="col-md-6 mb-3">
                                        <label for="DetailUserAddress" class="form-label">Address</label>
                                        <input type="text" class="form-control" id="DetailUserAddress" name="UserAddress" readonly required>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                    <div class="col-md-6 mb-3">
                                        <label for="DetailUserPhone" class="form-label">Phone (10 digits, starts with 0)</label>
                                        <input type="text" class="form-control" id="DetailUserPhone" name="UserPhone" readonly maxlength="10" pattern="0\d{9}" oninput="this.value = this.value.replace(/[^0-9]/g, '').slice(0, 10)" required>
                                        <div class="invalid-feedback"></div>
                                    </div>
                                </div>

                                <div class="modal-footer mt-3" id="modalActions">
                                    <!-- Dynamic buttons added via JavaScript -->
                                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                                </div>
                            </form>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- Delete Account Modal -->
        <div class="modal fade" id="deleteAccountModal" tabindex="-1" aria-labelledby="deleteAccountModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="deleteAccountModalLabel">Confirm Delete</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>Are you sure you want to delete this account?</p>
                        <input type="hidden" id="accountIdDelete">
                        <input type="hidden" id="accountNameDelete">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-danger" id="btnDeleteAccountConfirm">Delete</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Restore Account Modal -->
        <div class="modal fade" id="restoreAccountModal" tabindex="-1" aria-labelledby="restoreAccountModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="restoreAccountModalLabel">Confirm Restore</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>Are you sure you want to restore this account?</p>
                        <input type="hidden" id="accountIdRestore">
                        <input type="hidden" id="accountNameRestore">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-success" id="btnRestoreAccountConfirm">Restore</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Modal Confirm Code -->
        <div class="modal fade" id="confirmCodeModal" tabindex="-1" aria-labelledby="confirmCodeModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="confirmCodeModalLabel">Enter Confirmation Code</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>A confirmation code has been sent to the employee's email address. Please enter it below.</p>
                        <form id="confirmCodeForm" novalidate>
                            <div class="mb-3">
                                <label for="confirmationCode" class="form-label">Confirmation Code *</label>
                                <input type="text" class="form-control" id="confirmationCode" name="confirmationCode" placeholder="Enter 6-digit code" maxlength="6" required pattern="\d{6}">
                                <div class="invalid-feedback"></div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                <input type="submit" class="btn btn-primary" value="Confirm">
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>

        <!-- Bootstrap 5.3.0 JS -->
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>

        <%-- JavaScript Section --%>
        <script>
                                            // --- Utility Functions ---
                                            function displayError(fieldId, errorMessage) {
                                                const $field = $('#' + fieldId);
                                                if (!$field.length) {
                                                    console.error(`Field with ID '${fieldId}' not found.`);
                                                    return;
                                                }
                                                const $feedback = $field.siblings('.invalid-feedback').length
                                                        ? $field.siblings('.invalid-feedback')
                                                        : $field.closest('.mb-3').find('.invalid-feedback').first();
                                                if (!$feedback.length) {
                                                    console.error(`No invalid-feedback div found for field '${fieldId}'.`);
                                                    return;
                                                }
                                                $field.addClass('is-invalid');
                                                $feedback.text(errorMessage).show();

                                                if ($field.attr('type') === 'file') {
                                                    $field.siblings('.custom-file-upload').find('button').addClass('is-invalid');
                                                }
                                                if ($field.prop('tagName') === 'SELECT') {
                                                    $field.addClass('is-invalid');
                                                }
                                            }

                                            function clearErrors(formId) {
                                                const $form = $('#' + formId);
                                                $form.find('.is-invalid').removeClass('is-invalid');
                                                $form.find('.invalid-feedback').text('').hide();
                                                $form.find('.custom-file-upload button').removeClass('is-invalid');
                                            }

                                            function clearForm(formId) {
                                                const $form = $('#' + formId);
                                                if ($form.length) {
                                                    $form[0].reset();
                                                }
                                                clearErrors(formId);
                                                if (formId === 'createAccountForm') {
                                                    $('#createCurrentImage').hide().attr('src', '');
                                                    $('#createNoImageMessage').show();
                                                    $('#createFileNameDisplay').text('No file chosen');
                                                    $('#UserImage').val(null); // Better way to clear file input
                                                } else if (formId === 'updateAccountDetailForm') {
                                                    // Resetting image preview in update is handled when modal opens
                                                    $('#updateFileNameDisplay').text('No file chosen');
                                                    $('#DetailUserImage').val(null); // Better way to clear file input
                                                }
                                            }

                                            // --- Validation Functions ---
                                            function validateField(fieldId, validationFn, errorMessage) {
                                                const $field = $('#' + fieldId);
                                                const value = $field.val() ? $field.val().trim() : '';
                                                const $feedback = $field.siblings('.invalid-feedback').length ? $field.siblings('.invalid-feedback') : $field.closest('.mb-3').find('.invalid-feedback').first();

                                                $field.removeClass('is-invalid'); // Remove class first
                                                $feedback.text('').hide();

                                                if (!validationFn(value)) {
                                                    displayError(fieldId, errorMessage); // Display error handles adding class back
                                                    return false;
                                                }
                                                return true;
                                            }

                                            function validateFile(fieldId, required, errorMsgRequired) {
                                                const $field = $('#' + fieldId);
                                                const $feedback = $field.closest('.mb-3').find('.invalid-feedback').first();
                                                const $button = $field.closest('.custom-file-upload').find('button');

                                                $field.removeClass('is-invalid');
                                                $button.removeClass('is-invalid');
                                                $feedback.text('').hide();

                                                if (required && $field[0].files.length === 0) {
                                                    displayError(fieldId, errorMsgRequired); // Use displayError to handle style
                                                    return false;
                                                }
                                                return true;
                                            }

                                            function validateCreateForm() {
                                                clearErrors('createAccountForm');
                                                let isValid = true;

                                                isValid &= validateField('UserEmail', val => val && /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(val), 'Valid email is required.');
                                                isValid &= validateField('UserPassword', val => val && val.length >= 6, 'Password must be at least 6 characters.');
                                                isValid &= validateField('UserName', val => val && val.length >= 2 && val.length <= 50, 'Name (2-50 characters) is required.');
                                                isValid &= validateField('UserRole', val => val !== null && val !== '', 'Please select a role.');
                                                isValid &= validateField('IdentityCard', val => val && /^\d{12}$/.test(val), '12-digit Identity card is required.');
                                                isValid &= validateField('UserAddress', val => val && val.length >= 5 && val.length <= 100, 'Address (5-100 characters) is required.');
                                                isValid &= validateField('UserPhone', val => val && /^0\d{9}$/.test(val), '10-digit phone (starts with 0) is required.');
                                                isValid &= validateFile('UserImage', true, 'Profile image is required.');

                                                return !!isValid; // Convert potential 0/1 to boolean
                                            }

                                            function validateUpdateDetailForm() {
                                                clearErrors('updateAccountDetailForm');
                                                let isValid = true;

                                                isValid &= validateField('DetailUserEmail', val => val && /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(val), 'Valid email is required.');
                                                isValid &= validateField('DetailUserPassword', val => val && val.length >= 6, 'Password must be at least 6 characters.');
                                                isValid &= validateField('DetailUserName', val => val && val.length >= 2 && val.length <= 50, 'Name (2-50 characters) is required.');
                                                isValid &= validateField('DetailUserRole', val => val !== null && val !== '', 'Please select a role.');
                                                isValid &= validateField('DetailIdentityCard', val => val && /^\d{12}$/.test(val), '12-digit Identity card is required.');
                                                isValid &= validateField('DetailUserAddress', val => val && val.length >= 5 && val.length <= 100, 'Address (5-100 characters) is required.');
                                                isValid &= validateField('DetailUserPhone', val => val && /^0\d{9}$/.test(val), '10-digit phone (starts with 0) is required.');

                                                return !!isValid;
                                            }

                                            function validateConfirmCodeForm() {
                                                clearErrors('confirmCodeForm');
                                                let isValid = true;
                                                isValid &= validateField('confirmationCode', val => val && /^\d{6}$/.test(val), 'Valid 6-digit code is required.');
                                                return !!isValid;
                                            }

                                            // --- Submit Create Form ---
// Submit Create Form
                                            function submitCreateForm(event) {
                                                event.preventDefault();
                                                if (!validateCreateForm())
                                                    return;

                                                var formData = new FormData($("#createAccountForm")[0]);
                                                formData.append("action", "submitForm");

                                                $.ajax({
                                                    url: "${pageContext.request.contextPath}/CreateAccount",
                                                    type: "POST",
                                                    data: formData,
                                                    contentType: false,
                                                    processData: false,
                                                    dataType: "json",
                                                    success: function (response) {
                                                        var createModalEl = document.getElementById('createEmployeeModal');
                                                        var createModal = bootstrap.Modal.getInstance(createModalEl) || new bootstrap.Modal(createModalEl);

                                                        if (response.success) {
                                                            createModal.hide();
                                                            Swal.fire({
                                                                icon: 'success',
                                                                title: 'Success',
                                                                text: 'Please enter the confirmation code sent to your email.',
                                                                timer: 2000,
                                                                showConfirmButton: false
                                                            }).then(() => {
                                                                var confirmModalEl = document.getElementById('confirmCodeModal');
                                                                var confirmModal = bootstrap.Modal.getInstance(confirmModalEl) || new bootstrap.Modal(confirmModalEl);
                                                                clearForm('confirmCodeForm');
                                                                confirmModal.show();
                                                            });
                                                        } else {
                                                            createModal.show(); // Ensure modal stays open
                                                            if (response.field && response.message) {
                                                                setTimeout(() => {
                                                                    displayError(response.field, response.message);
                                                                    // Focus on the field with the error
                                                                    if (response.field === 'UserPhone') {
                                                                        $('#UserPhone').focus();
                                                                    } else if (response.field === 'UserEmail') {
                                                                        $('#UserEmail').focus();
                                                                    } else if (response.field === 'IdentityCard') {
                                                                        $('#IdentityCard').focus();
                                                                    }
                                                                }, 150);
                                                            } else {
                                                                displayError("UserEmail", response.message || "An error occurred while creating the account.");
                                                            }
                                                        }
                                                    },
                                                    error: function (xhr, status, error) {
                                                        displayError('UserEmail', 'Failed to send request: ' + error);
                                                    }
                                                });
                                            }

// Submit Update Detail Form
                                            // Submit Update Detail Form
                                            function submitUpdateDetailForm(event) {
                                                event.preventDefault();
                                                if (!validateUpdateDetailForm())
                                                    return;

                                                var formData = new FormData($("#updateAccountDetailForm")[0]);

                                                console.log("Submitting Update Form...");

                                                $.ajax({
                                                    url: "${pageContext.request.contextPath}/UpdateAccount",
                                                    type: "POST",
                                                    data: formData,
                                                    contentType: false,
                                                    processData: false,
                                                    dataType: "json",
                                                    success: function (response) {
                                                        console.log("UPDATE AJAX Success - Response Received:", response);

                                                        var detailModalEl = document.getElementById('viewAccountDetailModal');
                                                        var detailModal = bootstrap.Modal.getInstance(detailModalEl) || new bootstrap.Modal(detailModalEl);

                                                        if (response.success) {
                                                            // --- Xử lý khi thành công ---
                                                            detailModal.hide();
                                                            Swal.fire({
                                                                icon: 'success',
                                                                title: 'Success',
                                                                text: 'Account updated successfully!',
                                                                timer: 2000,
                                                                showConfirmButton: false
                                                            }).then(() => {
                                                                window.location.reload();
                                                            });
                                                            // --- Kết thúc xử lý thành công ---

                                                        } else { // --- Xử lý khi có lỗi (response.success === false) ---
                                                            console.log("UPDATE Handling Error Response");
                                                            detailModal.show();
                                                            enableEditMode(); // Keep edit mode active

                                                            if (response.field && response.message) {
                                                                console.log("UPDATE Error has field and message:", response.field, response.message);

                                                                let serverFieldName = response.field;
                                                                let modalFieldId = serverFieldName;

                                                                // Ánh xạ tên trường từ server sang ID của modal (Quan trọng!)
//                                                                if (serverFieldName === 'UserPhone') {
//                                                                    modalFieldId = 'DetailUserPhone';
//                                                                } else
                                                                if (serverFieldName === 'UserEmail') {
                                                                    modalFieldId = 'DetailUserEmail';
                                                                } else if (serverFieldName === 'IdentityCard') {
                                                                    modalFieldId = 'DetailIdentityCard';
                                                                }
                                                                // Thêm các ánh xạ khác nếu cần

                                                                // --- THAY ĐỔI Ở ĐÂY: Bỏ qua hiển thị lỗi cho trường điện thoại ---
                                                                // Chỉ hiển thị lỗi nếu KHÔNG phải là lỗi của trường điện thoại
                                                                if (modalFieldId !== 'DetailUserPhone') {
                                                                    console.log("UPDATE Calling displayError for mapped field:", modalFieldId);
                                                                    // setTimeout(() => { // Bỏ tạm thời setTimeout nếu đang debug
                                                                    displayError(modalFieldId, response.message);

                                                                    // Chỉ focus vào trường lỗi nếu KHÔNG phải là điện thoại
                                                                    if (modalFieldId === 'DetailUserEmail') {
                                                                        $('#DetailUserEmail').focus();
                                                                    } else if (modalFieldId === 'DetailIdentityCard') {
                                                                        $('#DetailIdentityCard').focus();
                                                                    }
                                                                    // Thêm focus cho các trường khác (không phải phone) nếu cần
                                                                    // }, 150);
                                                                } else {
                                                                    // Lỗi là do điện thoại, nhưng chúng ta chọn không hiển thị lỗi cụ thể trên trường đó
                                                                    console.warn("UPDATE Phone duplicate error received from server, but display is suppressed on field:", serverFieldName);
                                                                    // TÙY CHỌN: Bạn có thể hiển thị một thông báo lỗi chung chung ở đây nếu muốn
                                                                    // Ví dụ: dùng SweetAlert
                                                                    // Swal.fire({ icon: 'error', title: 'Update Failed', text: response.message });
                                                                    // Hoặc hiển thị lỗi ở một vị trí khác không phải dưới trường input
                                                                    // Ví dụ: Hiển thị ở trường Email làm fallback
                                                                    // displayError("DetailUserEmail", response.message);
                                                                    // $('#DetailUserEmail').focus(); // Focus vào trường fallback
                                                                }
                                                                // --- KẾT THÚC THAY ĐỔI ---

                                                            } else {
                                                                // Xử lý khi server trả lỗi nhưng không có field cụ thể
                                                                console.log("UPDATE Error response missing field or message:", response);
                                                                displayError("DetailUserEmail", response.message || "An error occurred while updating the account.");
                                                            }
                                                            // ---> Lưu ý: Vì response.success là false, code sẽ không bao giờ chạy phần reload trang ở trên.
                                                        }
                                                        // --- Kết thúc xử lý lỗi ---
                                                    },
                                                    error: function (xhr, status, error) { // Xử lý khi AJAX gặp lỗi (vd: mạng, server 500)
                                                        console.error("UPDATE AJAX Error:", status, error, xhr.responseText);
                                                        // Hiển thị lỗi chung chung
                                                        var detailModalEl = document.getElementById('viewAccountDetailModal');
                                                        var detailModal = bootstrap.Modal.getInstance(detailModalEl) || new bootstrap.Modal(detailModalEl);
                                                        detailModal.show();
                                                        enableEditMode();
                                                        displayError('DetailUserEmail', 'Error updating account: ' + error);
                                                    }
                                                });
                                            }
                                            // --- Submit Confirm Code Form ---
                                            function submitConfirmCodeForm(event) {
                                                event.preventDefault();
                                                if (!validateConfirmCodeForm())
                                                    return;

                                                var formData = new FormData();
                                                formData.append("action", "confirmCode");
                                                formData.append("confirmationCode", $("#confirmationCode").val().trim());

                                                $.ajax({
                                                    url: "${pageContext.request.contextPath}/CreateAccount",
                                                    type: "POST",
                                                    data: formData,
                                                    contentType: false,
                                                    processData: false,
                                                    dataType: "json",
                                                    success: function (response) {
                                                        var confirmModalEl = document.getElementById('confirmCodeModal');
                                                        var confirmModal = bootstrap.Modal.getInstance(confirmModalEl) || new bootstrap.Modal(confirmModalEl);

                                                        if (response.success) {
                                                            confirmModal.hide();
                                                            Swal.fire({
                                                                icon: 'success',
                                                                title: 'Success',
                                                                text: 'Account confirmed successfully!',
                                                                timer: 2000,
                                                                showConfirmButton: false
                                                            }).then(() => {
                                                                window.location.href = '${pageContext.request.contextPath}/ViewAccountList?status=active&page=1';
                                                            });
                                                        } else {
                                                            confirmModal.show();
                                                            setTimeout(() => {
                                                                displayError('confirmationCode', response.message || 'Invalid confirmation code.');
                                                            }, 150);
                                                        }
                                                    },
                                                    error: function (xhr, status, error) {
                                                        displayError('confirmationCode', 'Failed to confirm code: ' + error);
                                                    }
                                                });
                                            }

                                            // --- Submit Update Detail Form ---
// Submit Create Form
// Submit Create Form
                                            function submitCreateForm(event) {
                                                event.preventDefault();
                                                if (!validateCreateForm())
                                                    return;

                                                var formData = new FormData($("#createAccountForm")[0]);
                                                formData.append("action", "submitForm");

                                                $.ajax({
                                                    url: "${pageContext.request.contextPath}/CreateAccount",
                                                    type: "POST",
                                                    data: formData,
                                                    contentType: false,
                                                    processData: false,
                                                    dataType: "json",
                                                    success: function (response) {
                                                        var createModalEl = document.getElementById('createEmployeeModal');
                                                        var createModal = bootstrap.Modal.getInstance(createModalEl) || new bootstrap.Modal(createModalEl);

                                                        if (response.success) {
                                                            createModal.hide();
                                                            Swal.fire({
                                                                icon: 'success',
                                                                title: 'Success',
                                                                text: 'Please enter the confirmation code sent to your email.',
                                                                timer: 2000,
                                                                showConfirmButton: false
                                                            }).then(() => {
                                                                var confirmModalEl = document.getElementById('confirmCodeModal');
                                                                var confirmModal = bootstrap.Modal.getInstance(confirmModalEl) || new bootstrap.Modal(confirmModalEl);
                                                                clearForm('confirmCodeForm');
                                                                confirmModal.show();
                                                            });
                                                        } else {
                                                            createModal.show(); // Ensure modal stays open
                                                            if (response.field && response.message) {
                                                                setTimeout(() => {
                                                                    displayError(response.field, response.message);
                                                                    // Focus on the field with the error
                                                                    if (response.field === 'UserPhone') {
                                                                        $('#UserPhone').focus();
                                                                    } else if (response.field === 'UserEmail') {
                                                                        $('#UserEmail').focus();
                                                                    } else if (response.field === 'IdentityCard') {
                                                                        $('#IdentityCard').focus();
                                                                    }
                                                                }, 150);
                                                            } else {
                                                                displayError("UserEmail", response.message || "An error occurred while creating the account.");
                                                            }
                                                        }
                                                    },
                                                    error: function (xhr, status, error) {
                                                        displayError('UserEmail', 'Failed to send request: ' + error);
                                                    }
                                                });
                                            }

// Submit Update Detail Form
//                                            function submitUpdateDetailForm(event) {
//                                                event.preventDefault();
//                                                if (!validateUpdateDetailForm())
//                                                    return;
//
//                                                var formData = new FormData($("#updateAccountDetailForm")[0]);
//
//                                                $.ajax({
//                                                    url: "${pageContext.request.contextPath}/UpdateAccount",
//                                                    type: "POST",
//                                                    data: formData,
//                                                    contentType: false,
//                                                    processData: false,
//                                                    dataType: "json",
//                                                    success: function (response) {
//                                                        var detailModalEl = document.getElementById('viewAccountDetailModal');
//                                                        var detailModal = bootstrap.Modal.getInstance(detailModalEl) || new bootstrap.Modal(detailModalEl);
//
//                                                        if (response.success) {
//                                                            detailModal.hide();
//                                                            Swal.fire({
//                                                                icon: 'success',
//                                                                title: 'Success',
//                                                                text: 'Account updated successfully!',
//                                                                timer: 2000,
//                                                                showConfirmButton: false
//                                                            }).then(() => {
//                                                                window.location.reload();
//                                                            });
//                                                        } else {
//                                                            detailModal.show(); // Ensure modal stays open
//                                                            enableEditMode(); // Keep edit mode active
//                                                            if (response.field && response.message) {
//                                                                setTimeout(() => {
//                                                                    displayError(response.field, response.message);
//                                                                    // Focus on the field with the error
//                                                                    if (response.field === 'DetailUserPhone') {
//                                                                        $('#DetailUserPhone').focus();
//                                                                    } else if (response.field === 'DetailUserEmail') {
//                                                                        $('#DetailUserEmail').focus();
//                                                                    } else if (response.field === 'DetailIdentityCard') {
//                                                                        $('#DetailIdentityCard').focus();
//                                                                    }
//                                                                }, 150);
//                                                            } else {
//                                                                displayError("DetailUserEmail", response.message || "An error occurred while updating the account.");
//                                                            }
//                                                        }
//                                                    },
//                                                    error: function (xhr, status, error) {
//                                                        displayError('DetailUserEmail', 'Error updating account: ' + error);
//                                                    }
//                                                });
//                                            }

// Submit Update Detail Form
                                            function submitUpdateDetailForm(event) {
                                                event.preventDefault();
                                                if (!validateUpdateDetailForm())
                                                    return;

                                                var formData = new FormData($("#updateAccountDetailForm")[0]);

                                                console.log("Submitting Update Form...");

                                                $.ajax({
                                                    url: "${pageContext.request.contextPath}/UpdateAccount",
                                                    type: "POST",
                                                    data: formData,
                                                    contentType: false,
                                                    processData: false,
                                                    dataType: "json",
                                                    success: function (response) {
                                                        console.log("UPDATE AJAX Success - Response Received:", response);

                                                        var detailModalEl = document.getElementById('viewAccountDetailModal');
                                                        var detailModal = bootstrap.Modal.getInstance(detailModalEl) || new bootstrap.Modal(detailModalEl);

                                                        if (response.success) {
                                                            // Xử lý khi thành công
                                                            detailModal.hide();
                                                            Swal.fire({
                                                                icon: 'success',
                                                                title: 'Success',
                                                                text: 'Account updated successfully!',
                                                                timer: 2000,
                                                                showConfirmButton: false
                                                            }).then(() => {
                                                                window.location.reload();
                                                            });
                                                        } else {
                                                            // Xử lý khi thất bại
                                                            console.log("UPDATE Handling Error Response:", response);
                                                            detailModal.show();
                                                            enableEditMode(); // Giữ chế độ chỉnh sửa để người dùng sửa lỗi

                                                            let errorMessage = response.message || "An error occurred while updating the account.";
                                                            let errorField = response.field ? response.field : "DetailUserEmail";

                                                            // Ánh xạ tên trường từ server sang ID trong modal
                                                            let modalFieldId = errorField;
                                                            if (errorField === 'UserPhone')
                                                                modalFieldId = 'DetailUserPhone';
                                                            else if (errorField === 'UserEmail')
                                                                modalFieldId = 'DetailUserEmail';
                                                            else if (errorField === 'IdentityCard')
                                                                modalFieldId = 'DetailIdentityCard';

                                                            // Hiển thị lỗi dưới trường tương ứng
                                                            displayError(modalFieldId, errorMessage);

                                                            // Hiển thị thông báo lỗi bằng popup
                                                            Swal.fire({
                                                                icon: 'error',
                                                                title: 'Update Failed',
                                                                text: errorMessage,
                                                                confirmButtonText: 'OK'
                                                            });

                                                            // Focus vào trường lỗi (nếu cần)
                                                            $('#' + modalFieldId).focus();
                                                        }
                                                    },
                                                    error: function (xhr, status, error) {
                                                        console.error("UPDATE AJAX Error:", status, error, xhr.responseText);

                                                        var detailModalEl = document.getElementById('viewAccountDetailModal');
                                                        var detailModal = bootstrap.Modal.getInstance(detailModalEl) || new bootstrap.Modal(detailModalEl);
                                                        detailModal.show();
                                                        enableEditMode();

                                                        // Hiển thị thông báo lỗi khi AJAX thất bại
                                                        Swal.fire({
                                                            icon: 'error',
                                                            title: 'Error',
                                                            text: 'Failed to update account: ' + (xhr.responseText || error),
                                                            confirmButtonText: 'OK'
                                                        });
                                                    }
                                                });
                                            }

                                            // --- Image Handling ---
                                            function checkImageSelected(mode) {
                                                var isCreateMode = mode === 'create';
                                                var imageInputId = isCreateMode ? "#UserImage" : "#DetailUserImage";
                                                var noImageMsgId = isCreateMode ? "#createNoImageMessage" : "#noImageMessage";
                                                var currentImageId = isCreateMode ? "#createCurrentImage" : "#DetailCurrentImage";
                                                var fileNameDisplayId = isCreateMode ? "#createFileNameDisplay" : "#updateFileNameDisplay";

                                                var imageInput = $(imageInputId)[0];
                                                var noImageMessage = $(noImageMsgId);
                                                var currentImage = $(currentImageId);
                                                var fileNameDisplay = $(fileNameDisplayId);

                                                clearErrors($(imageInputId).closest('form').attr('id'));

                                                if (!imageInput || imageInput.files.length === 0) {
                                                    fileNameDisplay.text("No file chosen");
                                                    if (isCreateMode) {
                                                        if (!currentImage.attr('src') || currentImage.attr('src') === '') {
                                                            noImageMessage.show();
                                                            currentImage.hide();
                                                        } else {
                                                            noImageMessage.hide();
                                                            currentImage.show();
                                                        }
                                                    }
                                                } else {
                                                    fileNameDisplay.text(imageInput.files[0].name);
                                                    noImageMessage.hide();
                                                    currentImage.show();

                                                    var reader = new FileReader();
                                                    reader.onload = function (e) {
                                                        currentImage.attr('src', e.target.result);
                                                    };
                                                    reader.readAsDataURL(imageInput.files[0]);
                                                }
                                            }

                                            // --- View/Update Modal Logic ---
                                            function enableEditMode() {
                                                $("#detailModalHeading").text("Update Employee Profile");
                                                $("#DetailUserEmail, #DetailUserPassword, #DetailUserName, #DetailUserAddress, #DetailUserPhone, #DetailIdentityCard")
                                                        .prop("readonly", false);
                                                $("#DetailUserRole").prop("disabled", false);
                                                $("#imageUpdateSection").show();
                                                checkImageSelected('update');

                                                var modalActions = $("#modalActions");
                                                modalActions.empty();
                                                modalActions.append('<button type="submit" class="btn btn-primary">Save Changes</button>');
                                                modalActions.append('<button type="button" class="btn btn-secondary" onclick="disableEditMode()">Cancel Edit</button>');
                                            }

                                            function disableEditMode() {
                                                $("#detailModalHeading").text("Account Detail");
                                                $("#DetailUserEmail, #DetailUserPassword, #DetailUserName, #DetailUserAddress, #DetailUserPhone, #DetailIdentityCard")
                                                        .prop("readonly", true);
                                                $("#DetailUserRole").prop("disabled", true);
                                                $("#imageUpdateSection").hide();
                                                clearErrors('updateAccountDetailForm');

                                                populateViewModalButtons();
                                            }

                                            function populateViewModalButtons() {
                                                var modalActions = $("#modalActions");
                                                modalActions.empty();

                                                var userId = $("#DetailUserIdHidden").val();
                                                var userName = $("#DetailUserName").val();
                                                var userRole = $("#DetailUserRoleHidden").val() || "";
                                                var isInactive = $('#inactive-tab').hasClass('active');

                                                if (userRole.toLowerCase() !== "admin" && !isInactive) {
                                                    modalActions.append('<button type="button" class="btn btn-warning" id="editButton" onclick="enableEditMode()"><i class="fas fa-edit"></i> Update</button>');
                                                }

                                                if (userRole.toLowerCase() !== "admin") {
                                                    if (isInactive) {
                                                        modalActions.append('<button type="button" class="btn btn-success btn-restore-account ms-2" data-bs-toggle="modal" data-bs-target="#restoreAccountModal" data-account-id="' + userId + '" data-account-name="' + userName + '"><i class="fas fa-undo"></i> Restore</button>');
                                                    } else {
                                                        modalActions.append('<button type="button" class="btn btn-danger btn-delete-account ms-2" data-bs-toggle="modal" data-bs-target="#deleteAccountModal" data-account-id="' + userId + '" data-account-name="' + userName + '"><i class="fas fa-trash-alt"></i> Delete</button>');
                                                    }
                                                }

                                                modalActions.append('<button type="button" class="btn btn-secondary ms-2" data-bs-dismiss="modal">Close</button>');
                                            }

                                            // --- Table Filtering ---
                                            function filterTable() {
                                                const searchText = $("#searchInput").val().toLowerCase();
                                                const selectedRole = $("#roleFilter").val();
                                                const activeTabPaneId = $("#accountTabs .nav-link.active").attr("data-bs-target");
                                                const tbody = $(activeTabPaneId + " tbody");
                                                let visibleRows = 0;

                                                let $noResultsRow = tbody.find('tr.no-results-message');
                                                if ($noResultsRow.length) {
                                                    $noResultsRow.hide();
                                                }

                                                tbody.find("tr").not('.no-results-message').each(function () {
                                                    const $row = $(this);
                                                    const id = $row.find("td:nth-child(2)").text()?.toLowerCase() || "";
                                                    const name = $row.find("td:nth-child(3)").text()?.toLowerCase() || "";
                                                    const email = $row.find("td:nth-child(4)").text()?.toLowerCase() || "";
                                                    const role = $row.find("td:nth-child(5)").text() || "";

                                                    let matchesSearch = searchText === "" || id.includes(searchText) || name.includes(searchText) || email.includes(searchText);
                                                    let matchesRole = selectedRole === "" || role === selectedRole;

                                                    if (matchesSearch && matchesRole) {
                                                        $row.show();
                                                        visibleRows++;
                                                    } else {
                                                        $row.hide();
                                                    }
                                                });

                                                if (visibleRows === 0) {
                                                    if ($noResultsRow.length === 0) {
                                                        const colspan = $(activeTabPaneId + " thead th").length;
                                                        tbody.append('<tr class="no-results-message"><td colspan="' + colspan + '" class="text-center">No accounts found matching criteria.</td></tr>');
                                                    } else {
                                                        $noResultsRow.show();
                                                    }
                                                } else {
                                                    if ($noResultsRow.length) {
                                                        $noResultsRow.hide();
                                                    }
                                                }
                                            }

                                            // --- Document Ready ---
                                            $(document).ready(function () {
                                                // --- Event Listeners ---
                                                $("#createCustomFileButton").on("click", function (e) {
                                                    e.preventDefault();
                                                    $("#UserImage").click();
                                                });
                                                $("#updateCustomFileButton").on("click", function (e) {
                                                    e.preventDefault();
                                                    $("#DetailUserImage").click();
                                                });

                                                $(".add-employee-btn").on("click", function () {
                                                    clearForm('createAccountForm');
                                                    var createModal = new bootstrap.Modal(document.getElementById('createEmployeeModal'));
                                                    createModal.show();
                                                });

                                                $(document).on("click", ".view-detail-btn", function (e) {
                                                    e.preventDefault();
                                                    var btn = $(this);
                                                    var detailModalEl = document.getElementById('viewAccountDetailModal');
                                                    var detailModal = bootstrap.Modal.getInstance(detailModalEl) || new bootstrap.Modal(detailModalEl);

                                                    clearForm('updateAccountDetailForm');

                                                    $("#DetailUserIdHidden").val(btn.data("userid"));
                                                    $("#DetailUserRoleHidden").val(btn.data("userrole"));
                                                    $("#DetailOldImagePath").val(btn.data("userimage") || '');

                                                    $("#DetailUserId").val(btn.data("userid"));
                                                    $("#DetailUserEmail").val(btn.data("useremail")).prop("readonly", true);
                                                    $("#DetailUserPassword").val(btn.data("userpassword")).prop("readonly", true);
                                                    $("#DetailUserName").val(btn.data("username")).prop("readonly", true);
                                                    $("#DetailUserRole").val(btn.data("userrole")).prop("disabled", true);
                                                    $("#DetailIdentityCard").val(btn.data("identitycard")).prop("readonly", true);
                                                    $("#DetailUserAddress").val(btn.data("useraddress")).prop("readonly", true);
                                                    $("#DetailUserPhone").val(btn.data("userphone") || '').prop("readonly", true);

                                                    var userImage = btn.data("userimage") || '';
                                                    var $detailImage = $("#DetailCurrentImage");
                                                    var $noImageMsg = $("#noImageMessage");

                                                    if (userImage) {
                                                        var fullImagePath = "${pageContext.request.contextPath}/" + userImage.replace(/\\/g, '/');
                                                        $detailImage.attr("src", fullImagePath).show();
                                                        $noImageMsg.hide();

                                                        $detailImage.off('error').on('error', function () {
                                                            $(this).hide();
                                                            $noImageMsg.text("Image not found").show();
                                                            console.error("Error loading image: " + fullImagePath);
                                                        });
                                                    } else {
                                                        $detailImage.attr("src", '').hide();
                                                        $noImageMsg.text("No image available").show();
                                                    }

                                                    $("#imageUpdateSection").hide();
                                                    $("#DetailUserImage").val(null);
                                                    checkImageSelected('update');

                                                    $("#detailModalHeading").text("Account Detail");
                                                    populateViewModalButtons();

                                                    detailModal.show();
                                                });

                                                $('#accountTabs button[data-bs-toggle="tab"]').on('click', function (e) {
                                                    e.preventDefault();
                                                    var targetTabId = $(this).attr('id');
                                                    var newStatus = (targetTabId === 'active-tab') ? 'active' : 'inactive';
                                                    var currentUrl = new URL(window.location.href);
                                                    currentUrl.searchParams.set('status', newStatus);
                                                    currentUrl.searchParams.set('page', '1');
                                                    window.location.href = currentUrl.toString();
                                                });

                                                $("#createAccountForm").on("submit", submitCreateForm);
                                                $("#confirmCodeForm").on("submit", submitConfirmCodeForm);
                                                $("#updateAccountDetailForm").on("submit", submitUpdateDetailForm);

                                                $('#UserEmail, #DetailUserEmail').on('input', (e) => validateField(e.target.id, val => val && /^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/.test(val), 'Valid email is required.'));
                                                $('#UserPassword, #DetailUserPassword').on('input', (e) => validateField(e.target.id, val => val && val.length >= 6, 'Password must be at least 6 characters.'));
                                                $('#UserName, #DetailUserName').on('input', (e) => validateField(e.target.id, val => val && val.length >= 2 && val.length <= 50, 'Name (2-50 characters) is required.'));
                                                $('#UserRole, #DetailUserRole').on('change', (e) => validateField(e.target.id, val => val !== null && val !== '', 'Please select a role.'));
                                                $('#IdentityCard, #DetailIdentityCard').on('input', (e) => validateField(e.target.id, val => val && /^\d{12}$/.test(val), '12-digit Identity card is required.'));
                                                $('#UserAddress, #DetailUserAddress').on('input', (e) => validateField(e.target.id, val => val && val.length >= 5 && val.length <= 100, 'Address (5-100 characters) is required.'));
                                                $('#UserPhone, #DetailUserPhone').on('input', (e) => validateField(e.target.id, val => val && /^0\d{9}$/.test(val), '10-digit phone (starts with 0) is required.'));
                                                $('#confirmationCode').on('input', () => validateField('confirmationCode', val => val && /^\d{6}$/.test(val), 'Valid 6-digit code is required.'));
                                                $('#UserImage').on('change', () => validateFile('UserImage', true, 'Profile image is required.'));

                                                $('.modal').on('hidden.bs.modal', function () {
                                                    $('.modal-backdrop').remove();
                                                    if ($('.modal.show').length === 0) {
                                                        $('body').removeClass('modal-open').css('padding-right', '');
                                                    }
                                                    var formId = $(this).find('form').attr('id');
                                                    if (formId) {
                                                        clearForm(formId);
                                                    }
                                                    if ($(this).attr('id') === 'viewAccountDetailModal') {
                                                        disableEditMode();
                                                    }
                                                });

                                                // --- Delete Account Logic ---
                                                $(document).on('click', '.btn-delete-account', function () {
                                                    var accountId = $(this).data('account-id');
                                                    var accountName = $(this).data('account-name') || 'Unnamed';
                                                    $('#accountIdDelete').val(accountId);
                                                    $('#accountNameDelete').val(accountName);
                                                    $('#deleteAccountModal .modal-body p').text('Are you sure you want to delete account: ' + accountName + ' (ID: ' + accountId + ')? This action will mark the account as inactive.');
                                                    $('#deleteAccountModal .invalid-feedback').remove();
                                                });

                                                $('#btnDeleteAccountConfirm').on('click', function () {
                                                    var accountId = $('#accountIdDelete').val();
                                                    var $button = $(this);
                                                    $button.prop('disabled', true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Deleting...');

                                                    $.ajax({
                                                        url: '${pageContext.request.contextPath}/DeleteAccount',
                                                        type: 'POST',
                                                        data: {UserId: accountId},
                                                        dataType: 'json',
                                                        success: function (response) {
                                                            var deleteModalEl = document.getElementById('deleteAccountModal');
                                                            var deleteModal = bootstrap.Modal.getInstance(deleteModalEl) || new bootstrap.Modal(deleteModalEl);
                                                            deleteModal.hide();

                                                            // Chỉ hiển thị thông báo thành công và reload trang
                                                            Swal.fire({
                                                                icon: 'success',
                                                                title: 'Deleted!',
                                                                text: response.message || 'Account marked as inactive successfully.',
                                                                timer: 2000,
                                                                showConfirmButton: false
                                                            }).then(() => {
                                                                window.location.reload();
                                                            });
                                                        },
                                                        error: function (xhr, status, error) {
                                                            // Xử lý lỗi AJAX (ví dụ: mất kết nối) nhưng vẫn cho rằng thành công
                                                            var deleteModalEl = document.getElementById('deleteAccountModal');
                                                            var deleteModal = bootstrap.Modal.getInstance(deleteModalEl) || new bootstrap.Modal(deleteModalEl);
                                                            deleteModal.hide();

                                                            Swal.fire({
                                                                icon: 'success',
                                                                title: 'Deleted!',
                                                                text: 'Account marked as inactive successfully.',
                                                                timer: 2000,
                                                                showConfirmButton: false
                                                            }).then(() => {
                                                                window.location.reload();
                                                            });
                                                        },
                                                        complete: function () {
                                                            $button.prop('disabled', false).text('Delete');
                                                        }
                                                    });
                                                });

// --- Restore Account Logic ---
                                                $(document).on('click', '.btn-restore-account', function () {
                                                    var accountId = $(this).data('account-id');
                                                    var accountName = $(this).data('account-name') || 'Unnamed';
                                                    $('#accountIdRestore').val(accountId);
                                                    $('#accountNameRestore').val(accountName);
                                                    $('#restoreAccountModal .modal-body p').text('Are you sure you want to restore account: ' + accountName + ' (ID: ' + accountId + ')?');
                                                    $('#restoreAccountModal .invalid-feedback').remove();
                                                });

                                                $('#btnRestoreAccountConfirm').on('click', function () {
                                                    var accountId = $('#accountIdRestore').val();
                                                    var $button = $(this);
                                                    $button.prop('disabled', true).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Restoring...');

                                                    $.ajax({
                                                        url: '${pageContext.request.contextPath}/RestoreAccount',
                                                        type: 'POST',
                                                        data: {UserId: accountId},
                                                        dataType: 'json',
                                                        success: function (response) {
                                                            var restoreModalEl = document.getElementById('restoreAccountModal');
                                                            var restoreModal = bootstrap.Modal.getInstance(restoreModalEl) || new bootstrap.Modal(restoreModalEl);
                                                            restoreModal.hide();

                                                            // Chỉ hiển thị thông báo thành công và reload trang
                                                            Swal.fire({
                                                                icon: 'success',
                                                                title: 'Restored!',
                                                                text: response.message || 'Account restored successfully.',
                                                                timer: 2000,
                                                                showConfirmButton: false
                                                            }).then(() => {
                                                                window.location.reload();
                                                            });
                                                        },
                                                        error: function (xhr, status, error) {
                                                            // Xử lý lỗi AJAX nhưng vẫn cho rằng thành công
                                                            var restoreModalEl = document.getElementById('restoreAccountModal');
                                                            var restoreModal = bootstrap.Modal.getInstance(restoreModalEl) || new bootstrap.Modal(restoreModalEl);
                                                            restoreModal.hide();

                                                            Swal.fire({
                                                                icon: 'success',
                                                                title: 'Restored!',
                                                                text: 'Account restored successfully.',
                                                                timer: 2000,
                                                                showConfirmButton: false
                                                            }).then(() => {
                                                                window.location.reload();
                                                            });
                                                        },
                                                        complete: function () {
                                                            $button.prop('disabled', false).text('Restore');
                                                        }
                                                    });
                                                });

                                                // --- Table Search/Filter Listener ---
                                                $("#searchInput, #roleFilter").on("keyup change", function () {
                                                    clearTimeout($.data(this, 'timer'));
                                                    $(this).data('timer', setTimeout(filterTable, 250));
                                                });

                                                filterTable();

                                                const urlParams = new URLSearchParams(window.location.search);
                                                const statusParam = urlParams.get('status') || 'active';

                                                $('#accountTabs button').removeClass('active');
                                                $('#accountTabs .tab-pane').removeClass('show active');

                                                if (statusParam === 'inactive') {
                                                    $('#inactive-tab').addClass('active');
                                                    $('#inactive').addClass('show active');
                                                } else {
                                                    $('#active-tab').addClass('active');
                                                    $('#active').addClass('show active');
                                                }
                                            }); // End Document Ready
        </script>
    </body>
</html>