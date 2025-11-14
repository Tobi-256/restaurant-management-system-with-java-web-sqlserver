<%@page import="Model.Account"%>
<%@page import="java.util.List"%>
<%@page import="Model.Customer"%>
<%@ page contentType="text/html" pageEncoding="UTF-8"%>

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
        <title>Customer Management</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
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
            .table th.actions-column, .table td.actions-column {
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
            .controls-container form {
                flex: 1;
                display: flex;
                gap: 10px;
            }
            .btn-edit {
                background-color: #007bff;
                color: white;
                padding: 5px 10px;
                text-decoration: none;
                border: none;
                transition: background-color 0.3s;
            }
            .btn-edit:hover {
                background-color: #0056b3;
                color: white;
            }
            .btn-delete {
                background-color: #dc3545;
                color: white;
                padding: 5px 10px;
                margin-left: 5px;
                border: none;
                transition: background-color 0.3s;
            }
            .btn-delete:hover {
                background-color: #c82333;
                color: white;
            }
            .modal-header {
                background-color: #f7f7f0;
            }
            .content-title {
                overflow: hidden;
                background: linear-gradient(to right, #2C3E50, #42A5F5);
                padding: 1rem;
                color: white;
                margin-bottom: 20px;
                margin-left: -25px;
                margin-right: -20px;
                margin-top: -24px;
                border-radius: 0;
            }
        </style>
    </head>
    <body>
        <!-- Sidebar -->
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
                    <li class="nav-item"><a href="${pageContext.request.contextPath}/ViewCustomerList" class="nav-link active"><i class="fas fa-user-friends me-2"></i>Customer Management</a></li>
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
                <div class="content-title">
                    <h4>Customer Management</h4>
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

                <div class="controls-container">
                    <form id="searchForm" class="row g-3">
                        <div class="col-auto">
                            <input type="text" class="form-control" id="searchInput" placeholder="Search by ID, Name, or Phone">
                        </div>
                    </form>
                    <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#addCustomerModal">
                        <i class="fas fa-plus me-2"></i>Add New
                    </button>
                </div>

                <div id="customerListContainer">
                    <%
                        List<Customer> customerList = (List<Customer>) request.getAttribute("customerList");
                        if (customerList != null && !customerList.isEmpty()) {
                    %>
                    <table class="table table-bordered table-hover">
                        <thead class="thead-dark">
                            <tr>
                                <th>No.</th>
                                <th>Customer ID</th>
                                <th>Customer Name</th>
                                <th>Customer Phone</th>
                                <th>Number of Payments</th>
                                <th class="actions-column">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="customerTableBody">
                            <%
                                int displayIndex = 1;
                                for (Customer customer : customerList) {
                            %>
                            <tr id="customerRow<%=customer.getCustomerId()%>">
                                <td><%= displayIndex++%></td>
                                <td><%= customer.getCustomerId()%></td>
                                <td><%= customer.getCustomerName()%></td>
                                <td><%= customer.getCustomerPhone()%></td>
                                <td><%= customer.getNumberOfPayment()%></td>
                                <td class="actions-column">
                                    <button type="button" class="btn btn-edit btn-update-customer"
                                            data-bs-toggle="modal" data-bs-target="#updateCustomerModal"
                                            data-customer-id="<%= customer.getCustomerId()%>"
                                            data-customer-name="<%= customer.getCustomerName()%>"
                                            data-customer-phone="<%= customer.getCustomerPhone()%>"
                                            data-number-of-payment="<%= customer.getNumberOfPayment()%>">
                                        <i class="fas fa-edit"></i> Update
                                    </button>
                                    <button type="button" class="btn btn-delete btn-delete-customer"
                                            data-bs-toggle="modal" data-bs-target="#deleteCustomerModal"
                                            data-customer-id="<%= customer.getCustomerId()%>">
                                        <i class="fas fa-trash-alt"></i> Delete
                                    </button>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                    <div class="pagination" id="pagination"></div>
                    <% } else { %>
                    <p class="text-muted">No customers available.</p>
                    <% }%>
                </div>
            </div>
        </div>

        <!-- Add Customer Modal -->
        <div class="modal fade" id="addCustomerModal" tabindex="-1" aria-labelledby="addCustomerModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="addCustomerModalLabel">Add New Customer</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="addCustomerForm">
                            <div class="mb-3 row">
                                <label for="customerName" class="col-sm-4 col-form-label">Customer Name:</label>
                                <div class="col-sm-8">
                                    <input type="text" class="form-control" id="customerName" name="CustomerName" required>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="customerPhone" class="col-sm-4 col-form-label">Customer Phone:</label>
                                <div class="col-sm-8">
                                    <input type="number" class="form-control" id="customerPhone" name="CustomerPhone" required>
                                    <small class="text-muted">Enter customer phone number.</small>
                                </div>
                            </div>
                            <input type="hidden" id="numberOfPayment" name="NumberOfPayment" value="0">
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-primary" id="btnAddCustomer">Add Customer</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Update Customer Modal -->
        <div class="modal fade" id="updateCustomerModal" tabindex="-1" aria-labelledby="updateCustomerModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="updateCustomerModalLabel">Update Customer</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="updateCustomerForm">
                            <div class="mb-3 row">
                                <label for="customerIdUpdateDisplay" class="col-sm-4 col-form-label">Customer ID:</label>
                                <div class="col-sm-8">
                                    <input type="text" class="form-control" id="customerIdUpdateDisplay" readonly>
                                    <input type="hidden" id="customerIdUpdate" name="customerId">
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="customerNameUpdate" class="col-sm-4 col-form-label">Customer Name:</label>
                                <div class="col-sm-8">
                                    <input type="text" class="form-control" id="customerNameUpdate" name="CustomerName" required>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="customerPhoneUpdate" class="col-sm-4 col-form-label">Customer Phone:</label>
                                <div class="col-sm-8">
                                    <input type="number" class="form-control" id="customerPhoneUpdate" name="CustomerPhone" required>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-primary" id="btnUpdateCustomer">Save Changes</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Delete Customer Modal -->
        <div class="modal fade" id="deleteCustomerModal" tabindex="-1" aria-labelledby="deleteCustomerModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="deleteCustomerModalLabel">Confirm Delete</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>Are you sure you want to mark this customer as deleted?</p>
                        <input type="hidden" id="customerIdDelete">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-danger" id="btnDeleteCustomerConfirm">Delete</button>
                    </div>
                </div>
            </div>
        </div>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
        <script>
            $(document).ready(function () {
                const itemsPerPage = 10;
                let currentPage = 1;
                let rows = []; // Khởi tạo mảng rows toàn cục

                bindEventHandlers();
                reloadViewCustomer();

                // Sự kiện tìm kiếm
                const searchInput = document.getElementById('searchInput');
                searchInput.addEventListener('keyup', filterAndSortTable);

                // Sự kiện nút Add Customer
                $(document).on('click', '#btnAddCustomer', function () {
                    var customerName = $('#customerName').val().trim();
                    var customerPhone = $('#customerPhone').val().trim();
                    var numberOfPayment = $('#numberOfPayment').val();

                    var isValid = true;
                    $('.error-message').remove();
                    $('.is-invalid').removeClass('is-invalid');

                    if (!customerName) {
                        isValid = false;
                        displayError('customerName', 'Please enter customer name');
                    } else if (customerName.length > 50) {
                        isValid = false;
                        displayError('customerName', 'Customer name cannot exceed 50 characters');
                    }
                    customerPhone = String(customerPhone); // Chuyển thành chuỗi
                    if (!customerPhone || !/^\d{10}$/.test(customerPhone) || !customerPhone.startsWith('0')) {
                        isValid = false;
                        displayError('customerPhone', 'Phone must be 10 digits and start with 0');
                    }

                    if (isValid) {
                        $.ajax({
                            url: 'AddCustomer',
                            type: 'POST',
                            data: {CustomerName: customerName, CustomerPhone: customerPhone, NumberOfPayment: numberOfPayment},
                            success: function (response) {
                                console.log("AddCustomer response:", response);
                                $('#addCustomerModal').modal('hide');
                                reloadViewCustomer();
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: 'Customer added successfully.',
                                    timer: 2000,
                                    showConfirmButton: false
                                });
                                $('#addCustomerForm')[0].reset();
                            },
                            error: function (xhr) {
                                console.error("AddCustomer error:", xhr.responseText);
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Sorry!',
                                    text: xhr.responseText || 'An error occurred. Please try again.',
                                    confirmButtonColor: '#dc3545'
                                });
                            }
                        });
                    }
                });

                // Sự kiện nút Update Customer
                $(document).on('click', '#btnUpdateCustomer', function () {
                    var customerId = $('#customerIdUpdate').val();
                    var customerName = $('#customerNameUpdate').val().trim();
                    var customerPhone = $('#customerPhoneUpdate').val().trim();

                    var isValid = true;
                    $('.error-message').remove();
                    $('.is-invalid').removeClass('is-invalid');

                    if (!customerName) {
                        isValid = false;
                        displayError('customerNameUpdate', 'Please enter customer name');
                    } else if (customerName.length > 50) {
                        isValid = false;
                        displayError('customerNameUpdate', 'Customer name cannot exceed 50 characters');
                    }
                    customerPhone = String(customerPhone); // Chuyển thành chuỗi
                    if (!customerPhone || !/^\d{10}$/.test(customerPhone) || !customerPhone.startsWith('0')) {
                        isValid = false;
                        displayError('customerPhoneUpdate', 'Phone must be 10 digits and start with 0');
                    }

                    if (isValid) {
                        $.ajax({
                            url: 'UpdateCustomer',
                            type: 'POST',
                            data: {customerId: customerId, CustomerName: customerName, CustomerPhone: customerPhone},
                            success: function (response) {
                                console.log("UpdateCustomer response:", response);
                                $('#updateCustomerModal').modal('hide');
                                reloadViewCustomer();
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: 'Customer updated successfully.',
                                    timer: 2000,
                                    showConfirmButton: false
                                });
                            },
                            error: function (xhr) {
                                console.error("UpdateCustomer error:", xhr.responseText);
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Sorry!',
                                    text: xhr.responseText || 'An error occurred. Please try again.',
                                    confirmButtonColor: '#dc3545'
                                });
                            }
                        });
                    }
                });

                // Sự kiện nút Delete Customer
                $(document).on('click', '#btnDeleteCustomerConfirm', function () {
                    var customerId = $('#customerIdDelete').val();
                    $.ajax({
                        url: 'DeleteCustomer',
                        type: 'GET',
                        data: {customerId: customerId},
                        success: function (response) {
                            $('#deleteCustomerModal').modal('hide');
                            $('#customerRow' + customerId).remove();
                            if ($('#customerTableBody tr').length === 0) {
                                $('#customerTableBody').html('<tr><td colspan="6"><div class="no-data">Customer Not Found.</div></td></tr>');
                            }
                            reloadViewCustomer();
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Customer marked as deleted.',
                                timer: 2000,
                                showConfirmButton: false
                            });
                        },
                        error: function (xhr) {
                            $('#deleteCustomerModal').modal('hide');
                            Swal.fire({
                                icon: 'error',
                                title: 'Sorry!',
                                text: xhr.responseText || 'An error occurred. Please try again.',
                                confirmButtonColor: '#dc3545'
                            });
                        }
                    });
                });

                function filterAndSortTable() {
                    const searchText = searchInput.value.toLowerCase();

                    let filteredRows = rows.filter(row => {
                        const customerId = row.cells[1].textContent.toLowerCase();
                        const customerName = row.cells[2].textContent.toLowerCase();
                        const customerPhone = row.cells[3].textContent.toLowerCase();
                        return customerId.includes(searchText) || customerName.includes(searchText) || customerPhone.includes(searchText);
                    });

                    renderTable(filteredRows);
                }

                function renderTable(filteredRows) {
                    const start = (currentPage - 1) * itemsPerPage;
                    const end = start + itemsPerPage;
                    const paginatedRows = filteredRows.slice(start, end);

                    const customerTableBody = document.getElementById('customerTableBody');
                    customerTableBody.innerHTML = '';
                    paginatedRows.forEach(row => customerTableBody.appendChild(row));

                    renderPagination(filteredRows.length);
                }

                function renderPagination(totalItems) {
                    const totalPages = Math.ceil(totalItems / itemsPerPage);
                    const pagination = document.getElementById('pagination');
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

                function reloadViewCustomer() {
                    $.get('ViewCustomerList', function (data) {
                        var newBody = $(data).find('#customerTableBody').html();
                        console.log("New table body content:", newBody);
                        $('#customerTableBody').html(newBody);
                        rows = Array.from(document.getElementById('customerTableBody').querySelectorAll('tr')); // Cập nhật rows
                        bindEventHandlers();
                        filterAndSortTable();
                    }).fail(function (xhr) {
                        console.error('Error reloading customer list:', xhr.responseText);
                    });
                }

                function bindEventHandlers() {
                    $(document).on('click', '.btn-update-customer', function () {
                        var customerId = $(this).data('customer-id');
                        var customerName = $(this).data('customer-name');
                        var customerPhone = $(this).data('customer-phone');
                        $('#customerIdUpdate').val(customerId);
                        $('#customerIdUpdateDisplay').val(customerId);
                        $('#customerNameUpdate').val(customerName);
                        $('#customerPhoneUpdate').val(customerPhone);
                    });

                    $(document).on('click', '.btn-delete-customer', function () {
                        var customerId = $(this).data('customer-id');
                        $('#customerIdDelete').val(customerId);
                    });
                }

                function displayError(fieldId, message) {
                    $('#' + fieldId).addClass('is-invalid');
                    $('#' + fieldId).after('<div class="error-message" style="color: red;">' + message + '</div>');
                }

                // Ẩn thông báo sau 10 giây
                setTimeout(function () {
                    $('#successMessage').fadeOut('slow');
                    $('#errorMessage').fadeOut('slow');
                }, 10000);
            });
        </script>
    </body>
</html>