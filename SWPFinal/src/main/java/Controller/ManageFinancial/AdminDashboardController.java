package Controller.ManageFinancial;

import DAO.DashboardDAO;
import DAO.RevenueDAO;
import Model.Account;
import Model.Revenue;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet("/dashboard")
public class AdminDashboardController extends HttpServlet {

    private final DashboardDAO dashboardDAO = new DashboardDAO();
    private final RevenueDAO revenueDAO = new RevenueDAO();

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
            response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
            return;
        }

        // Quick Stats
        Double todayRevenue = revenueDAO.getTodayRevenue();
        int newOrders = dashboardDAO.getNewOrdersCount();
        int dishesForSale = dashboardDAO.getDishesForSaleCount();
        int activeEmployees = dashboardDAO.getActiveEmployeesCount();
        List<Revenue> revenueData = revenueDAO.getWeeklyRevenue();
        Map<String, Integer> topDishes = dashboardDAO.getTopSellingDishes();
        List<Map<String, Object>> recentOrders = dashboardDAO.getRecentOrders();

        // Log để kiểm tra dữ liệu
        System.out.println("Today Revenue: " + todayRevenue);
        System.out.println("New Orders: " + newOrders);
        System.out.println("Dishes for Sale: " + dishesForSale);
        System.out.println("Active Employees: " + activeEmployees);
        System.out.println("Revenue Data: " + revenueData);
        System.out.println("Top Dishes: " + topDishes);
        System.out.println("Recent Orders: " + recentOrders);

        // Truyền dữ liệu vào request
        request.setAttribute("todayRevenue", todayRevenue != null ? todayRevenue : 0.0);
        request.setAttribute("newOrders", newOrders);
        request.setAttribute("dishesForSale", dishesForSale);
        request.setAttribute("activeEmployees", activeEmployees);
        request.setAttribute("revenueData", revenueData);
        request.setAttribute("topDishes", topDishes);
        request.setAttribute("recentOrders", recentOrders);

        request.getRequestDispatcher("/Dashboard/AdminDashboard.jsp").forward(request, response);
    }
}