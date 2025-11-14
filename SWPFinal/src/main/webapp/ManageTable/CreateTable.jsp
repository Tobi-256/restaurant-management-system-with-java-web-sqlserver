<%--
    Document   : CreateTable
    Created on : Feb 23, 2025, 10:00:00 AM (Ví dụ thời gian)
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Create New Table</title>
        <script>
            // Bạn có thể thêm JavaScript validation nếu cần
        </script>
    </head>
    <body>
        <nav>
            <a href="ViewTableList">Table Management</a> <%-- Link to Table List --%>
        </nav>

        <div>
            <h2>Create New Table</h2>
            <div>
                <form method="post" action="CreateTable"> <%-- Form action to CreateTable Servlet --%>
                    <div>
                        <label for="TableStatus">Table Status</label>
                        <select id="TableStatus" name="TableStatus"> <%-- Dropdown for Table Status --%>
                            <option value="Available">Available</option>
                            <option value="Occupied">Occupied</option>
                            <option value="Reserved">Reserved</option>
                            <option value="Unavailable">Unavailable</option>
                        </select>
                    </div>
                    <div>
                        <label for="NumberOfSeats">Number Of Seats</label>
                        <input type="number" id="NumberOfSeats" name="NumberOfSeats" placeholder="Enter number of seats"> <%-- Number input for Seats --%>
                    </div>
                    <div>
                        <input type="submit" name="btnSubmit" value="Create Table"/>
                        <a href="ViewTableList">Back to List</a> <%-- Link to Table List --%>
                    </div>
                </form>
            </div>
        </div>
    </body>
</html>