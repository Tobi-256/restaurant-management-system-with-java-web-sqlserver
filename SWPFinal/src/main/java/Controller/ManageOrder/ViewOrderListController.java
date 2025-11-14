package Controller.ManageOrder;

import DAO.OrderDAO;
import Model.Order;
import Model.OrderDetail;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/ViewOrderList")
public class ViewOrderListController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
   OrderDAO orderDAO = new OrderDAO();
    List<Order> orderList = new ArrayList<>();
    try {
        orderList = orderDAO.getAllOrders();
        if (orderList == null) {
            orderList = new ArrayList<>();
        }
        for (Order order : orderList) {
            List<OrderDetail> orderDetails = orderDAO.getOrderDetailsByOrderId(order.getOrderId());
            order.setOrderDetails(orderDetails != null ? orderDetails : new ArrayList<>());
        }
    } catch (Exception e) {
        e.printStackTrace();
        request.setAttribute("errorMessage", "Error fetching orders: " + e.getMessage());
    }
    request.setAttribute("orderList", orderList);
    request.getRequestDispatcher("/ManageOrder/ViewOrderList.jsp").forward(request, response);
}
}