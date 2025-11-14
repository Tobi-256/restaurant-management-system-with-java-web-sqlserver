<%--
    Document   : UpdateCoupon
    Created on : Feb 23, 2025, 2:46:50 PM
    Author     : DELL-Laptop
--%>
<!DOCTYPE html>
<html>
    <head>
        <title>Web Application Development</title> <%-- Keep original title or change to "Update Coupon" for clarity --%>
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
                <h5>Update Coupon</h5> <%-- English Form Heading - More descriptive --%>
                <hr />
                <form action="../UpdateCouponController" method="POST"> <!-- Keep form tag -->
                    <div class="form-group">
                        <div class="control-label col-md-2">Coupon ID</div> <%-- English Label --%>
                        <div class="col-md-10">
                            <input type="text" readonly="true" class="form-control" value="<% out.print(request.getParameter("couponId")); %>" name="couponId" required/>
                        </div>
                    </div>


                    <div class="form-group">
                        <div class="control-label col-md-2">Discount Amount</div> <%-- English Label --%>
                        <div class="col-md-10">
                            <input type="number" step="0.01" class="form-control" value="<% out.print(request.getParameter("discountAmount")); %>" name="discountAmount"required/>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="control-label col-md-2">Quantity</div> <%-- English Label --%>
                        <div class="col-md-10">
                            <input type="number" class="form-control" value="<% out.print(request.getParameter("timesUsed")); %>" name="timesUsed"required/>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="control-label col-md-2">Expiration Date</div> <%-- English Label --%>
                        <div class="col-md-10">
                            <input type="date" class="form-control" value="<% out.print(request.getParameter("expirationDate"));%>" name="expirationDate"required/>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="col-md-offset-2 col-md-10">
                            <input type="submit" value="Update" class="btn btn-warning" /> <%-- English Button Text --%>
                            <a href="../ViewCouponController" class="btn btn-info">Back to List</a> <%-- English Button Text --%>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>