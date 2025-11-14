package Controller.ManageOrder;

import DAO.MenuDAO;
import DAO.OrderDAO;
import DAO.TableDAO;
import Model.Order;
import Model.OrderDetail;
import Model.Dish;
import Model.Table;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/UpdateOrder")
public class UpdateOrderController extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        OrderDAO orderDAO = new OrderDAO();
        TableDAO tableDAO;
        try {
            tableDAO = new TableDAO();
            Order order = new Order();
            order.setOrderId(request.getParameter("orderId"));
            order.setUserId(request.getParameter("userId"));
            order.setCustomerId(request.getParameter("customerId"));
            order.setOrderDate(new java.sql.Timestamp(new SimpleDateFormat("yyyy-MM-dd'T'HH:mm").parse(request.getParameter("orderDate")).getTime()));
            order.setOrderStatus(request.getParameter("orderStatus"));
            order.setOrderType(request.getParameter("orderType"));
            order.setOrderDescription(request.getParameter("orderDescription"));
            order.setCouponId(request.getParameter("couponId"));
            order.setTableId(request.getParameter("tableId"));

            List<OrderDetail> details = new ArrayList<>();
            MenuDAO menuDAO = new MenuDAO();
            List<Dish> dishList = menuDAO.getAllDishes();
            for (Dish dish : dishList) {
                String quantityStr = request.getParameter("quantity_" + dish.getDishId());
                int quantity = quantityStr != null && !quantityStr.isEmpty() ? Integer.parseInt(quantityStr) : 0;
                if (quantity > 0) {
                    OrderDetail detail = new OrderDetail();
                    detail.setOrderId(order.getOrderId());
                    detail.setDishId(dish.getDishId());
                    detail.setDishName(dish.getDishName());
                    detail.setQuantity(quantity);
                    detail.setSubtotal(quantity * dish.getDishPrice());
                    details.add(detail);
                }
            }
            order.setOrderDetails(details);

            orderDAO.updateOrder(order);

            // Cập nhật trạng thái bàn nếu đơn hàng bị hủy
            if ("Cancelled".equals(order.getOrderStatus()) && order.getTableId() != null) {
                Table table = tableDAO.getTableById(order.getTableId());
                if (table != null) {
                    table.setTableStatus("Empty");
                    tableDAO.updateTable(order.getTableId(), table);
                }
            }

            response.getWriter().write("success");
        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().write("error: " + e.getMessage());
        }
    }
}