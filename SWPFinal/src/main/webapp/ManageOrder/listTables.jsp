<%@page import="java.util.ArrayList"%>
<%@page import="java.util.List"%>
<%@page import="Model.Table"%>
<%@page import="Model.Account"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    if (session == null || session.getAttribute("account") == null) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    Account account = (Account) session.getAttribute("account");
    String userRole = account.getUserRole();
    String userName = account.getUserName();

    if (!"Waiter".equals(userRole)) {
        response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
        return;
    }

    List<Table> allTables = (List<Table>) request.getAttribute("tables");
    List<Integer> floorNumbers = new ArrayList<>();
    if (allTables != null) {
        for (Table table : allTables) {
            if (!floorNumbers.contains(table.getFloorNumber())) {
                floorNumbers.add(table.getFloorNumber());
            }
        }
    }

    int pageSize = 20;
    int totalTables = (allTables != null) ? allTables.size() : 0;
    int totalPages = (totalTables == 0) ? 1 : (int) Math.ceil((double) totalTables / pageSize);
    int currentPage = 1;

    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1;
            if (currentPage > totalPages) currentPage = totalPages;
        } catch (NumberFormatException e) {
            currentPage = 1;
        }
    }

    int startIndex = (currentPage - 1) * pageSize;
    int endIndex = Math.min(startIndex + pageSize, totalTables);
    List<Table> tables = (allTables != null && startIndex < totalTables) ? allTables.subList(startIndex, endIndex) : List.of();
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Table List - Waiter Dashboard</title>

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">

    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" integrity="sha512-9usAa10IRO0HhonpyAIVpjrylPvoDwiPUiKdWk5t3PyolY1cOd4DSE0Ga+ri4AuTroPR5aQvXU9xC6qOPnzFeg==" crossorigin="anonymous" referrerpolicy="no-referrer" />

    <!-- SweetAlert2 -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

    <style>
         body {
            font-family: 'Roboto', sans-serif;
            background-color: #f8f9fa;
            margin: 0;
            padding: 0;
            display: flex;
            justify-content: center;
            min-height: 100vh;
        }

        .container-fluid {
            padding: 0;
        }

        /* Sidebar */
        .sidebar {
            height: 100vh;
            width: 250px;
            position: fixed;
            top: 0;
            left: 0;
            background-color: #343a40;
            padding-top: 20px;
            transition: 0.3s;
            z-index: 1000;
        }

        .sidebar .nav-link {
            color: #fff;
            padding: 15px 25px;
            text-decoration: none;
            display: flex;
            align-items: center;
            transition: 0.3s;
            font-size: 16px;
        }

        .sidebar .nav-link i {
            margin-right: 10px;
            width: 20px;
            text-align: center;
        }

        .sidebar .nav-link:hover {
            background-color: #495057;
            color: #fff;
        }

        .sidebar .nav-link.active {
            background-color: #007bff;
            color: #fff;
        }

        .sidebar h4 {
            color: #fff;
            text-align: center;
            padding: 20px 0;
            margin: 0;
            font-size: 24px;
            font-weight: 600;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
        }

        /* Main Content */
        .main-content {
            margin-left: 250px;
            padding: 20px;
            min-height: 100vh;
            background-color: #f4f4f4;
            transition: 0.3s;
        }

        .content-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
        }

        .search-filter {
            display: flex;
            align-items: center;
            gap: 15px;
            flex-wrap: wrap;
        }

        .search-bar input {
            padding: 8px 12px;
            border: 1px solid #ccc;
            border-radius: 4px;
            width: 250px;
            font-size: 14px;
            transition: border-color 0.3s;
        }

        .search-bar input:focus {
            border-color: #007bff;
            outline: none;
        }

        .filter-bar select {
            padding: 8px 12px;
            border: 1px solid #ccc;
            border-radius: 4px;
            width: 150px;
            font-size: 14px;
            background-color: #fff;
            transition: border-color 0.3s;
        }

        .filter-bar select:focus {
            border-color: #007bff;
            outline: none;
        }

        .table-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 15px;
            margin-bottom: 20px;
        }

        .table-item {
            border: 1px solid #ddd;
            padding: 15px;
            border-radius: 5px;
            background-color: white;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            min-height: 120px;
            position: relative;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
            transition: transform 0.2s ease-in-out;
        }

        .table-item:hover {
            transform: translateY(-3px);
        }

        .table-item.available {
            border-left: 5px solid #28a745;
            background-color: #f8f9fa;
        }

        .table-item.occupied {
            border-left: 5px solid #ffc107;
            background-color: #fff9e6;
        }

        .table-item.reserved {
            border-left: 5px solid #0dcaf0;
            background-color: #e7f8fc;
        }

        .table-info {
            text-align: left;
            margin-bottom: 10px;
            font-size: 0.9rem;
        }

        .table-info div {
            margin-bottom: 3px;
        }

        .table-id, .table-floor {
            font-weight: bold;
            color: #343a40;
        }

        .table-status span {
            font-weight: bold;
            padding: 2px 6px;
            border-radius: 3px;
            font-size: 0.85rem;
        }

        .table-item.available .table-status span {
            background-color: #28a745;
            color: white;
        }

        .table-item.occupied .table-status span {
            background-color: #ffc107;
            color: #333;
        }

        .table-item.reserved .table-status span {
            background-color: #0dcaf0;
            color: white;
        }

        .table-buttons {
            position: absolute;
            top: 10px;
            right: 10px;
            display: flex;
            gap: 5px;
        }

        .table-buttons a {
            padding: 5px;
            border: none;
            text-decoration: none;
            border-radius: 50%;
            width: 30px;
            height: 30px;
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            transition: background-color 0.2s ease;
        }

        .table-buttons a.btn-action {
            background-color: #007bff;
        }

        .table-buttons a.btn-action:hover {
            background-color: #0056b3;
        }

        .no-data {
            grid-column: 1 / -1;
            text-align: center;
            padding: 40px;
            color: #6c757d;
            background-color: #f8f9fa;
            border: 1px dashed #dee2e6;
            border-radius: 5px;
        }

        .no-data i {
            font-size: 2.5em;
            display: block;
            margin-bottom: 15px;
        }

        /* Tiêu đề "Table List" không gradient */
        .page-title {
            padding: 15px 20px;
            background-color: #fff;
            border-bottom: 1px solid #dee2e6;
            margin: -20px -20px 20px -20px;
        }

        .page-title h2 {
            margin: 0;
            font-size: 24px;
            color: #343a40;
            font-weight: 600;
        }

        .pagination {
            display: flex;
            justify-content: center;
            list-style: none;
            padding: 0;
            margin-top: 30px;
        }

        .pagination li {
            margin: 0 3px;
        }

        .pagination a, .pagination span {
            padding: 6px 12px;
            border: 1px solid #dee2e6;
            text-decoration: none;
            color: #0d6efd;
            background-color: #fff;
            border-radius: .25rem;
            transition: background-color 0.2s ease, color 0.2s ease;
            font-size: 0.9rem;
        }

        .pagination a:hover {
            background-color: #e9ecef;
            color: #0a58ca;
        }

        .pagination a.active {
            background-color: #0d6efd;
            color: white;
            border-color: #0d6efd;
            font-weight: bold;
        }

        .pagination .disabled span {
            color: #6c757d;
            pointer-events: none;
            background-color: #e9ecef;
        }

        @media (max-width: 768px) {
            .sidebar {
                width: 200px;
            }
            .main-content {
                margin-left: 200px;
            }
            .content-header {
                flex-direction: column;
                align-items: stretch;
            }
            .search-filter {
                flex-direction: column;
                width: 100%;
            }
            .search-bar input, .filter-bar select {
                width: 100%;
                margin-bottom: 10px;
            }
        }

        @media (max-width: 576px) {
            .sidebar {
                width: 100%;
                height: auto;
                position: relative;
            }
            .main-content {
                margin-left: 0;
            }
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <!-- Sidebar -->
        <div class="sidebar">
            <h4>Waiter</h4>
            <ul class="nav flex-column">
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/order?action=listTables" class="nav-link active">
                        <i class="fas fa-building"></i> Table List
                    </a>
                </li>
                
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/view-notifications" class="nav-link">
                        <i class="fas fa-bell"></i> View Notifications
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/viewAccountDetail" class="nav-link">
                        <i class="fas fa-user"></i> View Profile
                    </a>
                </li>
                <li class="nav-item">
                    <a href="${pageContext.request.contextPath}/logout" class="nav-link">
                        <i class="fas fa-sign-out-alt"></i> Logout
                    </a>
                </li>
            </ul>
        </div>

        <!-- Main Content -->
        <div class="main-content">
            <div class="page-title">
                <h2>Table List</h2>
            </div>
            <div class="content-header">
                <div class="search-filter">
                    <div class="search-bar">
                        <input type="text" id="searchInput" placeholder="Search by ID or Seats">
                    </div>
                    <div class="filter-bar">
                        <select id="statusFilter">
                            <option value="">All Status</option>
                            <option value="Available">Available</option>
                            <option value="Occupied">Occupied</option>
                            <option value="Reserved">Reserved</option>
                        </select>
                    </div>
                    <div class="filter-bar">
                        <select id="floorFilter">
                            <option value="all">All Floors</option>
                            <% if (floorNumbers != null && !floorNumbers.isEmpty()) {
                                for (Integer floor : floorNumbers) { %>
                                <option value="<%= floor %>">Floor <%= floor %></option>
                            <% } } %>
                        </select>
                    </div>
                </div>
            </div>

            <div class="table-grid" id="tableGrid">
                <% if (tables != null && !tables.isEmpty()) {
                    for (Table table : tables) {
                        String tableClass = "table-item";
                        String statusText = table.getTableStatus();
                        if ("Available".equalsIgnoreCase(statusText)) {
                            tableClass += " available";
                        } else if ("Occupied".equalsIgnoreCase(statusText)) {
                            tableClass += " occupied";
                        } else if ("Reserved".equalsIgnoreCase(statusText)) {
                            tableClass += " reserved";
                        } %>
                <div class="<%= tableClass %>" id="tableItem-<%= table.getTableId() %>">
                    <div class="table-info">
                        <div class="table-id">ID: <%= table.getTableId() %></div>
                        <div class="table-floor">Floor: <%= table.getFloorNumber() %></div>
                        <div class="table-seats">Seats: <%= table.getNumberOfSeats() %></div>
                        <div class="table-status">Status: <span><%= statusText %></span></div>
                        <div>Order: <%= table.isHasOrder() ? "Pending" : "None" %></div>
                    </div>
                    <div class="table-buttons">
                        <a href="#" class="btn-action" onclick="handleTableClick('<%= table.getTableId() %>'); return false;">
                            <i class="fas <%= "Available".equals(table.getTableStatus()) ? "fa-plus" : "fa-eye" %>"></i>
                        </a>
                    </div>
                </div>
                <% } } else { %>
                <div class="no-data">
                    <i class="fas fa-chair"></i>
                    <span>NO TABLES AVAILABLE.</span>
                </div>
                <% } %>
            </div>

            <!-- Pagination -->
            <nav aria-label="Table navigation">
                <ul class="pagination">
                    <% if (totalPages > 1) { %>
                    <li class="page-item <%= currentPage <= 1 ? "disabled" : "" %>">
                        <a class="page-link" href="?page=<%= currentPage - 1 %>" aria-label="Previous">«</a>
                    </li>
                    <% int startPage = Math.max(1, currentPage - 2);
                       int endPage = Math.min(totalPages, currentPage + 2);
                       if (startPage > 1) { %>
                    <li class="page-item"><a class="page-link" href="?page=1">1</a></li>
                    <% if (startPage > 2) { %>
                    <li class="page-item disabled"><span class="page-link">...</span></li>
                    <% } } %>
                    <% for (int i = startPage; i <= endPage; i++) { %>
                    <li class="page-item <%= currentPage == i ? "active" : "" %>">
                        <a class="page-link" href="?page=<%= i %>"><%= i %></a>
                    </li>
                    <% } %>
                    <% if (endPage < totalPages) { %>
                    <% if (endPage < totalPages - 1) { %>
                    <li class="page-item disabled"><span class="page-link">...</span></li>
                    <% } %>
                    <li class="page-item"><a class="page-link" href="?page=<%= totalPages %>"><%= totalPages %></a></li>
                    <% } %>
                    <li class="page-item <%= currentPage >= totalPages ? "disabled" : "" %>">
                        <a class="page-link" href="?page=<%= currentPage + 1 %>" aria-label="Next">»</a>
                    </li>
                    <% } %>
                </ul>
            </nav>
        </div>
    </div>

    <!-- Bootstrap 5 JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js" integrity="sha384-geWF76RCwLtnZ8qwWowPQNguL3RmwHVBC9FhGdlKrxdiJJigb/j/68SIy3Te4Bkz" crossorigin="anonymous"></script>

    <script>
        const allTables = [
            <% if (allTables != null) {
                for (int i = 0; i < allTables.size(); i++) {
                    Table table = allTables.get(i);
                    out.print("{");
                    out.print("\"tableId\": \"" + table.getTableId() + "\",");
                    out.print("\"floorNumber\": \"" + table.getFloorNumber() + "\",");
                    out.print("\"numberOfSeats\": \"" + table.getNumberOfSeats() + "\",");
                    out.print("\"tableStatus\": \"" + table.getTableStatus() + "\",");
                    out.print("\"hasOrder\": " + table.isHasOrder());
                    out.print("}");
                    if (i < allTables.size() - 1) out.print(",");
                }
            } %>
        ];

        $(document).ready(function () {
            $('#searchInput').on('keyup', filterTables);
            $('#statusFilter').on('change', filterTables);
            $('#floorFilter').on('change', filterTables);
            filterTables();
        });

        function filterTables() {
            const searchText = $('#searchInput').val().toLowerCase();
            const selectedStatus = $('#statusFilter').val();
            const selectedFloor = $('#floorFilter').val();

            const filteredTables = allTables.filter(table => {
                const matchesSearch = table.tableId.toLowerCase().includes(searchText) ||
                                      table.numberOfSeats.toString().includes(searchText);
                const matchesStatus = selectedStatus === '' || table.tableStatus === selectedStatus;
                const matchesFloor = selectedFloor === 'all' || table.floorNumber.toString() === selectedFloor;
                return matchesSearch && matchesStatus && matchesFloor;
            });

            const pageSize = 20;
            const totalTables = filteredTables.length;
            const totalPages = Math.ceil(totalTables / pageSize);
            let currentPage = parseInt(new URLSearchParams(window.location.search).get("page")) || 1;
            if (currentPage < 1) currentPage = 1;
            if (currentPage > totalPages) currentPage = totalPages;

            const startIndex = (currentPage - 1) * pageSize;
            const endIndex = Math.min(startIndex + pageSize, totalTables);
            const paginatedTables = filteredTables.slice(startIndex, endIndex);

            const tableGrid = $('#tableGrid');
            tableGrid.empty();

            if (paginatedTables.length > 0) {
                paginatedTables.forEach(table => {
                    let tableClass = "table-item";
                    let statusText = table.tableStatus;
                    if ("Available" === statusText) tableClass += " available";
                    else if ("Occupied" === statusText) tableClass += " occupied";
                    else if ("Reserved" === statusText) tableClass += " reserved";

                    const tableHtml = '<div class="' + tableClass + '" id="tableItem-' + table.tableId + '">' +
                        '<div class="table-info">' +
                        '<div class="table-id">ID: ' + table.tableId + '</div>' +
                        '<div class="table-floor">Floor: ' + table.floorNumber + '</div>' +
                        '<div class="table-seats">Seats: ' + table.numberOfSeats + '</div>' +
                        '<div class="table-status">Status: <span>' + statusText + '</span></div>' +
                        '<div>Order: ' + (table.hasOrder ? "Pending" : "None") + '</div>' +
                        '</div>' +
                        '<div class="table-buttons">' +
                        '<a href="#" class="btn-action" onclick="handleTableClick(\'' + table.tableId + '\'); return false;">' +
                        '<i class="fas ' + (table.tableStatus === "Available" ? "fa-plus" : "fa-eye") + '"></i>' +
                        '</a>' +
                        '</div>' +
                        '</div>';
                    tableGrid.append(tableHtml);
                });
            } else {
                tableGrid.append(
                    '<div class="no-data">' +
                    '<i class="fas fa-chair"></i>' +
                    '<span>NO TABLES MATCH CURRENT FILTERS OR PAGE.</span>' +
                    '</div>'
                );
            }

            const pagination = $('nav[aria-label="Table navigation"] ul');
            pagination.empty();
            if (totalPages > 1) {
                let paginationHtml = '<li class="page-item ' + (currentPage <= 1 ? "disabled" : "") + '">' +
                    '<a class="page-link" href="?page=' + (currentPage - 1) + getFilterParams() + '" aria-label="Previous">«</a></li>';
                const startPage = Math.max(1, currentPage - 2);
                const endPage = Math.min(totalPages, currentPage + 2);

                if (startPage > 1) {
                    paginationHtml += '<li class="page-item"><a class="page-link" href="?page=1' + getFilterParams() + '">1</a></li>';
                    if (startPage > 2) paginationHtml += '<li class="page-item disabled"><span class="page-link">...</span></li>';
                }

                for (let i = startPage; i <= endPage; i++) {
                    paginationHtml += '<li class="page-item ' + (currentPage === i ? "active" : "") + '">' +
                        '<a class="page-link" href="?page=' + i + getFilterParams() + '">' + i + '</a></li>';
                }

                if (endPage < totalPages) {
                    if (endPage < totalPages - 1) paginationHtml += '<li class="page-item disabled"><span class="page-link">...</span></li>';
                    paginationHtml += '<li class="page-item"><a class="page-link" href="?page=' + totalPages + getFilterParams() + '">' + totalPages + '</a></li>';
                }

                paginationHtml += '<li class="page-item ' + (currentPage >= totalPages ? "disabled" : "") + '">' +
                    '<a class="page-link" href="?page=' + (currentPage + 1) + getFilterParams() + '" aria-label="Next">»</a></li>';
                pagination.html(paginationHtml);
            }
        }

        function getFilterParams() {
            const searchText = $('#searchInput').val();
            const selectedStatus = $('#statusFilter').val();
            const selectedFloor = $('#floorFilter').val();
            let params = '';
            if (searchText) params += '&search=' + encodeURIComponent(searchText);
            if (selectedStatus) params += '&status=' + encodeURIComponent(selectedStatus);
            if (selectedFloor && selectedFloor !== 'all') params += '&floor=' + encodeURIComponent(selectedFloor);
            return params;
        }

        function handleTableClick(tableId) {
            $.ajax({
                url: '${pageContext.request.contextPath}/order',
                type: 'GET',
                data: { action: 'checkOrderByTable', tableId: tableId },
                success: function (response) {
                    if (response.orderId) {
                        window.location.href = '${pageContext.request.contextPath}/order?action=tableOverview&tableId=' + tableId;
                    } else {
                        window.location.href = '${pageContext.request.contextPath}/order?action=selectDish&tableId=' + tableId + '&returnTo=listTables';
                    }
                },
                error: function (xhr, status, error) {
                    Swal.fire('Error!', 'Error checking table: ' + error, 'error');
                }
            });
        }
    </script>
</body>
</html>