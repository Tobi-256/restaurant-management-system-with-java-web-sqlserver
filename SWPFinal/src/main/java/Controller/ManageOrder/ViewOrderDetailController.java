package Controller.ManageOrder;

import DAO.OrderDAO;
import Model.Order;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/ViewOrderDetail")
public class ViewOrderDetailController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        String orderId = request.getParameter("orderId");
        OrderDAO orderDAO = new OrderDAO();
        Order order = null;
        try {
            order = orderDAO.getOrderById(orderId);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(ViewOrderDetailController.class.getName()).log(Level.SEVERE, null, ex);
        } catch (SQLException ex) {
            Logger.getLogger(ViewOrderDetailController.class.getName()).log(Level.SEVERE, null, ex);
        }

        if (order == null) {
            response.getWriter().write("{\"error\": \"Order not found\"}");
            return;
        }

        Gson gson = new Gson();
        String jsonResponse = gson.toJson(order);
        response.getWriter().write(jsonResponse);
    }
}