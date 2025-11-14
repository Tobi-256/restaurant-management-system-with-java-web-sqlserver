package Controller.ManageTable;

import DAO.TableDAO;
import Model.Table;
import com.google.gson.Gson;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.util.stream.Collectors;

@WebServlet("/ViewTableList")
public class ViewTableListController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            TableDAO tableDAO = new TableDAO();
            List<Table> tableList = tableDAO.getAllTables();
            List<Integer> floorNumberList = tableDAO.getFloorNumbers();

            String search = request.getParameter("search");
            String status = request.getParameter("status");
            String floor = request.getParameter("floor");
            Logger.getLogger(ViewTableListController.class.getName()).log(Level.INFO,
                    "Nhận yêu cầu - Search: {0}, Status: {1}, Floor: {2}",
                    new Object[]{search, status, floor});

            // Áp dụng bộ lọc cho danh sách bàn
            List<Table> filteredTables = filterTables(tableList, search, status, floor);
            Logger.getLogger(ViewTableListController.class.getName()).log(Level.INFO,
                    "Kết quả lọc: {0} table", filteredTables.size());

            request.setAttribute("tableList", filteredTables);
            request.setAttribute("floorNumberList", floorNumberList);
            request.getRequestDispatcher("ManageTable/ViewTableList.jsp").forward(request, response);
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(ViewTableListController.class.getName()).log(Level.SEVERE, null, ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading table list");
        }
    }

    private List<Table> filterTables(List<Table> tables, String search, String status, String floor) {
        List<Table> filteredTables = new ArrayList<>(tables);

        if (search != null && !search.trim().isEmpty()) {
            String searchLower = search.toLowerCase();
            filteredTables = filteredTables.stream()
                    .filter(table -> String.valueOf(table.getTableId()).contains(searchLower)
                    || String.valueOf(table.getNumberOfSeats()).contains(searchLower))
                    .collect(Collectors.toList());
        }

        if (status != null && !status.trim().isEmpty()) {
            filteredTables = filteredTables.stream()
                    .filter(table -> table.getTableStatus().toLowerCase().equals(status))
                    .collect(Collectors.toList());
        }

        if (floor != null && !"all".equals(floor) && !floor.trim().isEmpty()) {
            filteredTables = filteredTables.stream()
                    .filter(table -> String.valueOf(table.getFloorNumber()).equals(floor))
                    .collect(Collectors.toList());
        }

        return filteredTables;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet for viewing the list of tables";
    }
}
