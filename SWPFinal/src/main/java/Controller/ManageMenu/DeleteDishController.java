package Controller.ManageMenu;

import DAO.MenuDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/deletedish")
public class DeleteDishController extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String dishId = request.getParameter("dishId");
        MenuDAO menuDAO = new MenuDAO();
        HttpSession session = request.getSession();

        boolean deleted = menuDAO.deleteDish(dishId);

        if (deleted) {
            // Xóa thành công
            session.setAttribute("message", "Dish deleted successfully.");
        } else {
            // Không xóa được (do có trong Order Detail)
            session.setAttribute("errorMessage", "Cannot delete dish. It exists in order details.");
        }

        response.sendRedirect("viewalldish");  // Chuyển hướng về trang danh sách món ăn
    }
}
//ok