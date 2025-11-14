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

    Dish dish = (Dish) request.getAttribute("dish");
    List<DishInventory> dishIngredients = (List<DishInventory>) request.getAttribute("dishIngredients");
    List<InventoryItem> inventoryList = (List<InventoryItem>) request.getAttribute("inventoryList");
    List<Dish> dishList = (List<Dish>) request.getAttribute("dishList");
%>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Update Dish</title>
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
        <style>
            body {
                font-family: 'Roboto', sans-serif;
                background-color: #f8f9fa;
                margin: 0;
                padding: 0;
            }
            .sidebar {
                background: linear-gradient(to bottom, #2C3E50, #34495E);
                color: white;
                height: 100vh;
                position: fixed;
                width: 16.67%;
                top: 0;
                left: 0;
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
                padding: 10px 15px;
            }
            .sidebar h4 {
                font-size: 1.5rem;
                padding: 15px 0;
                color: #ffffff;
            }
            .top-navbar {
                position: fixed;
                top: 0;
                left: 16.67%;
                width: 83.33%;
                background-color: #2C3E50;
                color: white;
                padding: 15px 25px;
                z-index: 1000;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            }
            .top-navbar h3 {
                margin: 0;
                font-size: 1.5rem;
            }
            .top-navbar .nav-buttons {
                display: flex;
                gap: 15px;
            }
            .content-area {
                margin-left: 16.67%;
                padding: 80px 30px 30px 30px;
                min-height: 100vh;
            }
            .form-section {
                background: white;
                padding: 25px;
                border-radius: 10px;
                box-shadow: 0 4px 12px rgba(0,0,0,0.1);
            }
            .form-group {
                margin-bottom: 20px;
            }
            label {
                font-weight: 600;
                margin-bottom: 8px;
                color: #333;
                font-size: 1rem;
            }
            input[type="text"],
            input[type="number"],
            select,
            textarea,
            input[type="file"] {
                width: 100%;
                padding: 12px;
                border: 1px solid #ddd;
                border-radius: 6px;
                font-size: 1rem;
                transition: border-color 0.3s;
            }
            input[type="text"]:focus,
            input[type="number"]:focus,
            select:focus,
            textarea:focus {
                border-color: #4CAF50;
                outline: none;
            }
            textarea {
                min-height: 120px;
                resize: vertical;
            }
            input[type="number"].quantity-input {
                width: 90px;
                padding: 8px;
                margin-left: 15px;
                display: none;
            }
            .ingredient-list {
                max-height: 400px;
                overflow-y: auto;
                background-color: #f9f9f9;
                padding: 15px;
                border: 1px solid #ddd;
                border-radius: 6px;
            }
            .ingredient-item {
                display: flex;
                align-items: center;
                margin-bottom: 12px;
                padding: 10px;
                background: white;
                border-radius: 6px;
                box-shadow: 0 1px 4px rgba(0,0,0,0.05);
                transition: background-color 0.3s;
            }
            .ingredient-item label {
                flex: 1;
                font-size: 0.95rem;
                margin: 0;
            }
            .ingredient-item:has(input[type="checkbox"]:checked) {
                background-color: #e6ffe6;
            }
            #imagePreview {
                max-width: 200px;
                max-height: 200px;
                margin-top: 15px;
                border-radius: 6px;
                display: <%= dish != null && dish.getDishImage() != null ? "block" : "none"%>;
                border: 1px solid #ddd;
            }
            .error {
                color: #dc3545;
                font-size: 0.9rem;
                margin-top: 5px;
                display: block;
            }
            .btn-primary {
                background-color: #4CAF50;
                border-color: #4CAF50;
                padding: 8px 20px;
                font-size: 1rem;
                transition: background-color 0.3s;
            }
            .btn-primary:hover {
                background-color: #45a049;
                border-color: #45a049;
            }
            .btn-secondary {
                background-color: #6c757d;
                border-color: #6c757d;
                padding: 8px 20px;
                font-size: 1rem;
                transition: background-color 0.3s;
            }
            .btn-secondary:hover {
                background-color: #5a6268;
                border-color: #5a6268;
            }
            h4 {
                color: #34495E;
                margin-bottom: 20px;
                font-size: 1.25rem;
            }
            .search-filter {
                display: flex;
                gap: 15px;
                margin-bottom: 20px;
            }
            #ingredientSearch {
                flex: 1;
                padding: 10px;
                border: 1px solid #ddd;
                border-radius: 6px;
            }
            #ingredientFilter {
                width: 160px;
                padding: 10px;
                border: 1px solid #ddd;
                border-radius: 6px;
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

            <!-- Top Navbar -->
            <nav class="top-navbar">
                <h3>Update Dish</h3>
                <div class="nav-buttons">
                    <a href="${pageContext.request.contextPath}/viewalldish" class="btn btn-secondary">Back to Menu</a>
                    <button type="submit" form="updateDishForm" class="btn btn-primary">Save Changes</button>
                </div>
            </nav>

            <!-- Main Content -->
            <div class="col-md-10 content-area">
                <% if (request.getAttribute("generalError") != null) {%>
                <div class="alert alert-danger">
                    <%= request.getAttribute("generalError")%>
                </div>
                <% } %>

                <% if (dish != null) {%>
                <form id="updateDishForm" action="${pageContext.request.contextPath}/updatedish" method="post" enctype="multipart/form-data" onsubmit="return validateForm()">
                    <input type="hidden" name="dishId" value="<%= dish.getDishId()%>">
                    <div class="row">
                        <!-- Left Column: Dish Details -->
                        <div class="col-md-6">
                            <div class="form-section">
                                <div class="form-group">
                                    <label for="dishName">Dish Name</label>
                                    <input type="text" id="dishName" name="dishName" value="<%= dish.getDishName()%>">
                                    <span id="dishNameError" class="error"><%= request.getAttribute("dishNameError") != null ? request.getAttribute("dishNameError") : ""%></span>
                                </div>
                                <div class="form-group">
                                    <label for="dishType">Dish Type</label>
                                    <select id="dishType" name="dishType">
                                        <option value="Food" <%= "Food".equals(dish.getDishType()) ? "selected" : ""%>>Food</option>
                                        <option value="Drink" <%= "Drink".equals(dish.getDishType()) ? "selected" : ""%>>Drink</option>
                                    </select>
                                    <span id="dishTypeError" class="error"><%= request.getAttribute("dishTypeError") != null ? request.getAttribute("dishTypeError") : ""%></span>
                                </div>
                                <div class="form-group">
                                    <label for="dishPrice">Price</label>
                                    <input type="number" id="dishPrice" name="dishPrice" step="0.01" value="<%= dish.getDishPrice()%>">
                                    <span id="dishPriceError" class="error"><%= request.getAttribute("dishPriceError") != null ? request.getAttribute("dishPriceError") : ""%></span>
                                </div>
                                <div class="form-group">
                                    <label for="dishDescription">Description</label>
                                    <textarea id="dishDescription" name="dishDescription"><%= dish.getDishDescription() != null ? dish.getDishDescription() : ""%></textarea>
                                </div>
                                <div class="form-group">
                                    <label for="dishStatus">Dish Status</label>
                                    <select id="dishStatus" name="dishStatus">
                                        <option value="Available" <%= "Available".equals(dish.getDishStatus()) ? "selected" : ""%>>Available</option>
                                        <option value="Unavailable" <%= "Unavailable".equals(dish.getDishStatus()) ? "selected" : ""%>>Unavailable</option>
                                    </select>
                                </div>
                                <div class="form-group">
                                    <label for="ingredientStatus">Ingredient Status</label>
                                    <input type="text" id="ingredientStatus" value="<%= dish.getIngredientStatus()%>" readonly>
                                </div>
                                <!-- ... Phần đầu giữ nguyên ... -->
                                <div class="form-group">
                                    <label for="dishImage">Image</label>
                                    <input type="file" id="dishImage" name="dishImage" onchange="previewImage(event)">
                                    <input type="hidden" name="oldDishImage" value="<%= dish.getDishImage() != null ? dish.getDishImage() : ""%>">
                                    <img id="imagePreview" src="<%= dish != null && dish.getDishImage() != null ? request.getContextPath() + dish.getDishImage() : ""%>" alt="Image Preview">
                                    <span id="dishImageError" class="error"></span>
                                </div>
                                <!-- ... Phần còn lại giữ nguyên ... -->
                            </div>
                        </div>
                        <!-- Right Column: Ingredients -->
                        <div class="col-md-6">
                            <div class="form-section">
                                <h4>Ingredients</h4>
                                <div class="search-filter">
                                    <input type="text" id="ingredientSearch" placeholder="Search ingredients..." class="form-control">
                                    <select id="ingredientFilter" class="form-control">
                                        <option value="all">All</option>
                                        <option value="available">Available</option>
                                        <option value="unavailable">Unavailable</option>
                                    </select>
                                </div>
                                <div class="ingredient-list" id="ingredientList">
                                    <%
                                        if (inventoryList != null && !inventoryList.isEmpty()) {
                                            for (InventoryItem inventory : inventoryList) {
                                                String itemId = inventory.getItemId();
                                                DishInventory existingIngredient = null;
                                                if (dishIngredients != null) {
                                                    for (DishInventory di : dishIngredients) {
                                                        if (di.getItemId().equals(itemId)) {
                                                            existingIngredient = di;
                                                            break;
                                                        }
                                                    }
                                                }
                                                String status = inventory.getItemQuantity() > 0 ? "available" : "unavailable";
                                    %>
                                    <div class="ingredient-item" data-name="<%= inventory.getItemName().toLowerCase()%>" data-status="<%= status%>">
                                        <label for="itemId<%= itemId%>"><%= inventory.getItemName()%> (<%= inventory.getItemUnit()%>) - Qty: <%= inventory.getItemQuantity()%></label>
                                        <input type="checkbox" id="itemId<%= itemId%>" name="itemId" value="<%= itemId%>"
                                               onclick="showQuantityInput('<%= itemId%>'); updateIngredientState('<%= itemId%>')"
                                               <%= existingIngredient != null ? "checked" : ""%>>
                                        <input type="number" class="quantity-input" id="quantityUsed<%= itemId%>" name="quantityUsed<%= itemId%>"
                                               step="0.01" placeholder="Qty"
                                               value="<%= existingIngredient != null ? existingIngredient.getQuantityUsed() : ""%>"
                                               oninput="updateQuantityState('<%= itemId%>')">
                                    </div>
                                    <%
                                        }
                                    } else {
                                    %>
                                    <p class="error">No ingredients available.</p>
                                    <%
                                        }
                                    %>
                                </div>
                                <span id="ingredientsError" class="error"><%= request.getAttribute("ingredientsError") != null ? request.getAttribute("ingredientsError") : ""%></span>
                            </div>
                        </div>
                    </div>
                </form>
                <% } else { %>
                <p class="alert alert-danger">Dish not found.</p>
                <% } %>

                <!-- Success Modal Popup -->
                <% if (request.getAttribute("successMessage") != null) {%>
                <div class="modal fade" id="successModal" tabindex="-1" aria-labelledby="successModalLabel" aria-hidden="true">
                    <div class="modal-dialog modal-dialog-centered">
                        <div class="modal-content">
                            <div class="modal-header">
                                <h5 class="modal-title" id="successModalLabel">Success</h5>
                            </div>
                            <div class="modal-body">
                                <%= request.getAttribute("successMessage")%>
                            </div>
                        </div>
                    </div>
                </div>
                <% } %>
            </div>
        </div>

        <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
        <script>
                                                   const existingDishNames = [
            <%
                if (dishList != null) {
                    for (int i = 0; i < dishList.size(); i++) {
                        if (!dishList.get(i).getDishId().equals(dish.getDishId())) {
                            out.print("\"" + dishList.get(i).getDishName() + "\"");
                            if (i < dishList.size() - 1) {
                                out.print(",");
                            }
                        }
                    }
                }
            %>
                                                   ];

                                                   let allIngredients = [];
                                                   let ingredientStates = {}; // Lưu trạng thái của checkbox và quantity

                                                   function showQuantityInput(itemId) {
                                                       var quantityInput = document.getElementById("quantityUsed" + itemId);
                                                       if (document.getElementById("itemId" + itemId).checked) {
                                                           quantityInput.style.display = "inline";
                                                       } else {
                                                           quantityInput.style.display = "none";
                                                           quantityInput.value = "";
                                                       }
                                                   }

                                                   function updateIngredientState(itemId) {
                                                       const checkbox = document.getElementById("itemId" + itemId);
                                                       const quantityInput = document.getElementById("quantityUsed" + itemId);
                                                       ingredientStates[itemId] = {
                                                           checked: checkbox.checked,
                                                           quantity: quantityInput.value
                                                       };
                                                   }

                                                   function updateQuantityState(itemId) {
                                                       const checkbox = document.getElementById("itemId" + itemId);
                                                       const quantityInput = document.getElementById("quantityUsed" + itemId);
                                                       if (checkbox.checked) {
                                                           ingredientStates[itemId] = {
                                                               checked: true,
                                                               quantity: quantityInput.value
                                                           };
                                                       }
                                                   }

                                                   function previewImage(event) {
                                                       var reader = new FileReader();
                                                       reader.onload = function () {
                                                           var output = document.getElementById('imagePreview');
                                                           output.src = reader.result;
                                                           output.style.display = 'block';
                                                       };
                                                       reader.readAsDataURL(event.target.files[0]);
                                                   }

                                                   function sortIngredients(items) {
                                                       return items.sort((a, b) => {
                                                           const aChecked = a.querySelector('input[type="checkbox"]').checked;
                                                           const bChecked = b.querySelector('input[type="checkbox"]').checked;
                                                           return bChecked - aChecked; // Checked items go to the top
                                                       });
                                                   }

                                                   function renderIngredients() {
                                                       var searchValue = document.getElementById("ingredientSearch").value.toLowerCase();
                                                       var filterValue = document.getElementById("ingredientFilter").value;

                                                       var filteredItems = allIngredients.filter(item => {
                                                           var matchesSearch = item.getAttribute("data-name").includes(searchValue);
                                                           var matchesFilter = filterValue === "all" || item.getAttribute("data-status") === filterValue;
                                                           return matchesSearch && matchesFilter;
                                                       });

                                                       var container = document.getElementById("ingredientList");
                                                       container.innerHTML = "";

                                                       if (filteredItems.length === 0) {
                                                           container.innerHTML = "<p class='error'>No ingredients found.</p>";
                                                       } else {
                                                           filteredItems.forEach(item => {
                                                               const clonedItem = item.cloneNode(true);
                                                               const itemId = clonedItem.querySelector('input[type="checkbox"]').value;
                                                               const checkbox = clonedItem.querySelector('input[type="checkbox"]');
                                                               const quantityInput = clonedItem.querySelector('input[type="number"]');

                                                               // Áp dụng trạng thái đã lưu
                                                               if (ingredientStates[itemId]) {
                                                                   checkbox.checked = ingredientStates[itemId].checked;
                                                                   quantityInput.value = ingredientStates[itemId].quantity || "";
                                                                   quantityInput.style.display = checkbox.checked ? "inline" : "none";
                                                               }

                                                               // Gắn lại sự kiện onclick và oninput
                                                               checkbox.onclick = function () {
                                                                   showQuantityInput(itemId);
                                                                   updateIngredientState(itemId);
                                                               };
                                                               quantityInput.oninput = function () {
                                                                   updateQuantityState(itemId);
                                                               };

                                                               container.appendChild(clonedItem);
                                                           });
                                                       }
                                                   }

                                                   function validateForm() {
                                                       var dishName = document.getElementById("dishName").value.trim();
                                                       var dishType = document.getElementById("dishType").value.trim();
                                                       var dishPrice = document.getElementById("dishPrice").value;
                                                       var checkboxes = document.getElementsByName("itemId");
                                                       var isValid = true;

                                                       document.querySelectorAll('.error').forEach(e => e.innerHTML = '');

                                                       if (!dishName) {
                                                           document.getElementById("dishNameError").innerHTML = "Dish name is required.";
                                                           isValid = false;
                                                       } else if (existingDishNames.includes(dishName) && dishName !== "<%= dish.getDishName()%>") {
                                                           document.getElementById("dishNameError").innerHTML = "Dish name already exists.";
                                                           isValid = false;
                                                       }

                                                       if (!dishType) {
                                                           document.getElementById("dishTypeError").innerHTML = "Dish type is required.";
                                                           isValid = false;
                                                       }

                                                       if (!dishPrice || isNaN(dishPrice) || parseFloat(dishPrice) <= 0) {
                                                           document.getElementById("dishPriceError").innerHTML = "Price must be a number greater than 0.";
                                                           isValid = false;
                                                       }

                                                       var isChecked = false;
                                                       for (var i = 0; i < checkboxes.length; i++) {
                                                           if (checkboxes[i].checked) {
                                                               isChecked = true;
                                                               var itemId = checkboxes[i].value;
                                                               var quantityInput = document.getElementById("quantityUsed" + itemId);
                                                               if (!quantityInput.value.trim() || quantityInput.value <= 0) {
                                                                   document.getElementById("ingredientsError").innerHTML = "Please enter a valid quantity for all selected ingredients.";
                                                                   isValid = false;
                                                                   break;
                                                               }
                                                           }
                                                       }
                                                       if (!isChecked) {
                                                           document.getElementById("ingredientsError").innerHTML = "Please select at least one ingredient.";
                                                           isValid = false;
                                                       }

                                                       return isValid;
                                                   }

                                                   window.onload = function () {
                                                       allIngredients = Array.from(document.querySelectorAll(".ingredient-item"));
                                                       var checkboxes = document.getElementsByName("itemId");
                                                       for (var i = 0; i < checkboxes.length; i++) {
                                                           const itemId = checkboxes[i].value;
                                                           if (checkboxes[i].checked) {
                                                               document.getElementById("quantityUsed" + itemId).style.display = "inline";
                                                               ingredientStates[itemId] = {
                                                                   checked: true,
                                                                   quantity: document.getElementById("quantityUsed" + itemId).value
                                                               };
                                                           }
                                                       }

                                                       // Sort initially when page loads
                                                       allIngredients = sortIngredients(allIngredients);
                                                       renderIngredients();

            <% if (request.getAttribute("successMessage") != null) { %>
                                                       var successModal = new bootstrap.Modal(document.getElementById('successModal'), {});
                                                       successModal.show();
                                                       setTimeout(function () {
                                                           window.location.href = "${pageContext.request.contextPath}/viewalldish";
                                                       }, 3000);
            <% }%>

                                                       document.getElementById("ingredientSearch").addEventListener("input", renderIngredients);
                                                       document.getElementById("ingredientFilter").addEventListener("change", renderIngredients);
                                                   };
        </script>
    </body>
</html>