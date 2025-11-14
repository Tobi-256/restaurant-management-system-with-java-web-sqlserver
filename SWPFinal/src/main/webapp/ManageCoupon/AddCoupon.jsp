<%--
    Document   : AddCoupon
    Created on : Feb 23, 2025, 11:29:14 AM
    Author     : DELL-Laptop
--%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Add New Coupon</title> <%-- English Page Title --%>
        <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
        <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
    </head>
    <body>
        <nav class="navbar navbar-inverse">
            <div class="container-fluid">
                <div class="navbar-header">
                    <a class="navbar-brand" href="#">COUPON MANAGEMENT</a> <%-- English Navbar Brand --%>
                </div>
                <ul class="nav navbar-nav">
                    <li class="active"><a href="#">About Us</a></li> <%-- English Menu Item --%>
                    <li><a href="#">Contact Us</a></li> <%-- English Menu Item --%>
                </ul>
            </div>
        </nav>
        <div class="container body-content">
            <h4>COUPON MANAGEMENT</h4> <%-- English Main Heading --%>
            <div class="form-horizontal">
                <h5>New Coupon</h5> <%-- English Form Heading --%>
                <hr />
                <form action="../AddCouponController" method="POST">
                    <div class="form-group">
                        <label class="control-label col-md-2" for="discountAmount">Discount Amount</label> <%-- English Label --%>
                        <div class="col-md-10">
                            <input type="number" step="0.01" class="form-control" id="discountAmount" value="" name="discountAmount" placeholder="Enter discount amount" required /> <%-- English Placeholder --%>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="control-label col-md-2" for="expirationDate">Expiration Date</label> <%-- English Label --%>
                        <div class="col-md-10">
                            <input type="date" class="form-control" id="expirationDate" value="" name="expirationDate" required/>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="col-md-offset-2 col-md-10">
                            <input type="submit" value="Save" class="btn btn-warning" /> <%-- English Button Text --%>
                            <a href="../ViewCouponController" class="btn btn-info">Back to List</a> <%-- English Button Text --%>
                        </div>
                    </div>
                </form>
            </div>
            <h3 style="color: red">
                <%-- Display error message from Servlet --%>
                <%
                    String error = (String) request.getAttribute("error");
                    if (error != null && !error.isEmpty()) {
                        out.print(error);
                    }
                %>
            </h3>
        </div>
    </body>
</html>