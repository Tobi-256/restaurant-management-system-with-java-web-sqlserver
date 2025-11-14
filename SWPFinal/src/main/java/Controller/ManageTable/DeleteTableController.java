package Controller.ManageTable;

import DAO.TableDAO;
import Model.Table;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/DeleteTable")
public class DeleteTableController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(DeleteTableController.class.getName());
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();

        try {
            String tableId = request.getParameter("TableId");

            if (tableId == null || tableId.trim().isEmpty()) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Invalid TableId");
                out.print(gson.toJson(jsonResponse));
                return;
            }

            TableDAO tableDAO = new TableDAO();
            Table table = tableDAO.getTableById(tableId);
            if (table == null || table.isIsDeleted()) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Table not found or already deleted");
                out.print(gson.toJson(jsonResponse));
                return;
            }

            if (!"Available".equalsIgnoreCase(table.getTableStatus())) {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Cannot delete table. Only tables with 'Available' status can be deleted.");
                out.print(gson.toJson(jsonResponse));
                return;
            }

            int count = tableDAO.deleteTable(tableId);
            if (count > 0) {
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("message", "Table deleted successfully");
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Failed to delete table");
            }

        } catch (ClassNotFoundException | SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting table", ex);
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "An error occurred: " + ex.getMessage());
        } finally {
            out.print(gson.toJson(jsonResponse));
            out.flush();
            out.close();
        }
    }
}