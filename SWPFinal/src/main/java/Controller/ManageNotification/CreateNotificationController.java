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
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@WebServlet("/create-notification")
public class CreateNotificationController extends HttpServlet {
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

        if (!"Admin".equals(userRole) && !"Manager".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/view-notifications");
            return;
        }

        List<Account> accounts = notificationDAO.getAllAccounts();
        if ("Admin".equals(userRole)) {
            accounts = accounts.stream()
                    .filter(acc -> !acc.getUserId().equals(account.getUserId()))
                    .collect(Collectors.toList());
        } else if ("Manager".equals(userRole)) {
            accounts = accounts.stream()
                    .filter(acc -> !"Admin".equals(acc.getUserRole()) && !"Manager".equals(acc.getUserRole()))
                    .collect(Collectors.toList());
        }

        request.setAttribute("accounts", accounts);
        request.getRequestDispatcher("/ManageNotification/CreateNotification.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
            return;
        }

        Account account = (Account) session.getAttribute("account");
        String userRole = account.getUserRole();

        if (!"Admin".equals(userRole) && !"Manager".equals(userRole)) {
            session.setAttribute("errorMessage", "You do not have permission to create notifications.");
            response.sendRedirect(request.getContextPath() + "/view-notifications");
            return;
        }

        String notificationType = request.getParameter("notificationType");
        String content = request.getParameter("content");
        Notification notification = new Notification();
        notification.setNotificationContent(content);
        notification.setNotificationCreateAt(new Date());

        if ("all".equals(notificationType)) {
            notification.setUserId(null); // Thông báo cho tất cả
            notification.setUserRole(null);
            notification.setUserName(null);
        } else if ("role".equals(notificationType)) {
            String selectedRole = request.getParameter("role");
            if ("Manager".equals(userRole) && ("Admin".equals(selectedRole) || "Manager".equals(selectedRole))) {
                session.setAttribute("errorMessage", "Manager cannot send notifications to Admin or Manager.");
                response.sendRedirect(request.getContextPath() + "/create-notification");
                return;
            }
            notification.setUserId(null);
            notification.setUserRole(selectedRole);
            notification.setUserName(null);
        } else if ("individual".equals(notificationType)) {
            String selectedUserId = request.getParameter("UserId");
            Account selectedAccount = notificationDAO.getAllAccounts().stream()
                    .filter(a -> a.getUserId().equals(selectedUserId))
                    .findFirst().orElse(null);
            if (selectedAccount != null) {
                if ("Manager".equals(userRole) && ("Admin".equals(selectedAccount.getUserRole()) || "Manager".equals(selectedAccount.getUserRole()))) {
                    session.setAttribute("errorMessage", "Manager cannot send notifications to Admin or Manager.");
                    response.sendRedirect(request.getContextPath() + "/create-notification");
                    return;
                }
                notification.setUserId(selectedUserId); // UserId của người nhận
                notification.setUserRole(selectedAccount.getUserRole());
                notification.setUserName(selectedAccount.getUserName());
            }
        }

        notificationDAO.createNotification(notification);
        session.setAttribute("message", "Notification created successfully!");
        response.sendRedirect(request.getContextPath() + "/view-notifications");
    }
}