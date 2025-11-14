<%-- 
    Document   : UpdateInventoryItem
    Created on : Mar 2, 2025, 8:34:19 AM
    Author     : DELL-Laptop
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Update Inventory Item</title>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
        <style>
            .form-group {
                margin-bottom: 15px;
            }
            .panel-body {
                padding: 20px;
            }
            .current-image {
                max-width: 150px;
                max-height: 150px;
                margin-bottom: 10px;
            }
            .new-filename-input {
                border: 2px solid #ffc107; /* Màu vàng cảnh báo */
                padding: 8px;
            }
        </style>
    </head>

    <body>
        <div class="container body-content">
            <div class="panel panel-primary">
                <div class="panel-heading">
                    <h3 class="panel-title">Update Inventory Item</h3>
                </div>
                <div class="panel-body">
                    <form action="../UpdateInventoryItemController" method="POST" class="form-horizontal" enctype="multipart/form-data">
                        <div class="form-group">
                            <label for="itemId" class="control-label col-md-2">Item ID</label>
                            <div class="col-md-10">
                                <input type="text" class="form-control" id="itemId" name="itemId" value="<% out.print(request.getParameter("itemId")); %>" readonly>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="itemName" class="control-label col-md-2">Item Name</label>
                            <div class="col-md-10">
                                <input type="text" readonly="" class="form-control" id="itemName" name="itemName" value="<% out.print(request.getParameter("itemName")); %>" placeholder="Enter Item Name" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="itemType" class="control-label col-md-2">Item Type</label>
                            <div class="col-md-10">
                                <input type="text"readonly="" class="form-control" id="itemType" name="itemType" value="<% out.print(request.getParameter("itemType")); %>" placeholder="Enter Item Type" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="itemPrice" class="control-label col-md-2">Item Price</label>
                            <div class="col-md-10">
                                <input type="number" step="0.01" class="form-control" id="itemPrice" name="itemPrice" value="<% out.print(request.getParameter("itemPrice")); %>" placeholder="Enter Item Price" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="itemQuantity" class="control-label col-md-2">Item Quantity</label>
                            <div class="col-md-10">
                                <input type="number" class="form-control" id="itemQuantity" name="itemQuantity" value="<% out.print(request.getParameter("itemQuantity")); %>" placeholder="Enter Item Quantity" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="itemUnit" class="control-label col-md-2">Item Unit</label>
                            <div class="col-md-10">
                                <input type="text" readonly="" class="form-control" id="itemUnit" name="itemUnit" value="<% out.print(request.getParameter("itemUnit")); %>" placeholder="Enter Item Unit" required>
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="itemDescription" class="control-label col-md-2">Item Description</label>
                            <div class="col-md-10">
                                <textarea class="form-control" id="itemDescription" name="itemDescription" rows="3" placeholder="Enter Item Description"><% out.print(request.getParameter("itemDescription")); %></textarea>
                            </div>
                        </div>

                        <div class="form-group">
                            <label class="control-label col-md-2">Current Item Image</label>
                            <div class="col-md-10">
                                <%
                                    String currentImagePath = request.getParameter("itemImage");
                                    if (currentImagePath != null && !currentImagePath.isEmpty()) {
                                %>
                                <img src="<%= request.getContextPath()%>/<%= currentImagePath%>" alt="Current Item Image" class="current-image">
                                <%
                                    } else {
                                        out.print("No Current Image");
                                    }
                                %>
                                <input type="hidden" name="oldItemImage" value="<%= currentImagePath != null ? currentImagePath : ""%>">
                            </div>
                        </div>

                        <div class="form-group">
                            <label for="newItemImage" class="control-label col-md-2">New Item Image</label>
                            <div class="col-md-10">
                                <input type="file" id="newItemImage" name="newItemImage" accept="image/*" onchange="showFilenameInput()"> <%-- Gọi hàm JS khi chọn file --%>
                                <p class="help-block">Select a new image to update (Optional).</p>
                            </div>
                        </div>

                        <div class="form-group" id="newFilenameGroup" style="display: none;">
                            <label for="newItemFilename" class="control-label col-md-2">New Filename (Optional)</label>
                            <div class="col-md-10">
                                <div class="input-group"> <%-- Thêm input-group của Bootstrap --%>
                                    <input type="text" class="form-control new-filename-input" id="newItemFilename" name="newItemFilename" placeholder="Enter new filename (without extension)">
                                    <span class="input-group-addon" id="newFilenameExtension" style="background-color: #eee; border: 1px solid #ccc; border-left: none;"></span> <%-- Span hiển thị extension --%>
                                </div>
                                <p class="help-block">Enter a filename for the new image (optional, without extension). If empty, a unique filename will be generated.</p>
                            </div>
                        </div>


                        <div class="form-group">
                            <div class="col-md-offset-2 col-md-10">
                                <button type="submit" class="btn btn-warning">Update</button>
                                <a href="../ViewInventoryController" class="btn btn-default">Back to List</a>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script>
            function showFilenameInput() {
                var fileInput = document.getElementById('newItemImage');
                var filenameGroup = document.getElementById('newFilenameGroup');
                var filenameInput = document.getElementById('newItemFilename');
                var filenameExtensionSpan = document.getElementById('newFilenameExtension'); // Lấy span extension

                if (fileInput.files && fileInput.files.length > 0) {
                    filenameGroup.style.display = 'block';

                    var fileName = fileInput.files[0].name;
                    var lastDotIndex = fileName.lastIndexOf('.');
                    var filenameWithoutExtension = fileName; // Mặc định là toàn bộ tên file (nếu không có dấu chấm)
                    var fileExtension = '';

                    if (lastDotIndex > 0) { // Kiểm tra có dấu chấm (có extension)
                        filenameWithoutExtension = fileName.substring(0, lastDotIndex); // Tên file không extension
                        fileExtension = fileName.substring(lastDotIndex); // Phần mở rộng (bao gồm dấu chấm)
                    }

                    filenameInput.value = filenameWithoutExtension; // Điền tên file vào input
                    filenameExtensionSpan.textContent = fileExtension; // Điền extension vào span
                    filenameInput.classList.add('new-filename-input');
                    filenameInput.focus();
                    filenameInput.select();
                } else {
                    filenameGroup.style.display = 'none';
                    filenameInput.value = '';
                    filenameExtensionSpan.textContent = ''; // Xóa nội dung span extension khi không có file
                    filenameInput.classList.remove('new-filename-input');
                }
            }
        </script>
    </body>
</html>