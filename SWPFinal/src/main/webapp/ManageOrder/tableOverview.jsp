<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="Model.Order, Model.OrderDetail, Model.Customer, Model.Account, java.util.List" %>
<%
    if (session == null || session.getAttribute("account") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    Account account = (Account) session.getAttribute("account");
    String UserRole = account.getUserRole();
    Order order = (Order) request.getAttribute("order");
    List<Customer> customers = (List<Customer>) request.getAttribute("customers");
    Customer currentCustomer = (Customer) request.getAttribute("currentCustomer");
    List<Model.Dish> dishes = (List<Model.Dish>) request.getAttribute("dishes");
    Boolean hasOrder = (Boolean) request.getAttribute("hasOrder");
%>
<html>
<head>
    <title>Table Details - <%= request.getAttribute("tableId")%></title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            font-family: 'Roboto', sans-serif;
            background-color: #f8f9fa;
           
        }
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
            color: white;
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
        .content {
            margin-left: 250px;
            padding: 30px;
            width: 100%;
            max-width: 1000px;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
        }
        .container {
            background: #fff;
            padding: 25px;
            border-radius: 10px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            width: 100%;
        }
        h1 {
            color: #2c3e50;
            text-align: center;
            font-size: 28px;
            font-weight: 600;
            margin-top: 30px;
        }
        h3 {
            color: #34495e;
            font-size: 20px;
            font-weight: 500;
            margin-bottom: 15px;
            border-bottom: 2px solid #4CAF50;
            padding-bottom: 5px;
        }
        .order-info p {
            font-size: 14px;
            color: #555;
            margin: 8px 0;
        }
        .order-info p strong {
            color: #333;
            font-weight: 600;
        }
        .table-list {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }
        .table-list th, .table-list td {
            padding: 12px 15px;
            border: 1px solid #e0e0e0;
            text-align: left;
            font-size: 14px;
        }
        .table-list th {
            background-color: #4CAF50;
            color: white;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .table-list td {
            background-color: #fff;
            color: #333;
        }
        .table-list tr:hover td {
            background-color: #f9f9f9;
            transition: background-color 0.3s;
        }
        .button {
            padding: 10px 20px;
            border: none;
            border-radius: 5px;
            color: white;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.3s ease;
            text-decoration: none;
            display: inline-block;
        }
        .button:hover {
            opacity: 0.9;
            transform: translateY(-2px);
        }
        .btn-primary {
            background-color: #007bff;
        }
        .btn-success {
            background-color: #28a745;
        }
        .btn-danger {
            background-color: #dc3545;
        }
        .btn-secondary {
            background-color: #6c757d;
        }
        .btn-disabled {
            background-color: #cccccc;
            cursor: not-allowed;
            transform: none;
        }
        .error {
            color: #dc3545;
            text-align: center;
            margin-bottom: 15px;
            font-size: 14px;
            font-weight: 500;
        }
        select, input[type="text"], input[type="number"] {
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px;
            width: 100%;
            max-width: 300px;
        }
        select:focus, input[type="text"]:focus, input[type="number"]:focus {
            border-color: #007bff;
            outline: none;
            box-shadow: 0 0 5px rgba(0, 123, 255, 0.3);
        }
        #addCustomerForm {
            display: none;
            margin-top: 15px;
        }
        .quantity-control {
            display: flex;
            align-items: center;
            gap: 5px;
        }
        .quantity-btn {
            padding: 5px 12px;
            font-size: 14px;
            background-color: #6c757d;
            border: none;
            border-radius: 50%;
            color: white;
            cursor: pointer;
            transition: background-color 0.3s;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .quantity-btn:hover {
            background-color: #5a6268;
        }
        .quantity-input {
            width: 50px;
            text-align: center;
            padding: 5px;
            border: 1px solid #ccc;
            border-radius: 4px;
            font-size: 14px;
        }
        .error-message {
            color: #dc3545;
            font-size: 12px;
            margin-top: 5px;
        }
        .description-section {
            margin-top: 15px;
        }
        .description-section label {
            font-weight: 600;
            color: #333;
        }
        .description-section input {
            width: 100%;
            max-width: 400px;
            padding: 8px;
            font-size: 14px;
            border: 1px solid #ccc;
            border-radius: 4px;
        }
        .description-section input:focus {
            border-color: #007bff;
            box-shadow: 0 0 5px rgba(0, 123, 255, 0.3);
        }
        .action-buttons {
            text-align: center;
            margin-top: 25px;
        }
        @media (max-width: 768px) {
            .sidebar {
                width: 200px;
            }
            .content {
                margin-left: 200px;
                padding: 20px;
            }
            .table-list th, .table-list td {
                padding: 8px;
                font-size: 12px;
            }
            .quantity-input {
                width: 40px;
            }
            .button {
                padding: 8px 15px;
                font-size: 12px;
            }
        }
        @media (max-width: 576px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }
            .content {
                margin-left: 0;
                padding: 15px;
            }
            .table-list {
                font-size: 12px;
            }
            .button {
                padding: 6px 12px;
                font-size: 12px;
            }
        }
    </style>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script>
        function toggleAddCustomerForm() {
            var checkbox = document.getElementById("addCustomerCheckbox");
            var form = document.getElementById("addCustomerForm");
            var selectForm = document.getElementById("selectCustomerForm");
            if (checkbox.checked) {
                form.style.display = "block";
                selectForm.style.display = "none";
            } else {
                form.style.display = "none";
                selectForm.style.display = "block";
            }
        }

        function updateQuantity(orderDetailId, dishId, tableId, delta) {
            var input = document.getElementById("quantity_" + dishId);
            var newQuantity = parseInt(input.value) + delta;
            if (newQuantity < 0) {
                Swal.fire('Error!', 'Quantity cannot be less than 0!', 'error');
                return;
            }
            input.value = newQuantity;

            var form = document.createElement("form");
            form.method = "POST";
            form.action = "${pageContext.request.contextPath}/order";

            var actionInput = document.createElement("input");
            actionInput.type = "hidden";
            actionInput.name = "action";
            actionInput.value = "editDishQuantity";
            form.appendChild(actionInput);

            var orderDetailInput = document.createElement("input");
            orderDetailInput.type = "hidden";
            orderDetailInput.name = "orderDetailId";
            orderDetailInput.value = orderDetailId || "";
            form.appendChild(orderDetailInput);

            var dishInput = document.createElement("input");
            dishInput.type = "hidden";
            dishInput.name = "dishId";
            dishInput.value = dishId;
            form.appendChild(dishInput);

            var quantityInput = document.createElement("input");
            quantityInput.type = "hidden";
            quantityInput.name = "newQuantity";
            quantityInput.value = newQuantity;
            form.appendChild(quantityInput);

            var tableInput = document.createElement("input");
            tableInput.type = "hidden";
            tableInput.name = "tableId";
            tableInput.value = tableId;
            form.appendChild(tableInput);

            document.body.appendChild(form);
            form.submit();
        }

        $(document).ready(function () {
            $('#btnAddCustomerTable').click(function (e) {
                e.preventDefault();
                $('.error-message').remove();

                var customerName = $('#customerNameTable').val().trim();
                var customerPhone = $('#customerPhoneTable').val().trim();

                var isValid = true;

                if (customerName === '') {
                    isValid = false;
                    $('#customerNameTable').after('<div class="error-message">Please input this field</div>');
                }

                if (customerPhone === '') {
                    isValid = false;
                    $('#customerPhoneTable').after('<div class="error-message">Please input this field</div>');
                } else if (!customerPhone.startsWith('0')) {
                    isValid = false;
                    $('#customerPhoneTable').after('<div class="error-message">Phone number must start with 0</div>');
                } else if (!/^\d{10}$/.test(customerPhone)) {
                    isValid = false;
                    $('#customerPhoneTable').after('<div class="error-message">Phone number must be exactly 10 digits</div>');
                }

                if (isValid) {
                    $.ajax({
                        url: '${pageContext.request.contextPath}/AddCustomer',
                        type: 'POST',
                        data: {
                            CustomerName: customerName,
                            CustomerPhone: customerPhone,
                            NumberOfPayment: 0
                        },
                        success: function () {
                            Swal.fire({
                                icon: 'success',
                                title: 'Success!',
                                text: 'Customer added successfully.',
                                timer: 2000,
                                showConfirmButton: false
                            }).then(() => {
                                window.location.reload();
                            });
                        },
                        error: function (xhr) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: xhr.responseText || 'Error adding customer.',
                                confirmButtonColor: '#dc3545'
                            });
                        }
                    });
                }
            });

            $('#btnCancelOrder').click(function (e) {
                e.preventDefault();
                Swal.fire({
                    title: 'Are you sure?',
                    text: "You want to cancel this order?",
                    icon: 'warning',
                    showCancelButton: true,
                    confirmButtonColor: '#d33',
                    cancelButtonColor: '#3085d6',
                    confirmButtonText: 'Yes, cancel it!'
                }).then((result) => {
                    if (result.isConfirmed) {
                        var orderId = $(this).data('order-id');
                        var tableId = $(this).data('table-id');
                        $.post('${pageContext.request.contextPath}/order', {
                            action: 'cancelOrder',
                            orderId: orderId,
                            tableId: tableId
                        }, function () {
                            Swal.fire({
                                icon: 'success',
                                title: 'Cancelled!',
                                text: 'Order has been cancelled.',
                                timer: 2000,
                                showConfirmButton: false
                            }).then(() => {
                                window.location.href = '${pageContext.request.contextPath}/order?action=listTables';
                            });
                        }).fail(function (xhr) {
                            Swal.fire({
                                icon: 'error',
                                title: 'Error!',
                                text: xhr.responseText || 'Error cancelling order.',
                                confirmButtonColor: '#dc3545'
                            });
                        });
                    }
                });
            });

            $('#btnSaveDescription').click(function (e) {
                e.preventDefault();
                var orderId = $(this).data('order-id');
                var tableId = $(this).data('table-id');
                var orderDescription = $('#orderDescription').val().trim();

                if (!orderDescription) {
                    Swal.fire('Error!', 'Please enter order description.', 'error');
                    return;
                }

                $.post('${pageContext.request.contextPath}/order', {
                    action: 'updateOrderDescription',
                    orderId: orderId,
                    tableId: tableId,
                    orderDescription: orderDescription
                }, function () {
                    Swal.fire({
                        icon: 'success',
                        title: 'Success!',
                        text: 'Order description saved successfully.',
                        timer: 2000,
                        showConfirmButton: false
                    });
                }).fail(function (xhr) {
                    Swal.fire({
                        icon: 'error',
                        title: 'Error!',
                        text: xhr.responseText || 'Error saving order description.',
                        confirmButtonColor: '#dc3545'
                    });
                });
            });
        });

        function updateHiddenDescription() {
            var orderDesc = $('#orderDescription').val().trim();
            $('#hiddenOrderDescription').val(orderDesc);
        }
    </script>
