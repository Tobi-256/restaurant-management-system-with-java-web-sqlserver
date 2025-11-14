<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Tasty Restaurant</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    <style>
        body {
            font-family: 'Poppins', sans-serif;
            background: url('https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?ixlib=rb-4.0.3&auto=format&fit=crop&w=1350&q=80') no-repeat center center fixed;
            background-size: cover;
            height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .login-container {
            background: rgba(255, 255, 255, 0.9);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 8px 16px rgba(0, 0, 0, 0.2);
            max-width: 400px;
            width: 100%;
        }
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .login-header h2 {
            color: #d35400;
            font-weight: 700;
            text-transform: uppercase;
        }
        .login-header img {
            width: 80px;
            margin-bottom: 10px;
        }
        .form-control {
            border-radius: 25px;
            padding: 12px 20px;
            border: 1px solid #e67e22;
        }
        .form-control:focus {
            border-color: #d35400;
            box-shadow: 0 0 5px rgba(211, 84, 0, 0.5);
        }
        .btn-login {
            background-color: #e67e22;
            border: none;
            border-radius: 25px;
            padding: 12px;
            font-weight: 600;
            transition: background-color 0.3s;
            width: 100%;
        }
        .btn-login:hover {
            background-color: #d35400;
        }
        .alert {
            border-radius: 10px;
            margin-bottom: 20px;
        }
        .input-group-text {
            background-color: #e67e22;
            color: white;
            border: none;
            border-radius: 25px 0 0 25px;
            padding: 12px 15px;
        }
        .input-group {
            position: relative;
        }
        .toggle-password {
            position: absolute;
            right: 10px;
            top: 50%;
            transform: translateY(-50%);
            background: none;
            border: none;
            color: #e67e22;
            cursor: pointer;
            font-size: 1.1rem;
            padding: 0;
            z-index: 10;
        }
        .toggle-password:hover {
            color: #d35400;
        }
        .form-control.password-field {
            padding-right: 40px; /* Để chừa chỗ cho biểu tượng mắt */
            border-radius: 25px; /* Giữ bo tròn đều */
        }
    </style>
</head>
<body>
    <div class="login-container">
        <div class="login-header">
            <img src="https://img.icons8.com/color/96/000000/restaurant.png" alt="Restaurant Logo">
            <h2>Tasty Restaurant</h2>
            <p class="text-muted">By GROUP 6 - SE1808</p>
        </div>

        <% String error = (String) request.getAttribute("error");
           if (error != null) { %>
        <div class="alert alert-danger"><%= error %></div>
        <% } %>

        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="mb-3">
                <label for="email" class="form-label fw-bold text-dark">Email</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-envelope"></i></span>
                    <input type="email" class="form-control" id="email" name="email" placeholder="Enter email" required>
                </div>
            </div>
            <div class="mb-4">
                <label for="password" class="form-label fw-bold text-dark">Password</label>
                <div class="input-group">
                    <span class="input-group-text"><i class="fas fa-lock"></i></span>
                    <input type="password" class="form-control password-field" id="password" name="password" placeholder="Enter password" required>
                    <button type="button" class="toggle-password" onclick="togglePassword()">
                        <i class="fas fa-eye" id="toggleIcon"></i>
                    </button>
                </div>
            </div>
            <button type="submit" class="btn btn-login">Login</button>
        </form>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0-alpha1/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script>
        function togglePassword() {
            const passwordInput = document.getElementById("password");
            const toggleIcon = document.getElementById("toggleIcon");
            if (passwordInput.type === "password") {
                passwordInput.type = "text";
                toggleIcon.classList.remove("fa-eye");
                toggleIcon.classList.add("fa-eye-slash");
            } else {
                passwordInput.type = "password";
                toggleIcon.classList.remove("fa-eye-slash");
                toggleIcon.classList.add("fa-eye");
            }
        }
    </script>
</body>
</html>