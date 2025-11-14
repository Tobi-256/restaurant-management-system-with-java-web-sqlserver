package Controller.ManagerAccount;

import DAO.AccountDAO;
import Model.Account;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/ViewAccountList")
public class ViewAccountController extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            AccountDAO dao = new AccountDAO();
            String status = request.getParameter("status"); // active, inactive hoặc null
            String pageParam = request.getParameter("page");
            int currentPage = 1;

            // Xử lý tham số page
            if (pageParam != null && !pageParam.isEmpty()) {
                try {
                    currentPage = Integer.parseInt(pageParam);
                    if (currentPage < 1) currentPage = 1;
                } catch (NumberFormatException e) {
                    currentPage = 1;
                }
            }

            List<Account> accountList;
            int totalAccounts;
            int totalPages;

            // Mặc định hiển thị tab Active nếu không có tham số status
            if (status == null || status.isEmpty()) {
                status = "active";
            }

            if ("active".equals(status)) {
                accountList = dao.getActiveAccounts();
                request.setAttribute("viewMode", "active");
            } else if ("inactive".equals(status)) {
                accountList = dao.getInactiveAccounts();
                request.setAttribute("viewMode", "inactive");
            } else {
                accountList = dao.getAllAccount();
                request.setAttribute("viewMode", "all");
            }

            totalAccounts = accountList.size();
            totalPages = (int) Math.ceil((double) totalAccounts / PAGE_SIZE);

            // Giới hạn currentPage
            if (currentPage > totalPages) currentPage = totalPages;
            if (currentPage < 1) currentPage = 1;

            // Phân trang
            int startIndex = (currentPage - 1) * PAGE_SIZE;
            int endIndex = Math.min(startIndex + PAGE_SIZE, totalAccounts);
            List<Account> paginatedAccounts = accountList.subList(startIndex, endIndex);

            // Debug
            for (Account acc : paginatedAccounts) {
                System.out.println("User ID: " + acc.getUserId() + ", UserImage: " + acc.getUserImage() + ", IsDeleted: " + acc.isIsDeleted());
            }

            request.setAttribute("accountList", paginatedAccounts);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("currentPage", currentPage);
            request.setAttribute("status", status); // Để JSP sử dụng trong URL phân trang

            request.getRequestDispatcher("/ManageAccount/ViewAccountList.jsp").forward(request, response);
        } catch (ClassNotFoundException | SQLException ex) {
            Logger.getLogger(ViewAccountController.class.getName()).log(Level.SEVERE, null, ex);
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error loading account list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}