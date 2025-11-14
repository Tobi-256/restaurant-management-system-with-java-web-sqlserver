package Controller.ManageTable;

import DAO.TableDAO;
import Model.Table;
import com.google.gson.Gson; // Import Gson
import com.google.gson.JsonObject; // Import JsonObject
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.SQLException;
import java.util.HashMap; // For errors map
import java.util.Map; // For errors map
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/UpdateTable")
public class UpdateTableController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(UpdateTableController.class.getName());
    private final Gson gson = new Gson(); // Create a Gson instance

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // --- Set up for JSON response ---
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        Gson gson = new Gson(); // Make sure Gson library is added
        JsonObject jsonResponse = new JsonObject();

        try {
            String tableId = request.getParameter("TableIdHidden");
            String tableStatus = request.getParameter("TableStatus");

            // Basic Server-Side Validation (example)
            int numberOfSeats = 0;
            int floorNumber = 0;
            boolean valid = true;
            Map<String, String> errors = new HashMap<>();

            if (tableId == null || tableId.trim().isEmpty()) {
                // This indicates a problem with the form/JS sending data
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Table ID is missing. Cannot update.");
                out.print(gson.toJson(jsonResponse));
                out.flush();
                return;
            }

            try {
                numberOfSeats = Integer.parseInt(request.getParameter("NumberOfSeats"));
                if (numberOfSeats <= 0) {
                    errors.put("NumberOfSeats", "Number of seats must be positive.");
                    valid = false;
                }
            } catch (NumberFormatException e) {
                errors.put("NumberOfSeats", "Invalid number format for seats.");
                valid = false;
            }
            try {
                floorNumber = Integer.parseInt(request.getParameter("FloorNumber"));
                if (floorNumber <= 0) {
                    errors.put("FloorNumber", "Floor number must be positive.");
                    valid = false;
                }
            } catch (NumberFormatException e) {
                errors.put("FloorNumber", "Invalid number format for floor.");
                valid = false;
            }
            if (tableStatus == null || tableStatus.trim().isEmpty()) {
                errors.put("TableStatus", "Status cannot be empty.");
                valid = false;
            }

            // If validation fails, return error JSON
            if (!valid) {
                jsonResponse.addProperty("success", false);
                JsonObject errorsJson = new JsonObject();
                errors.forEach(errorsJson::addProperty);
                jsonResponse.add("errors", errorsJson);
                out.print(gson.toJson(jsonResponse));
                out.flush();
                return; // Stop processing
            }

            // Proceed if valid
            Table table = new Table(tableId, tableStatus, numberOfSeats, floorNumber);
            TableDAO dao = new TableDAO();
            int count = dao.updateTable(tableId, table); // Ensure DAO method is correct

            if (count > 0) {
                // --- Send SUCCESS JSON response ---
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("message", "Table updated successfully!");
            } else {
                // --- Send FAILURE JSON response (e.g., ID not found) ---
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Update failed. Table not found or no changes detected.");
            }
        } catch (NumberFormatException e) { // Catch specifically for parsing errors if not handled above
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Invalid number input.");
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(UpdateTableController.class.getName()).log(Level.SEVERE, null, ex);
            // --- Send ERROR JSON response ---
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Database error occurred: " + ex.getMessage());
        } catch (Exception ex) { // Catch any other unexpected errors
            Logger.getLogger(UpdateTableController.class.getName()).log(Level.SEVERE, "Unexpected error", ex);
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "An unexpected server error occurred.");
        }

        // --- Write the JSON response ---
        out.print(gson.toJson(jsonResponse));
        out.flush();

    }

}
