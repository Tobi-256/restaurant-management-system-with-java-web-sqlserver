package Controller.ManageOrder;

import DAO.OrderDAO;
import DAO.TableDAO;
import Model.Account;
import Model.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "KitchenOrderStatusController", urlPatterns = {"/kitchen"})
public class KitchenOrderStatusController extends HttpServlet {

    private OrderDAO orderDAO;
    private TableDAO tableDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAO();
        tableDAO = new TableDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || !"Kitchen staff".equals(account.getUserRole())) {
            response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
            return;
        }

        String action = request.getParameter("action");
        try {
            if (action == null || "list".equals(action)) {
                List<Order> pendingOrders = orderDAO.getPendingOrders();
                request.setAttribute("pendingOrders", pendingOrders);
                request.getRequestDispatcher("/ManageOrder/kitchendb.jsp").forward(request, response);
            } else if ("viewOrder".equals(action)) {
                String orderId = request.getParameter("orderId");
                Order order = orderDAO.getOrderById(orderId);
                if (order != null) {
                    request.setAttribute("order", order);
                    request.getRequestDispatcher("/ManageOrder/kitchenod.jsp").forward(request, response);
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                }
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (SQLException | ClassNotFoundException e) {
            throw new ServletException("Error processing GET request: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");

        if (account == null || !"Kitchen staff".equals(account.getUserRole())) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only Kitchen staff role can update order status");
            return;
        }

        String orderId = request.getParameter("orderId");
        String newStatus = request.getParameter("newStatus");

        try {
            Order order = orderDAO.getOrderById(orderId);
            if (order == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                return;
            }

            if ("Pending".equals(order.getOrderStatus()) && "Processing".equals(newStatus)) {
                orderDAO.updateOrderStatus(orderId, "Processing"); // Check and deduct ingredients here
                request.setAttribute("successMessage", "Order " + orderId + " has been changed to Processing.");
            } else if ("Processing".equals(order.getOrderStatus()) && "Completed".equals(newStatus)) {
                orderDAO.updateOrderStatus(orderId, "Completed");
                request.setAttribute("successMessage", "Order " + orderId + " has been completed.");
            } else {
                request.setAttribute("errorMessage", "Cannot change status from " + order.getOrderStatus() + " to " + newStatus);
            }

            order = orderDAO.getOrderById(orderId);
            request.setAttribute("order", order);
            request.getRequestDispatcher("/ManageOrder/kitchenod.jsp").forward(request, response);

        } catch (SQLException e) {
            request.setAttribute("errorMessage", "Error updating status: " + e.getMessage());
            try {
                request.setAttribute("order", orderDAO.getOrderById(orderId));
            } catch (SQLException | ClassNotFoundException ex) {
                Logger.getLogger(KitchenOrderStatusController.class.getName()).log(Level.SEVERE, null, ex);
            }
            request.getRequestDispatcher("/ManageOrder/kitchenod.jsp").forward(request, response);
        } catch (ClassNotFoundException e) {
            throw new ServletException("Error updating order status: " + e.getMessage(), e);
        }
    }

    @Override
    public String getServletInfo() {
        return "Handles kitchen staff order management";
    }
}