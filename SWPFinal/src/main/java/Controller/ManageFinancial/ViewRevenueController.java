package Controller.ManageFinancial;

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

@WebServlet("/view-revenue")
public class ViewRevenueController extends HttpServlet {

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

        if (!"Admin".equals(userRole)) {
            response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
            return;
        }

        // Lấy tham số từ request (mặc định là "week" nếu không có)
        String period = request.getParameter("period") != null ? request.getParameter("period") : "week";

        // Dữ liệu tổng quan
        double totalRevenue = 0.0;
        List<Revenue> revenueByPeriod = null;

        switch (period) {
            case "hour": // Thêm case cho tùy chọn "hour"
                totalRevenue = revenueDAO.getTodayRevenue(); // Tổng doanh thu ngày hiện tại
                revenueByPeriod = revenueDAO.getRevenueByHourToday(); // Doanh thu theo giờ trong ngày
                break;
            case "day":
                totalRevenue = revenueDAO.getTodayRevenue();
                revenueByPeriod = revenueDAO.getRevenueByHourToday();
                break;
            case "week":
                totalRevenue = revenueDAO.getWeeklyRevenueTotal();
                revenueByPeriod = revenueDAO.getWeeklyRevenue();
                break;
            case "month":
                totalRevenue = revenueDAO.getMonthlyRevenueTotal();
                revenueByPeriod = revenueDAO.getMonthlyRevenue();
                break;
            case "year":
                totalRevenue = revenueDAO.getYearlyRevenueTotal();
                revenueByPeriod = revenueDAO.getYearlyRevenue();
                break;
            default:
                totalRevenue = revenueDAO.getWeeklyRevenueTotal();
                revenueByPeriod = revenueDAO.getWeeklyRevenue();
        }

        // Truyền dữ liệu vào request
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("revenueByPeriod", revenueByPeriod);
        request.setAttribute("period", period);

        // Log để kiểm tra
        System.out.println("Period: " + period);
        System.out.println("Total Revenue: " + totalRevenue);
        System.out.println("Revenue by Period: " + revenueByPeriod);

        request.getRequestDispatcher("/ManageFinancial/ViewRevenue.jsp").forward(request, response);
    }
}