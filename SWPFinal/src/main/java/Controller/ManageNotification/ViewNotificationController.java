package Controller.ManageNotification;

import DAO.NotificationDAO;
import Model.Account;
import Model.Notification;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;

@WebServlet("/view-notifications")
public class ViewNotificationController extends HttpServlet {
    private final NotificationDAO notificationDAO = new NotificationDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
            return;
        }

        Account account = (Account) session.getAttribute("account");
        String userRole = account.getUserRole();
        String userId = account.getUserId();
        List<Notification> notifications;

        // Phân quyền xem thông báo
        if ("Admin".equals(userRole)) {
            // Admin xem tất cả thông báo
            notifications = notificationDAO.getAllNotifications();
        } else if ("Manager".equals(userRole)) {
            // Manager chỉ xem thông báo mình tạo
            notifications = notificationDAO.getNotificationsByCreator(userId);
        } else {
            // Các role còn lại (Cashier, Waiter, Kitchen staff) xem thông báo của mình
            notifications = notificationDAO.getNotificationsForUser(userId, userRole);
        }

        request.setAttribute("notifications", notifications);
        request.getRequestDispatcher("/ManageNotification/ViewNotification.jsp").forward(request, response);
    }
}