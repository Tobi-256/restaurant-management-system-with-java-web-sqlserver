package Controller.ManageNotification;

import DAO.NotificationDAO;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.ArrayList;
import java.util.List;
import java.util.Arrays; // Import Arrays để in mảng

@WebServlet(name = "DeleteNotification", urlPatterns = {"/DeleteNotification"})
public class DeleteNotificationController extends HttpServlet {

    private NotificationDAO notificationDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        notificationDAO = new NotificationDAO();
    }

    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        HttpSession session = request.getSession();

        // Get the array of notificationIds from request parameters
        String[] notificationIds = request.getParameterValues("notificationIds");

        // --- DEBUGGING ---
        System.out.println("DeleteNotificationController: processRequest called");
        if (notificationIds != null) {
            System.out.println("Notification IDs received: " + Arrays.toString(notificationIds)); // In mảng notificationIds
        } else {
            System.out.println("No notification IDs received.");
        }
        // --- END DEBUGGING ---

        try {
            if (notificationIds != null && notificationIds.length > 0) {
                // Convert String[] to List<Integer>
                List<Integer> IntegerNotificationIds = new ArrayList<>();
                for (String idStr : notificationIds) {
                    int notificationId = Integer.parseInt(idStr);
                    IntegerNotificationIds.add(notificationId);
                }
                // Delete each selected notification
                notificationDAO.deleteNotifications(IntegerNotificationIds);
                session.setAttribute("message", "Selected notifications deleted successfully");
            } else {
                session.setAttribute("errorMessage", "No notifications selected for deletion");
            }
            response.sendRedirect(request.getContextPath() + "/view-notifications");
        } catch (NumberFormatException e) {
            session.setAttribute("errorMessage", "Invalid notification ID format");
            response.sendRedirect(request.getContextPath() + "/view-notifications");
        } catch (Exception e) {
            session.setAttribute("errorMessage", "Error deleting notifications: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/view-notifications");
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    @Override
    public String getServletInfo() {
        return "Servlet for deleting multiple notifications by NotificationId";
    }
}