</head>
<body>
    <div class="d-flex">
        <!-- Sidebar -->
        <% if ("Waiter".equals(UserRole)) { %>
        <div class="sidebar">
            <h4>Waiter</h4>
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/order?action=listTables" class="nav-link active">
                        <i class="fas fa-building"></i> Table List
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/view-notifications" class="nav-link">
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
        <% } %>

        <!-- Main Content -->
        <div class="content">
            <div class="container">
                <h1>Table Details: <%= request.getAttribute("tableId")%></h1>

                <!-- Error Message -->
                <% if (request.getAttribute("error") != null) {%>
                <p class="error"><%= request.getAttribute("error")%></p>
                <% } %>

                <!-- Order Information -->
                <div class="order-info">
                    <h3>Order Information</h3>
                    <% if (order != null) {%>
                    <p><strong>Order ID:</strong> <%= order.getOrderId()%></p>
                    <p><strong>Status:</strong> <%= order.getOrderStatus()%></p>
                    <p><strong>Order Type:</strong> <%= order.getOrderType()%></p>
                    <p><strong>Order Date:</strong> <%= order.getOrderDate()%></p>
                    <p><strong>Total:</strong> <%= order.getTotal()%> VND</p>
                    <p><strong>Customer:</strong> 
                        <% if (currentCustomer != null) {%>
                        <%= currentCustomer.getCustomerName()%> (<%= currentCustomer.getCustomerPhone()%>)
                        <% } else { %>
                        Not selected
                        <% }%>
                    </p>
                    <div class="description-section">
                        <label for="orderDescription"><strong>Order Description:</strong></label><br>
                        <input type="text" id="orderDescription" name="orderDescription" 
                               value="<%= order.getOrderDescription() != null ? order.getOrderDescription() : ""%>">

                    </div>
                    <% } else { %>
                    <p>No order has been created yet.</p>
                    <% } %>
                </div>

                <!-- Dish List -->
                <div class="dish-list">
                    <h3>Dish List</h3>
                    <table class="table-list">
                        <tr>
                            <th>Dish Name</th>
                            <th>Quantity</th>
                            <th>Unit Price</th>
                            <th>Subtotal</th>
                            <th>Action</th>
                        </tr>
                        <% if (order != null && order.getOrderDetails() != null && !order.getOrderDetails().isEmpty()) { %>
                        <% for (OrderDetail detail : order.getOrderDetails()) {%>
                        <tr>
                            <td><%= detail.getDishName()%></td>
                            <td>
                                <div class="quantity-control">
                                    <button class="quantity-btn" onclick="updateQuantity('<%= detail.getOrderDetailId()%>', '<%= detail.getDishId()%>', '<%= request.getAttribute("tableId")%>', -1)">-</button>
                                    <input type="number" class="quantity-input" id="quantity_<%= detail.getDishId()%>" 
                                           value="<%= detail.getQuantity()%>" min="0" readonly>
                                    <button class="quantity-btn" onclick="updateQuantity('<%= detail.getOrderDetailId()%>', '<%= detail.getDishId()%>', '<%= request.getAttribute("tableId")%>', 1)">+</button>
                                </div>
                            </td>
                            <td><%= detail.getSubtotal() / detail.getQuantity()%> VND</td>
                            <td><%= detail.getSubtotal()%> VND</td>
                            <td>
                                <form action="${pageContext.request.contextPath}/order" method="post" style="display: inline;">
                                    <input type="hidden" name="action" value="deleteDish">
                                    <input type="hidden" name="orderDetailId" value="<%= detail.getOrderDetailId()%>">
                                    <input type="hidden" name="dishId" value="<%= detail.getDishId()%>">
                                    <input type="hidden" name="tableId" value="<%= request.getAttribute("tableId")%>">
                                    <button type="submit" class="button btn-danger">Delete</button>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                        <% } else { %>
                        <tr>
                            <td colspan="5" style="text-align: center;">No dishes in the order yet.</td>
                        </tr>
                        <% }%>
                    </table>
                    <a href="${pageContext.request.contextPath}/order?action=selectDish&tableId=<%= request.getAttribute("tableId")%>&returnTo=tableOverview" 
                       class="button btn-primary" style="margin-top: 15px;">Add Dish</a>
                </div>

                <!-- Customer Management -->
                <div class="customer-section">
                    <h3>Customer Management</h3>
                    <div>
                        <input type="checkbox" id="addCustomerCheckbox" onclick="toggleAddCustomerForm()">
                        <label for="addCustomerCheckbox">Add New Customer</label>
                    </div>

                    <div id="selectCustomerForm">
                        <form action="${pageContext.request.contextPath}/order" method="post">
                            <input type="hidden" name="action" value="selectCustomer">
                            <input type="hidden" name="tableId" value="<%= request.getAttribute("tableId")%>">
                            <input type="hidden" name="orderId" value="<%= order != null ? order.getOrderId() : ""%>">
                            <select name="customerId" onchange="this.form.submit()">
                                <option value="">-- Select Customer --</option>
                                <% for (Customer customer : customers) {%>
                                <option value="<%= customer.getCustomerId()%>" <%= order != null && customer.getCustomerId().equals(order.getCustomerId()) ? "selected" : ""%>>
                                    <%= customer.getCustomerName()%> (<%= customer.getCustomerPhone()%>)
                                </option>
                                <% }%>
                            </select>
                        </form>
                    </div>

                    <div id="addCustomerForm">
                        <form id="addCustomerFormTable">
                            <label>Customer Name:</label><br>
                            <input type="text" id="customerNameTable" name="customerName" required><br><br>
                            <label>Phone Number:</label><br>
                            <input type="text" id="customerPhoneTable" name="customerPhone" required><br><br>
                            <button type="button" id="btnAddCustomerTable" class="button btn-success">Add</button>
                        </form>
                    </div>
                </div>

                <!-- Action Buttons -->
                <div class="action-buttons">
                    <form action="${pageContext.request.contextPath}/order" method="post" style="display: inline;">
                        <input type="hidden" name="action" value="completeOrder">
                        <input type="hidden" name="tableId" value="<%= request.getAttribute("tableId")%>">
                        <input type="hidden" id="hiddenOrderDescription" name="orderDescription" value="">
                        <button type="submit" class="button btn-success" onclick="updateHiddenDescription()">Complete Order</button>
                    </form>
                    <% if (hasOrder != null && hasOrder && order != null && "Pending".equals(order.getOrderStatus())) {%>
                    <button id="btnCancelOrder" class="button btn-danger" style="margin-left: 10px;" 
                            data-order-id="<%= order.getOrderId()%>" data-table-id="<%= request.getAttribute("tableId")%>">
                        Cancel Order
                    </button>
                    <% } else { %>
                    <form action="${pageContext.request.contextPath}/order" method="get" style="display: inline;">
                        <input type="hidden" name="action" value="listTables">
                        <button type="submit" class="button btn-secondary" style="margin-left: 10px;">Back</button>
                    </form>
                    <% }%>
                </div>
            </div>
        </div>
    </div>
</body>
</html>