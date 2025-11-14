<%-- 
    Document   : AddInventoryItem
    Created on : Feb 27, 2025, 10:33:45 AM
    Author     : DELL-Laptop
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>Add New Inventory Item</title>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    </head>
    <body>
        <nav class="navbar navbar-inverse">
            <div class="container-fluid">
                <div class="navbar-header">
                    <a class="navbar-brand" href="#">MANAGE INVENTORY ITEM</a>
                </div>
                <ul class="nav navbar-nav">
                    <li class="active"><a href="#">About us</a></li>
                    <li><a href="#">Contact Us</a></li>
                </ul>
            </div>
        </nav>
        <div class="container body-content">
            <h4>ADD NEW INVENTORY ITEM</h4>
            <div class="form-horizontal">
                <h5>Enter Item Details</h5>
                <hr />
                <form action="../AddInventoryItemController" method="POST" enctype="multipart/form-data">
                    <div class="form-group">
                        <label class="control-label col-md-2">Item Name</label>
                        <div class="col-md-10">
                            <input type="text" class="form-control" name="itemName" required placeholder="Enter Item Name" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="control-label col-md-2">Item Type</label>
                        <div class="col-md-10">
                            <select class="form-control" name="itemType" required> <%-- Changed to <select> element and added required --%>
                                <option value="">Select Item Type</option> <%-- Default option prompting selection --%>
                                <option value="Food">Food</option>         <%-- Option for Food --%>
                                <option value="Drink">Drink</option>        <%-- Option for Drink --%>
                            </select>
                        </div>
                    </div>


                    <div class="form-group">
                        <label class="control-label col-md-2">Item Price</label>
                        <div class="col-md-10">
                            <input type="number" step="0.01" class="form-control" name="itemPrice" required placeholder="Enter Item Price" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="control-label col-md-2">Quantity</label>
                        <div class="col-md-10">
                            <input type="number" class="form-control" name="itemQuantity" required placeholder="Enter Quantity" />
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="control-label col-md-2">Unit</label>
                        <div class="col-md-10">
                            <select class="form-control" name="itemUnit" required> <%-- Changed to <select> element and added required --%>
                                <option value="">Select Unit</option> <%-- Default option prompting selection --%>
                                <option value="kg">kg</option>         <%-- Example Unit options --%>
                                <option value="piece">Piece</option>
                                <option value="liter">Liter</option>
                                <option value="box">Box</option>
                                <option value="gram">Gram</option>
                                <option value="ml">ml</option>
                                <%-- Add more units as needed --%>
                            </select>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="control-label col-md-2">Description</label>
                        <div class="col-md-10">
                            <textarea class="form-control" name="itemDescription" placeholder="Enter Item Description"></textarea>
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="control-label col-md-2" for="itemImage">Image </label>
                        <div class="col-md-10">
                            <input type="file" class="form-control" id="itemImage" name="itemImage">  <!-- Input type file để chọn file hình ảnh -->
                        </div>
                    </div>
                    <div class="form-group">
                        <label class="control-label col-md-2" for="imageName">Image Name (Optional)</label>
                        <div class="col-md-10">
                            <input type="text" class="form-control" id="imageName" name="imageName" placeholder="Enter image name (optional)">
                        </div>
                    </div>
                    <div class="form-group">
                        <div class="col-md-offset-2 col-md-10">
                            <input type="submit" value="Add Item" class="btn btn-warning" />
                            <a href="../ViewInventoryController" class="btn btn-info">Back to list</a>
                        </div>
                    </div>
                </form>
            </div>
            <h3 style="color: red">
                <%
                    String error = (String) request.getAttribute("error");
                    if (error != null && !error.isEmpty()) {
                        out.print(error);
                    }
                %>
            </h3>
        </div>

        <script>
            document.getElementById('itemImage').addEventListener('change', function () {
                const fileInput = this;
                const imageNameInput = document.getElementById('imageName');

                if (fileInput.files && fileInput.files[0]) {
                    const fileName = fileInput.files[0].name;
                    const lastDotIndex = fileName.lastIndexOf('.');
                    let imageNameBase = fileName;
                    let fileExtension = "";

                    if (lastDotIndex > 0) {
                        imageNameBase = fileName.substring(0, lastDotIndex);
                        fileExtension = fileName.substring(lastDotIndex);
                    }

                    imageNameInput.value = imageNameBase;

                    // Chọn (tô sáng) phần tên file (không có phần mở rộng)
                    imageNameInput.focus(); // Đảm bảo input được focus trước khi select
                    imageNameInput.setSelectionRange(0, imageNameBase.length); // Chọn từ đầu đến hết phần tên
                }
            });
        </script>
    </body>
</html>