<%--
    Document   : UpdateAccount
    Created on : Feb 21, 2025, 8:28:39 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Edit Employee Account</title>
    </head>
    <body>
        <!-- Navbar -->
        <nav>
            <a href="ViewAccountList">Employee Accounts Management</a>
        </nav>

        <!-- Title and form content -->
        <div>
            <h2>Edit Employee Account</h2>
            <div>
                <form method="post" action="UpdateAccount" enctype="multipart/form-data" onsubmit="return validateForm()">
                    <input type="hidden" id="UserIdHidden" name="UserIdHidden" value="${account.userId}"/>

                    <div>
                        <div>
                            <div>
                                <img src="${pageContext.request.contextPath}${account.userImage}" alt="Current Image" style="width: 150px; height: 150px; border-radius: 50%; object-fit: cover;"/>
                            </div>
                            <label for="UserImage">Update Profile Image</label>
                            <input type="file" id="UserImage" name="UserImage"/>
                        </div>
                        <div>
                            <div>
                                <label for="UserId">User ID</label>
                                <input type="text" id="UserId" name="UserId" value="${account.userId}" readonly/>
                            </div>
                            <div>
                                <label for="UserEmail">Email Address</label>
                                <input type="email" id="UserEmail" name="UserEmail" value="${account.userEmail}"/>
                            </div>
                            <div>
                                <label for="UserPassword">Password</label>
                                <input type="password" id="UserPassword" name="UserPassword" value="${account.userPassword}"/>
                            </div>
                            <div>
                                <label for="UserName">Full Name</label>
                                <input type="text" id="UserName" name="UserName" value="${account.userName}"/>
                            </div>
                            <div>
                                <label for="UserRole">Role</label>
                                <select id="UserRole" name="UserRole">
                                    <option value="Manager" ${account.userRole == 'Manager' ? 'selected' : ''}>Manager</option>
                                    <option value="Cashier" ${account.userRole == 'Cashier' ? 'selected' : ''}>Cashier</option>
                                    <option value="Waiter" ${account.userRole == 'Waiter' ? 'selected' : ''}>Waiter</option>
                                    <option value="Kitchen staff" ${account.userRole == 'Kitchen staff' ? 'selected' : ''}>Kitchen staff</option>
                                </select>
                            </div>
                            <div>
                                <label for="IdentityCard">Identity Card (12 digits)</label>
                                <input type="text" id="IdentityCard" name="IdentityCard" value="${account.identityCard}"/>
                            </div>
                            <div>
                                <label for="UserAddress">Address</label>
                                <input type="text" id="UserAddress" name="UserAddress" value="${account.userAddress}"/>
                            </div>
                        </div>
                    </div>

                    <!-- Save and Back to List Buttons -->
                    <div>
                        <input type="submit" name="btnSubmit" value="Save Changes"/>
                        <a href="ViewAccountList">Back to List</a>
                    </div>
                </form>
            </div>
        </div>

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
    </body>
</html>