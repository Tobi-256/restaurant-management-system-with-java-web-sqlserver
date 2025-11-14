package Controller.ManagerAccount;

import DAO.AccountDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/DeleteAccount")
public class DeleteAccountController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Set response type to JSON
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        String userId = request.getParameter("UserId");

        if (userId == null || userId.trim().isEmpty()) {
            out.print("{\"success\": false, \"message\": \"User ID is required.\"}");
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST); // 400
        } else {
            try {
                AccountDAO dao = new AccountDAO();
                int count = dao.deleteAccount(userId); // Assuming this marks account as inactive
                if (count > 0) {
                    out.print("{\"success\": true, \"message\": \"Account marked as inactive.\"}");
                    System.out.println("Account with ID " + userId + " deleted successfully.");
                } else {
                    out.print("{\"success\": false, \"message\": \"Failed to delete account or account not found.\"}");
                    response.setStatus(HttpServletResponse.SC_NOT_FOUND); // 404
                    System.out.println("Failed to delete account with ID " + userId + " or account not found.");
                }
            } catch (Exception e) {
                String errorMessage = "{\"success\": false, \"message\": \"Server error: " + escapeJson(e.getMessage()) + "\"}";
                out.print(errorMessage);
                response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR); // 500
                System.err.println("Error deleting account: " + e.getMessage());
                e.printStackTrace();
            }
        }

        out.flush();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/plain");
        response.getWriter().write("This endpoint only supports POST requests.");
        response.setStatus(HttpServletResponse.SC_METHOD_NOT_ALLOWED); // 405
    }

    @Override
    public String getServletInfo() {
        return "Servlet to delete an account via AJAX";
    }

    // Helper method to escape special characters in JSON strings
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\"", "\\\"") // Escape double quotes
                  .replace("\\", "\\\\") // Escape backslashes
                  .replace("\n", "\\n")  // Escape newlines
                  .replace("\r", "\\r")  // Escape carriage returns
                  .replace("\t", "\\t"); // Escape tabs
    }
}