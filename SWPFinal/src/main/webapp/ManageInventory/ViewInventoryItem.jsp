<%--
    Document   : ViewIntentoryItem
    Created on : Feb 23, 2025, 9:43:14 PM
    Author     : DELL-Laptop
--%>

<%@page import="Model.InventoryItem"%>
<%@page import="Model.Account"%>
<%@page import="java.util.List"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
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
        <title>Inventory Management - Admin Dashboard</title>

        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
        <!-- Font Awesome Icons -->
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <!-- jQuery -->
        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <!-- SweetAlert2 for enhanced alerts -->
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
            .sidebar h4{
                font-size: 1.5rem;
            }
            .card-stats {
                background: linear-gradient(to right, #4CAF50, #81C784);
                color: white;
            }

            .card-stats i {
                font-size: 2rem;
            }

            .chart-container {
                position: relative;
                height: 300px;
            }

            /* Main Content Area */
            .main-content-area {
                padding: 20px;
                margin-left: 16.67%;
            }

            /* Content Header */
            .content-header {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 20px;
            }

            .content-header h2 {
                margin-top: 0;
                font-size: 24px;
            }

            /* Search Bar */
            .search-bar input {
                padding: 8px 12px;
                border: 1px solid #ccc;
                border-radius: 3px;
                width: 250px;
            }
            .modal-header{
                background-color: #f7f7f0
            }
            /* Table Styles */
            .table-responsive {
                overflow-x: auto;
            }

            /* Nút trong bảng */
            .btn-edit, .btn-delete {
                padding: 5px 10px;
                border-radius: 5px;
                color: white;
                text-decoration: none;
                display: inline-flex;
                align-items: center;
                justify-content: center;
            }

            .btn-edit {
                background-color: #007bff;
            }

            .btn-edit:hover {
                background-color: #0056b3;
            }

            .btn-delete {
                background-color: #dc3545;
                margin-left: 5px;
            }
            #couponIdUpdateDisplay{
                background-color: #fcfcf7
            }
            .btn-delete:hover {
                background-color: #c82333;
            }

            .btn-edit i, .btn-delete i {
                margin-right: 5px;
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

            /* No Data Message */
            .no-data {
                padding: 20px;
                text-align: center;
                color: #777;
            }
            .sidebar .nav-link {
                font-size: 0.9rem; /* Hoặc 16px, tùy vào AdminDashboard.jsp */
            }


            .highlight {
                background-color: yellow !important; /* Thêm !important */
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
            .text-left.mb-4 {

                overflow: hidden; /* Đảm bảo background và border-radius hoạt động đúng với nội dung bên trong */
                /* Các tùy chỉnh tùy chọn để làm đẹp thêm (có thể bỏ nếu không cần) */
                background: linear-gradient(to right, #2C3E50, #42A5F5);
                padding: 1rem; /* Thêm padding bên trong để tạo khoảng cách, tùy chọn */
                color:white;
                margin-left : -40px !important;
                margin-top: -25px !important;
                margin-right: -25px !important;
            }

            .btn-warning {
                background-color: #ffca28; /* Chọn màu vàng ấm áp: #ffca28 (hoặc #ffb300, #ffc107, tùy bạn thích) */
                border-color: #ffca28;    /* Viền cùng màu nền */
                color: white;         /* Chữ tối màu */
                transition: background-color 0.3s ease, border-color 0.3s ease, box-shadow 0.3s ease; /* Transition mượt mà */
            }

            .btn-warning:hover {
                background-color: #ffda6a; /* Vàng sáng hơn một chút khi hover: #ffda6a (hoặc #ffe082, tùy màu nền) */
                border-color: #ffda6a;    /* Viền cùng màu nền hover */
                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1); /* Bóng đổ nhẹ */
            }

            .btn-danger {
                background-color: #f44336; /* Màu đỏ "đỏ hơn", ví dụ: #f44336 (hoặc #e53935, #d32f2f, tùy chọn) */
                border-color: #f44336;    /* Viền cùng màu nền */
                color: white;             /* Chữ trắng */
                transition: background-color 0.3s ease, border-color 0.3s ease, box-shadow 0.3s ease; /* Transition mượt mà */
            }

            .btn-danger:hover {
                background-color: #e53935; /* Đỏ đậm hơn một chút khi hover, ví dụ: #e53935 (hoặc #d32f2f, tùy màu nền) */
                border-color: #e53935;    /* Viền cùng màu nền hover */
                box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1); /* Bóng đổ nhẹ */
                color: black;
            }

            /* Tùy chỉnh cho cột Description trong bảng Inventory */
            .table th:nth-child(8), /* Cột Description (thứ 8) trong thead của bảng Inventory */
            .table td:nth-child(8)  /* Cột Description (thứ 8) trong tbody của bảng Inventory */
            {
                max-width: 400px; /* Điều chỉnh độ rộng tối đa nếu cần */
                word-wrap: break-word;
                white-space: normal;
            }

            /* Tùy chỉnh cho cột Actions trong bảng Inventory */
            .table th:nth-child(9), /* Cột Actions (thứ 9) trong thead của bảng Inventory */
            .table td:nth-child(9)  /* Cột Actions (thứ 9) trong tbody của bảng Inventory */
            {
                width: 150px;      /* Điều chỉnh độ rộng cột Actions nếu cần */
                min-width: 100px;   /* Đảm bảo cột Actions không quá hẹp */
                white-space: nowrap; /* Ngăn xuống dòng trong cột Actions */
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
            <!-- Main Content -->
            <div class="col-md-10 p-4 main-content-area">
                <section class="main-content">
                    <div class="container-fluid">
                        <div class="text-left mb-4">
                            <h4>Inventory Management</h4>
                        </div>
                        <main class="content-area">
                            <div class="content-header">
                                <div class="search-bar"> <%-- Search bar and filter added here --%>
                                    <input type="text" id="searchInput" placeholder="Search Inventory Item"> <%-- Updated placeholder --%>
                                </div>

                                <div class="header-buttons">
                                    <button type="button" class="btn btn-info" data-bs-toggle="modal" data-bs-target="#addInventoryModal"><i class="fas fa-plus"></i>Add New</button>
                                </div>
                            </div>
                            <div class="employee-grid"> <%-- Reusing employee-grid class for layout consistency --%>
                                <div class="table-responsive">
                                    <table class="table table-bordered"  method="post">
                                        <thead>
                                            <tr>
                                                <th>No.</th>
                                                <th>ID</th>
                                                <th>Name</th>
                                                <th>Type</th>
                                                <th>Price</th>
                                                <th>Quantity</th>
                                                <th>Unit</th>
                                                <th>Description</th>
                                                <th>Actions</th> <%-- Action column title --%>
                                            </tr>

                                            <tr id="noResultsRow" style="display: none;">
                                                <td colspan="9" style="text-align: center; color: gray">Inventory Item Not Found.</td>
                                            </tr>
                                        </thead>

                                        <tbody id="inventoryTableBody"> <%-- Added ID for table body --%>

                                            <%
                                                List<InventoryItem> inventoryItemList = (List<InventoryItem>) request.getAttribute("InventoryItemList");
                                                if (inventoryItemList != null && !inventoryItemList.isEmpty()) {
                                                    int displayIndex = 1;
                                                    for (InventoryItem listItem : inventoryItemList) {
                                            %>

                                            <tr id="inventoryRow<%=listItem.getItemId()%>">
                                                <Td valign="middle"><% out.print(displayIndex++); %></td>
                                                <Td valign="middle"><% out.print(listItem.getItemId()); %></td>
                                                <Td valign="middle"><% out.print(listItem.getItemName()); %></td>
                                                <Td valign="middle"><% out.print(listItem.getItemType()); %></td>
                                                <Td valign="middle"><% out.print(listItem.getItemPrice()); %></td>
                                                <Td valign="middle"><% out.print(listItem.getItemQuantity()); %></td>
                                                <Td valign="middle"><% out.print(listItem.getItemUnit()); %></td>
                                                <Td valign="middle"><% out.print(listItem.getItemDescription());%></td>
                                                <Td valign="middle">
                                                    <button type="button" class="btn btn-warning btn-update-inventory"
                                                            data-bs-toggle="modal" data-bs-target="#updateInventoryModal"
                                                            data-item-id="<%= listItem.getItemId()%>"
                                                            data-item-name="<%= listItem.getItemName()%>"
                                                            data-item-type="<%= listItem.getItemType()%>"
                                                            data-item-price="<%= listItem.getItemPrice()%>"
                                                            data-item-quantity="<%= listItem.getItemQuantity()%>"
                                                            data-item-unit="<%= listItem.getItemUnit()%>"
                                                            data-item-description="<%= listItem.getItemDescription()%>">
                                                        <i class="fas fa-edit"></i> Update
                                                    </button>
                                                    <button type="button" class="btn btn-danger btn-delete-inventory"
                                                            data-bs-toggle="modal" data-bs-target="#deleteInventoryModal"
                                                            data-item-id="<%= listItem.getItemId()%>">
                                                        <i class="fas fa-trash-alt"></i> Delete
                                                    </button>
                                                </td>
                                            </tr>
                                            <%
                                                }
                                            } else {
                                            %>
                                            <tr>
                                                <td colspan="9">
                                                    <div class="no-data">
                                                        No inventory items found.
                                                    </div>
                                                </td>
                                            </tr>
                                            <%
                                                }
                                            %>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </main>
                    </div>
                </section>
            </div>
        </div>

        <!-- Add Inventory Modal -->
        <div class="modal fade" id="addInventoryModal" tabindex="-1" aria-labelledby="addInventoryModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="addInventoryModalLabel">Add New Inventory Item</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="addInventoryForm">

                            <div class="mb-3 row">
                                <label for="itemName" class="col-sm-4 col-form-label">Name:</label>
                                <div class="col-sm-8">
                                    <input type="text" class="form-control" id="itemName" name="itemName" required>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="itemType" class="col-sm-4 col-form-label">Type:</label>
                                <div class="col-sm-8">
                                    <select class="form-control" id="itemType" name="itemType" required >
                                        <option value="">Select type...</option>
                                        <option value="food">Food</option>
                                        <option value="drink">Drink</option>
                                    </select>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="itemPrice" class="col-sm-4 col-form-label">Price:</label>
                                <div class="col-sm-8">
                                    <input type="number" class="form-control" id="itemPrice" name="itemPrice" required min="0" step="0.01">
                                    <small class="text-muted">Enter a non-negative number.</small>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="itemQuantity" class="col-sm-4 col-form-label">Quantity:</label>
                                <div class="col-sm-8">
                                    <input type="number" class="form-control" id="itemQuantity" name="itemQuantity" required min="0">
                                    <small class="text-muted">Enter a non-negative integer.</small>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="itemUnit" class="col-sm-4 col-form-label">Unit:</label>
                                <div class="col-sm-8">
                                    <select class="form-control" id="itemUnit" name="itemUnit" required>
                                        <option value="">Select unit...</option> <!-- Tùy chọn mặc định -->
                                        <option value="piece">Piece</option>
                                        <option value="kg">Kg</option>
                                        <option value="gram">Gram</option>
                                        <option value="liter">Liter</option>
                                        <option value="ml">ml</option>
                                        <option value="box">Box</option>
                                        <option value="pack">Pack</option>
                                        <option value="bottle">Bottle</option>
                                        <option value="set">Set</option>
                                    </select>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="itemDescription" class="col-sm-4 col-form-label">Description:</label>
                                <div class="col-sm-8">
                                    <textarea class="form-control" id="itemDescription" name="itemDescription" rows="2"></textarea>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-primary" id="btnAddInventory">Add Item</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Update Inventory Modal -->
        <div class="modal fade" id="updateInventoryModal" tabindex="-1" aria-labelledby="updateInventoryModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="updateInventoryModalLabel">Update Inventory Item</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <form id="updateInventoryForm">
                            <div class="mb-3 row">
                                <label for="itemIdUpdate" class="col-sm-4 col-form-label">Item ID (View Only):</label>
                                <div class="col-sm-8">
                                    <input type="text" class="form-control" id="itemIdUpdateDisplay" readonly>
                                    <input type="hidden" class="form-control" id="itemIdUpdate" name="itemId">
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="itemNameUpdate" class="col-sm-4 col-form-label">Name:</label>
                                <div class="col-sm-8">
                                    <input type="text" class="form-control" id="itemNameUpdate" name="itemName" required>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="itemTypeUpdate" class="col-sm-4 col-form-label">Type:</label>
                                <div class="col-sm-8">
                                    <select class="form-control" id="itemTypeUpdate" name="itemType" required>
                                        <option value="">Select type...</option>
                                        <option value="food">Food</option>
                                        <option value="drink">Drink</option>
                                    </select>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="itemPriceUpdate" class="col-sm-4 col-form-label">Price:</label>
                                <div class="col-sm-8">
                                    <input type="number" class="form-control" id="itemPriceUpdate" name="itemPrice" required min="0" step="0.01">
                                    <small class="text-muted">Enter a non-negative number.</small>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="itemQuantityUpdate" class="col-sm-4 col-form-label">Quantity:</label>
                                <div class="col-sm-8">
                                    <input type="number" class="form-control" id="itemQuantityUpdate" name="itemQuantity" required min="0" step="0.01">
                                    <small class="text-muted">Enter a non-negative integer.</small>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="itemUnitUpdate" class="col-sm-4 col-form-label">Unit:</label>
                                <div class="col-sm-8">
                                    <select class="form-control" id="itemUnitUpdate" name="itemUnit" required>
                                        <option value="">Select unit...</option> <!-- Tùy chọn mặc định -->
                                        <option value="piece">Piece</option>
                                        <option value="kg">Kg</option>
                                        <option value="gram">Gram</option>
                                        <option value="liter">Liter</option>
                                        <option value="ml">ml</option>
                                        <option value="box">Box</option>
                                        <option value="pack">Pack</option>
                                        <option value="bottle">Bottle</option>
                                        <option value="set">Set</option>
                                    </select>
                                </div>
                            </div>
                            <div class="mb-3 row">
                                <label for="itemDescriptionUpdate" class="col-sm-4 col-form-label">Description:</label>
                                <div class="col-sm-8">
                                    <textarea class="form-control" id="itemDescriptionUpdate" name="itemDescription" rows="2"></textarea>
                                </div>
                            </div>
                        </form>
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-primary" id="btnUpdateInventory">Save Changes</button>
                    </div>
                </div>
            </div>
        </div>

        <!-- Delete Inventory Modal -->
        <div class="modal fade" id="deleteInventoryModal" tabindex="-1" aria-labelledby="deleteInventoryModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header">
                        <h5 class="modal-title" id="deleteInventoryModalLabel">Confirm Delete</h5>
                        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <div class="modal-body">
                        <p>Are you sure you want to DELETE this inventory item?</p>
                        <input type="hidden" id="inventoryItemIdDelete">
                    </div>
                    <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                        <button type="button" class="btn btn-danger" id="btnDeleteInventoryConfirm">Delete Item</button>
                    </div>
                </div>
            </div>
        </div>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
        <script>

            function formatDiscountDisplay(priceFormat) {
                const priceStr = String(priceFormat); // Chuyển số thành chuỗi
                if (priceStr.length > 0) {
                    // Định dạng số lớn hơn 999 thành tiền tệ với dấu phẩy và 'đ'
                    return formatCurrency(priceFormat) + 'đ';
                } else {
                    // Định dạng số nhỏ hơn hoặc bằng 999 thành phần trăm với '%'
                    return priceFormat + '%';
                }
            }

            function formatCurrency(number) {
                return number.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            }
            $(document).ready(function () {
                bindEventHandlers();
                reloadViewInventory();
                setupSearchFilter();


                // **Xử lý Thêm Inventory Item**
                $('#btnAddInventory').click(function () {
                    // Xóa các thông báo lỗi cũ (nếu có)
                    $('.error-message').remove();
                    $('.is-invalid').removeClass('is-invalid');

                    var itemNameInput = $('#itemName');
                    var itemTypeInput = $('#itemType');
                    var itemPriceInput = $('#itemPrice');
                    var itemQuantityInput = $('#itemQuantity');
                    var itemUnitInput = $('#itemUnit');
                    var itemDescriptionInput = $('#itemDescription');


                    var itemName = itemNameInput.val().trim(); // trim() để loại bỏ khoảng trắng đầu cuối
                    var itemType = itemTypeInput.val();
                    var itemPrice = itemPriceInput.val();
                    var itemQuantity = itemQuantityInput.val();
                    var itemUnit = itemUnitInput.val();
                    var itemDescription = itemDescriptionInput.val();

                    var isValid = true; // Biến cờ để theo dõi trạng thái hợp lệ của form

                    // Kiểm tra trường Name
                    if (itemName === '') {
                        isValid = false;
                        displayError('itemName', 'Please input this field.');
                    } else if (itemName.length > 100) { // Thêm điều kiện kiểm tra độ dài itemName
                        isValid = false;
                        displayError('itemName', 'Item name cannot exceed 100 characters.');
                    }

                    // Kiểm tra trường Type
                    if (itemType === '') {
                        isValid = false;
                        displayError('itemType', 'Please select item type.');
                    }

                    // Kiểm tra trường Price
                    if (itemPrice === '' || isNaN(itemPrice) || parseFloat(itemPrice) <= 0) {
                        isValid = false;
                        displayError('itemPrice', 'Price must be a valid non-negative number and greater than 0.');
                    }

                    // Kiểm tra trường Quantity
                    if (itemQuantity === '' || isNaN(itemQuantity) || parseFloat(itemQuantity) <= 0) {
                        isValid = false;
                        displayError('itemQuantity', 'Quantity must be a non-negative number.');
                    }
                    // Kiểm tra trường Unit
                    if (itemUnit === '') {
                        isValid = false;
                        displayError('itemUnit', 'Please select item unit.');
                    }

                    // Kiểm tra trường Description
                    if (itemDescription.length > 255) { // Thêm điều kiện kiểm tra độ dài description
                        isValid = false;
                        displayError('itemDescription', 'Description cannot exceed 255 characters.');
                    }


                    if (isValid) {
                        // Nếu tất cả các trường hợp lệ, gửi AJAX request
                        $.ajax({
                            url: 'AddInventoryItemController', // URL của controller xử lý thêm InventoryItem
                            type: 'POST',
                            data: {
                                itemName: itemName,
                                itemType: itemType,
                                itemPrice: itemPrice,
                                itemQuantity: itemQuantity,
                                itemUnit: itemUnit,
                                itemDescription: itemDescription
                            },
                            success: function (response) { // Callback khi thành công
                                var addInventoryModal = bootstrap.Modal.getInstance(document.getElementById('addInventoryModal'));
                                addInventoryModal.hide();
                                reloadViewInventory(); // Hàm reload lại bảng dữ liệu InventoryItems
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: 'Inventory item added successfully.',
                                    timer: 2000,
                                    showConfirmButton: false
                                });
                                $('#addInventoryForm')[0].reset(); // Reset form sau khi thành công
                            },
                            error: function (xhr, status, error) { // Callback khi lỗi
                                if (xhr.status === 400) { // Kiểm tra mã lỗi 400 Bad Request (có thể do validation lỗi ở server)
                                    Swal.fire({
                                        icon: 'error',
                                        title: 'Sorry!',
                                        text: 'Inventory is exist, please check agains!', // Thông báo lỗi chung cho dữ liệu không hợp lệ
                                        confirmButtonText: 'OK',
                                        confirmButtonColor: '#dc3545'
                                    });
                                } else { // Xử lý các lỗi khác (lỗi server, lỗi database,...)
                                    Swal.fire({
                                        icon: 'error',
                                        title: 'Sorry!',
                                        text: 'Your transaction has failed. Please go back and try again.', // Thông báo lỗi chung khi giao dịch thất bại
                                        confirmButtonText: 'OK',
                                        confirmButtonColor: '#dc3545'
                                    });
                                }
                            }
                        });
                    }
                });

                // Hàm hiển thị thông báo lỗi bên dưới trường nhập liệu
                function displayError(fieldId, message) {
                    $('#' + fieldId).addClass('is-invalid'); // Thêm class 'is-invalid' để hiển thị lỗi CSS nếu cần
                    $('#' + fieldId).after('<div class="error-message" style="color: red;">' + message + '</div>'); // Thêm thông báo lỗi
                }

                // **Xử lý Cập nhật Inventory Item**
                $('#btnUpdateInventory').click(function () {
                    // **Clear old error messages (if any)**
                    $('.error-message').remove();
                    $('.is-invalid').removeClass('is-invalid');

                    var itemNameUpdateInput = $('#itemNameUpdate');
                    var itemTypeUpdateInput = $('#itemTypeUpdate');
                    var itemPriceUpdateInput = $('#itemPriceUpdate');
                    var itemQuantityUpdateInput = $('#itemQuantityUpdate');
                    var itemUnitUpdateInput = $('#itemUnitUpdate');
                    var itemDescriptionUpdateInput = $('#itemDescriptionUpdate');

                    var itemNameUpdate = itemNameUpdateInput.val();
                    var itemTypeUpdate = itemTypeUpdateInput.val();
                    var itemPriceUpdate = itemPriceUpdateInput.val();
                    var itemQuantityUpdate = itemQuantityUpdateInput.val();
                    var itemUnitUpdate = itemUnitUpdateInput.val();
                    var itemDescriptionUpdate = itemDescriptionUpdateInput.val();


                    var isValid = true;

                    if (itemNameUpdate === '') {
                        isValid = false;
                        displayError('itemNameUpdate', 'Please input this field.');
                    } else if (itemNameUpdate.length > 100) { // Thêm điều kiện kiểm tra độ dài itemNameUpdate
                        isValid = false;
                        displayError('itemNameUpdate', 'Item name cannot exceed 100 characters.');
                    }
                    if (itemTypeUpdate === '') {
                        isValid = false;
                        displayError('itemTypeUpdate', 'Please select item type.');
                    }
                    if (itemPriceUpdate === '' || isNaN(itemPriceUpdate) || parseFloat(itemPriceUpdate) <= 0) {
                        isValid = false;
                        displayError('itemPriceUpdate', 'Price must be a valid non-negative number and greater than 0.');
                    }
                    if (itemQuantityUpdate === '' || isNaN(itemQuantityUpdate) || parseFloat(itemQuantityUpdate) <= 0) {
                        isValid = false;
                        displayError('itemQuantityUpdate', 'Quantity must be a non-negative integer.');
                    }
                    if (itemUnitUpdate === '') {
                        isValid = false;
                        displayError('itemUnitUpdate', 'Please select item unit.');
                    }
                    if (itemDescriptionUpdate.length > 255) { // Thêm điều kiện kiểm tra độ dài itemDescriptionUpdate
                        isValid = false;
                        displayError('itemDescriptionUpdate', 'Description cannot exceed 255 characters.');
                    }

                    if (isValid) {
                        var itemId = $('#itemIdUpdate').val();
                        $.ajax({
                            url: 'UpdateInventoryItemController',
                            type: 'POST',
                            data: {
                                itemId: itemId,
                                itemName: itemNameUpdate,
                                itemType: itemTypeUpdate,
                                itemPrice: itemPriceUpdate,
                                itemQuantity: itemQuantityUpdate,
                                itemUnit: itemUnitUpdate,
                                itemDescription: itemDescriptionUpdate
                            },
                            success: function () {
                                var updateInventoryModal = bootstrap.Modal.getInstance(document.getElementById('updateInventoryModal'));
                                updateInventoryModal.hide();
                                reloadViewInventory();
                                Swal.fire({
                                    icon: 'success',
                                    title: 'Success!',
                                    text: 'Inventory item updated successfully.',
                                    timer: 2000,
                                    showConfirmButton: false
                                });
                            },
                            error: function (error) {
                                Swal.fire({
                                    icon: 'error',
                                    title: 'Error!',
                                    text: 'Error updating inventory item: ' + error
                                });
                            }
                        });
                    }
                });

                // **Xử lý Xóa Inventory Item**
                $('#btnDeleteInventoryConfirm').click(function () {
                    var itemId = $('#inventoryItemIdDelete').val();
                    $.ajax({
                        url: 'DeleteInventoryItemController',
                        type: 'POST',
                        data: {
                            itemID: itemId
                        },
                        success: function (response) {
                            var deleteInventoryModal = bootstrap.Modal.getInstance(document.getElementById('deleteInventoryModal'));
                            deleteInventoryModal.hide();
                            $('#inventoryRow' + itemId).remove();
                            if ($('#inventoryTableBody tr').length === 0) {
                                $('#inventoryTableBody').html('<tr><td colspan="9"><div class="no-data">No inventory items found.</div></td></tr>');
                            }
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Inventory item deleted successfully.',
                                timer: 2000,
                                showConfirmButton: false
                            });
                        },
                        error: function (xhr, status, error) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: 'Error deleting inventory item: ' + error
                            });
                        }
                    });
                });
            });

            function bindEventHandlers() {
                $(document).on('click', '.btn-update-inventory', function () {
                    var itemId = $(this).data('item-id');
                    var itemName = $(this).data('item-name');
                    var itemType = $(this).data('item-type');
                    var itemPrice = $(this).data('item-price');
                    var itemQuantity = $(this).data('item-quantity');
                    var itemUnit = $(this).data('item-unit');
                    var itemDescription = $(this).data('item-description');


                    $('#itemIdUpdate').val(itemId);
                    $('#itemIdUpdateDisplay').val(itemId);
                    $('#itemNameUpdate').val(itemName);
                    $('#itemTypeUpdate').val(itemType);
                    $('#itemPriceUpdate').val(itemPrice);
                    $('#itemQuantityUpdate').val(itemQuantity);
                    $('#itemUnitUpdate').val(itemUnit);
                    $('#itemDescriptionUpdate').val(itemDescription);

                });

                $(document).on('click', '.btn-delete-inventory', function () {
                    var itemId = $(this).data('item-id');
                    $('#inventoryItemIdDelete').val(itemId);
                });
            }

            function reloadViewInventory() {
                $.get('ViewInventoryController', function (data) {
                    var newBody = $(data).find('tbody').html();
                    $('tbody').html(newBody); // Thay thế tbody bằng HTML mới

                    // **Định dạng cột giá sau khi load lại bảng**
                    $('tbody tr').each(function () { // Lặp qua từng hàng trong tbody mới
                        var priceCell = $(this).find('td:nth-child(5)'); // **ĐÃ KIỂM TRA, CỘT THỨ 3 LÀ DISCOUNT AMOUNT**
                        if (priceCell.length) { // Kiểm tra xem có tìm thấy td hay không
                            var discountAmountText = priceCell.text();
                            var discountAmount = parseFloat(discountAmountText); // Chuyển text thành số
                            if (!isNaN(discountAmount)) { // Kiểm tra xem có phải là số hợp lệ không
                                var formattedDiscount = formatDiscountDisplay(discountAmount); // Định dạng giá trị
                                priceCell.text(formattedDiscount); // Cập nhật text của td với giá trị đã định dạng
                            }
                        }
                    });
                    bindEventHandlers(); // Re-bind event handlers sau khi HTML được thay thế
                });
            }

            function setupSearchFilter() {
                const searchInput = document.getElementById('searchInput');
                const table = document.querySelector('.table');
                const noResultsRow = document.getElementById('noResultsRow');

                function searchInventory() {
                    const searchText = searchInput.value.trim().toLowerCase();
                    let foundMatch = false;
                    noResultsRow.style.display = 'none';
                    const rows = table.querySelectorAll('tbody tr:not(#noResultsRow)');

                    rows.forEach(row => {
                        let rowVisible = false;
                        row.querySelectorAll('td').forEach((cell, cellIndex) => {
                            if (cellIndex > 0 && cellIndex < 8) { // Search in columns from ID to Description
                                const originalText = cell.textContent;
                                const cellText = originalText.toLowerCase();
                                cell.innerHTML = originalText; // Reset highlight

                                if (searchText.trim() === "") {
                                    row.style.display = '';
                                    rowVisible = true;
                                    return;
                                }

                                if (cellText.includes(searchText)) {
                                    let highlightedText = "";
                                    let currentIndex = 0;
                                    let searchIndex = originalText.toLowerCase().indexOf(searchText, currentIndex);

                                    while (searchIndex !== -1) {
                                        highlightedText += originalText.slice(currentIndex, searchIndex);
                                        highlightedText += '<span class="highlight">' + originalText.slice(searchIndex, searchIndex + searchText.length) + '</span>';
                                        currentIndex = searchIndex + searchText.length;
                                        searchIndex = originalText.toLowerCase().indexOf(searchText, currentIndex);
                                    }
                                    highlightedText += originalText.slice(currentIndex);

                                    cell.innerHTML = highlightedText;
                                    rowVisible = true;
                                    foundMatch = true;
                                }
                            }
                        });
                        if (rowVisible) {
                            row.style.display = '';
                        } else {
                            row.style.display = 'none';
                        }
                    });
                    if (!foundMatch && searchText.trim() !== "") {
                        noResultsRow.style.display = '';
                    }
                }
                searchInput.addEventListener('keyup', searchInventory);
            }


        </script>
    </body>
</html>