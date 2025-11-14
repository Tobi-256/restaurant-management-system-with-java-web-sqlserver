package Controller.ManageMenu;

import DAO.MenuDAO;
import Model.Dish;
import Model.DishInventory;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

@WebServlet("/dishdetail")
public class DishDetailController extends HttpServlet {
    private final MenuDAO menuDAO = new MenuDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String dishId = request.getParameter("dishId");
        Dish dish = menuDAO.getDishById(dishId);
        List<DishInventory> dishIngredients = menuDAO.getDishIngredients(dishId);

        if (dish != null) {
            request.setAttribute("dish", dish);
            request.setAttribute("dishIngredients", dishIngredients);
            request.getRequestDispatcher("ManageMenu/DishDetail.jsp").forward(request, response);
        } else {
            request.getSession().setAttribute("errorMessage", "Dish not found with ID: " + dishId);
            response.sendRedirect(request.getContextPath() + "/viewalldish");
        }
    }
}