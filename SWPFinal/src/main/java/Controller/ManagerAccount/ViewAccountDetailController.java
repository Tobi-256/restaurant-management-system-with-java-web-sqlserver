package Controller.ManagerAccount;

import DAO.AccountDAO;
import Model.Account;
import java.io.IOException;
import java.sql.SQLException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@WebServlet("/viewAccountDetail")
public class ViewAccountDetailController extends HttpServlet {
    
    private AccountDAO accountDAO;
    
    @Override
    public void init() throws ServletException {
        try {
            accountDAO = new AccountDAO();
        } catch (ClassNotFoundException | SQLException e) {
            throw new ServletException("Cannot initialize AccountDAO", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        
        // Kiểm tra session và tài khoản đăng nhập
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
            return;
        }

        // Lấy thông tin tài khoản từ session
        Account loggedInAccount = (Account) session.getAttribute("account");
        String userId = loggedInAccount.getUserId();

        try {
            // Lấy thông tin chi tiết tài khoản từ database (đảm bảo dữ liệu mới nhất)
            Account account = accountDAO.getAccountById(userId, true);
            if (account == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Account not found");
                return;
            }

            // Đặt thông tin tài khoản vào request để hiển thị trên JSP
            request.setAttribute("account", account);
            request.getRequestDispatcher("ManageAccount/ViewAccountDetail.jsp").forward(request, response);
            
        } catch (SQLException | ClassNotFoundException e) {
            throw new ServletException("Error retrieving account details", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response); // Nếu cần xử lý POST, có thể mở rộng sau
    }
}