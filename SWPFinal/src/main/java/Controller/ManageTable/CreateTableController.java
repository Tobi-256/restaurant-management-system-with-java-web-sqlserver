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
import java.util.HashMap;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/CreateTable")
public class CreateTableController extends HttpServlet {

    private static final Logger LOGGER = Logger.getLogger(CreateTableController.class.getName());
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();
        JsonObject jsonResponse = new JsonObject();

        try {
            // Lấy tham số từ form, khớp với JSP
            String tableStatus = request.getParameter("tableStatus");
            int numberOfSeats = 0;
            int floorNumber = 0;
            boolean valid = true;
            Map<String, String> errors = new HashMap<>();

            // Debug để kiểm tra giá trị nhận được
            LOGGER.log(Level.INFO, "Received tableStatus: {0}", tableStatus);
            LOGGER.log(Level.INFO, "Received numberOfSeats: {0}", request.getParameter("numberOfSeats"));
            LOGGER.log(Level.INFO, "Received floorNumber: {0}", request.getParameter("floorNumber"));

            try {
                numberOfSeats = Integer.parseInt(request.getParameter("numberOfSeats"));
                if (numberOfSeats <= 0) {
                    errors.put("numberOfSeats", "Number of seats must be positive.");
                    valid = false;
                }
            } catch (NumberFormatException e) {
                errors.put("numberOfSeats", "Invalid number format for seats.");
                valid = false;
            }
            try {
                floorNumber = Integer.parseInt(request.getParameter("floorNumber"));
                if (floorNumber <= 0) {
                    errors.put("floorNumber", "Floor number must be positive.");
                    valid = false;
                }
            } catch (NumberFormatException e) {
                errors.put("floorNumber", "Invalid number format for floor.");
                valid = false;
            }
            if (tableStatus == null || tableStatus.trim().isEmpty() || 
                !("Available".equals(tableStatus) || "Reserved".equals(tableStatus) || "Occupied".equals(tableStatus))) {
                errors.put("tableStatus", "Please select a valid status (Available, Reserved, Occupied).");
                valid = false;
            }

            if (!valid) {
                jsonResponse.addProperty("success", false);
                JsonObject errorsJson = new JsonObject();
                errors.forEach(errorsJson::addProperty);
                jsonResponse.add("errors", errorsJson);
                out.print(gson.toJson(jsonResponse));
                out.flush();
                return;
            }

            // Tạo đối tượng Table với trạng thái chính xác
            Table table = new Table(tableStatus, numberOfSeats, floorNumber);
            TableDAO tableDAO = new TableDAO();
            int count = tableDAO.createTable(table);

            if (count > 0) {
                jsonResponse.addProperty("success", true);
                jsonResponse.addProperty("message", "Table created successfully with status: " + tableStatus);
            } else {
                jsonResponse.addProperty("success", false);
                jsonResponse.addProperty("message", "Failed to create table in database.");
            }
        } catch (NumberFormatException e) {
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Invalid number input.");
        } catch (ClassNotFoundException | SQLException ex) {
            LOGGER.log(Level.SEVERE, "Database error", ex);
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "Database error occurred: " + ex.getMessage());
        } catch (Exception ex) {
            LOGGER.log(Level.SEVERE, "Unexpected error", ex);
            jsonResponse.addProperty("success", false);
            jsonResponse.addProperty("message", "An unexpected server error occurred.");
        }

        out.print(gson.toJson(jsonResponse));
        out.flush();
    }
}