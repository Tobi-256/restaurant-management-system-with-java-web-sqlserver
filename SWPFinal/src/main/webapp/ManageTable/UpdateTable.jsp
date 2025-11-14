<%--
    Document   : UpdateTableStatus
    Created on : Feb 21, 2025, 8:28:39 PM
    Author     : ADMIN
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Edit Table Status</title> <%-- Updated title to Edit Table Status --%>
    </head>
    <body>
        <!-- Title and form content -->
        <div>
            <h2>Edit Table Status</h2> <%-- Updated title to Edit Table Status --%>
            <div>
                <form method="post" action="UpdateTable">
                    <input type="hidden" id="TableIdHidden" name="TableIdHidden" value="${table.tableId}"/> <%-- Hidden field for TableId, using "table" attribute from Controller --%>
                    <div>
                        <div>
                            <label for="TableId">Table ID</label> <%-- Updated label to Table ID --%>
                            <input type="number" id="TableId" name="TableId" value="${table.tableId}" readonly/> <%-- Display TableId as readonly --%>
                        </div>
                          <div>
                            <label for="NumberOfSeats">Number Of Seats</label> <%-- Updated label to Table ID --%>
                            <input type="number" id="NumberOfSeats" name="NumberOfSeats" value="${table.numberOfSeats}"/> <%-- Display TableId as readonly --%>
                        </div>
                        <div>
                            <label for="TableStatus">Table Status</label> <%-- Updated label to Table Status --%>
                            <select id="TableStatus" name="TableStatus"> <%-- Select dropdown for TableStatus --%>
                                <option value="Available" ${table.tableStatus == 'Available' ? 'selected' : ''}>Available</option>
                                <option value="Occupied" ${table.tableStatus == 'Occupied' ? 'selected' : ''}>Occupied</option>
                                <option value="Reserved" ${table.tableStatus == 'Reserved' ? 'selected' : ''}>Reserved</option>
                                <option value="Unavailable" ${table.tableStatus == 'Unavailable' ? 'selected' : ''}>Unavailable</option>
                            </select>
                        </div>
                    </div>

                    <!-- Save and Back to List Buttons -->
                    <div>
                        <input type="submit" name="btnSubmit" value="Save Changes"/> <%-- Keep button text as Save Changes --%>
                        <a href="ViewTableList">Back to List</a> <%-- Updated back link to ViewTableList --%>
                    </div>
                </form>
            </div>
        </div>

        <%-- No Javascript validation needed for simple status update, can add if required --%>
    </body>
</html>