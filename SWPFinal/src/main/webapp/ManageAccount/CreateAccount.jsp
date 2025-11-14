<%--
    Document   : CreateAccount
    Created on : Feb 21, 2025, 8:28:24 PM
    Author     : ADMIN
--%>

<%@page import="java.sql.ResultSet"%>
<%@page import="DAO.AccountDAO"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Create Employee Account</title>
        <script>
            function validateForm() {
                let email = document.getElementById("UserEmail").value.trim();
                let password = document.getElementById("UserPassword").value.trim();
                let name = document.getElementById("UserName").value.trim();
                let role = document.getElementById("UserRole").value;
                let idCard = document.getElementById("IdentityCard").value.trim();
                let address = document.getElementById("UserAddress").value.trim();

                if (!email || !password || !name || !role || !idCard || !address) {
                    alert("All fields are required.");
                    return false;
                }

                if (!email.endsWith("@gmail.com")) {
                    alert("Email must end with '@gmail.com'.");
                    return false;
                }

                if (!/^\d{12}$/.test(idCard)) {
                    alert("Identity Card must be exactly 12 digits.");
                    return false;
                }

                return true;
            }
        </script>
    </head>
    <body>
        <nav>
            <a href="ViewAccountList">Employee Accounts Management</a>
        </nav>

        <div>
            <h2>Create New Employee Account</h2>
            <div>
                <form method="post" action="CreateAccount" enctype="multipart/form-data" onsubmit="return validateForm()">
                    <div>
                        <label for="UserEmail">Email Address</label>
                        <input type="email" id="UserEmail" name="UserEmail" placeholder="Enter email">
                    </div>
                    <div>
                        <label for="UserPassword">Password</label>
                        <input type="password" id="UserPassword" name="UserPassword" placeholder="Password">
                    </div>
                    <div>
                        <label for="UserName">Full Name</label>
                        <input type="text" id="UserName" name="UserName" placeholder="Enter full name">
                    </div>
                    <div>
                        <label for="UserRole">Role</label>
                        <select id="UserRole" name="UserRole">
                            <option value="Manager">Manager</option>
                            <option value="Cashier">Cashier</option>
                            <option value="Waiter">Waiter</option>
                            <option value="Kitchen staff">Kitchen staff</option>
                        </select>
                    </div>
                    <div>
                        <label for="IdentityCard">Identity Card (12 digits)</label>
                        <input type="text" id="IdentityCard" name="IdentityCard" placeholder="Enter 12-digit ID Card number">
                    </div>
                    <div>
                        <label for="UserAddress">Address</label>
                        <input type="text" id="UserAddress" name="UserAddress" placeholder="Enter address">
                    </div>
                    <div>
                        <label for="UserImage">Profile Image</label>
                        <input type="file" id="UserImage" name="UserImage"> < !-- Đảm bảo name="UserImage" khớp với controller -->
                    </div>
                    <div>
                        <input type="submit" name="btnSubmit" value="Create Account"/>
                        <a href="ViewAccountList">Back to List</a>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>