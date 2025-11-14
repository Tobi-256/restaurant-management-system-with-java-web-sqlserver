package Controller.ManageMenu;

import DAO.MenuDAO;
import Model.Account;
import Model.Dish;
import Model.InventoryItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/viewalldish")
public class ViewAllDishController extends HttpServlet {

    private final MenuDAO menuDAO = new MenuDAO();
    private static final Logger LOGGER = Logger.getLogger(ViewAllDishController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false); // Không tạo session mới nếu chưa có
        if (session == null || session.getAttribute("account") == null) {
            response.sendRedirect(request.getContextPath() + "/LoginPage.jsp"); // Chuyển hướng nếu chưa đăng nhập
            return;
        }

        // Lấy đối tượng Account từ session
        Account account = (Account) session.getAttribute("account");
        String UserRole = account.getUserRole();

        // Kiểm tra vai trò: chỉ Admin được truy cập
        if (!"Admin".equals(UserRole)) {
            response.sendRedirect(request.getContextPath() + "/LoginPage.jsp"); // Chuyển hướng nếu không phải Admin
            return;
        }

        List<Dish> dishList = menuDAO.getAllDishes();
        List<InventoryItem> inventoryList = menuDAO.getAllInventory();

        LOGGER.log(Level.INFO, "Dish list size: " + (dishList != null ? dishList.size() : "null"));
        LOGGER.log(Level.INFO, "Inventory list size: " + (inventoryList != null ? inventoryList.size() : "null"));

        if (dishList == null) {
            request.setAttribute("errorMessage", "Failed to load dish list.");
        }
        if (inventoryList == null) {
            request.setAttribute("errorMessage", "Failed to load inventory list.");
        } else if (inventoryList.isEmpty()) {
            request.setAttribute("errorMessage", "No ingredients available in inventory.");
        }

        request.setAttribute("dishList", dishList);
        request.setAttribute("inventoryList", inventoryList);
        request.getRequestDispatcher("/ManageMenu/ViewAllDish.jsp").forward(request, response);
    }
}