package Controller.ManagePayment;

import DAO.OrderDAO;
import DAO.CustomerDAO;
import DAO.CouponDAO;
import DAO.TableDAO;
import Model.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.Map;
import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/printBill")
public class PrintBillServlet extends HttpServlet {
    private OrderDAO orderDAO;
    private CustomerDAO customerDAO;
    private CouponDAO couponDAO;
    private TableDAO tableDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
        customerDAO = new CustomerDAO();
        couponDAO = new CouponDAO();
        tableDAO = new TableDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            String orderId = request.getParameter("orderId");
            if (orderId == null || orderId.isEmpty()) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order ID is required");
                return;
            }
            
            Order order = orderDAO.getOrderById(orderId);
            if (order == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                return;
            }

            // Kiểm tra nếu có pendingCashOrder trong session
            Map<String, String> pendingCashOrder = (Map<String, String>) request.getSession().getAttribute("pendingCashOrder");
            if (pendingCashOrder != null && pendingCashOrder.get("orderId").equals(orderId)) {
                request.setAttribute("pendingCashOrder", pendingCashOrder);
            }
            
            request.setAttribute("order", order);
            request.setAttribute("formattedDate", new SimpleDateFormat("dd/MM/yyyy HH:mm").format(order.getOrderDate()));
            request.getRequestDispatcher("/ManagePayment/printBill.jsp").forward(request, response);
        } catch (SQLException | ClassNotFoundException ex) {
            Logger.getLogger(PrintBillServlet.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("printInvoice".equals(action)) {
            try {
                String orderId = request.getParameter("orderId");
                Map<String, String> orderData = (Map<String, String>) request.getSession().getAttribute("pendingCashOrder");

                if (orderData == null || !orderData.get("orderId").equals(orderId)) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "No pending cash order found");
                    return;
                }

                Order order = orderDAO.getOrderById(orderId);
                if (order == null || !"Processing".equals(order.getOrderStatus())) {
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order not valid for payment");
                    return;
                }

                // Cập nhật đơn hàng
                order.setTotal(Double.parseDouble(orderData.get("totalBeforeDiscount")));
                order.setFinalPrice(Double.parseDouble(orderData.get("finalPrice")));
                order.setOrderStatus("Completed");
                String couponId = orderData.get("couponId");
                if (couponId != null && !couponId.isEmpty()) {
                    order.setCouponId(couponId);
                    couponDAO.incrementTimesUsed(couponId);
                }
                orderDAO.updateOrder(order);

                // Cập nhật thông tin khách hàng và bàn
                customerDAO.incrementNumberOfPayment(order.getCustomerId());
                tableDAO.updateTableStatus(orderData.get("tableId"), "Available");

                // Xóa thông tin tạm trong session
                request.getSession().removeAttribute("pendingCashOrder");

                // Chuẩn bị dữ liệu cho JSP và tự động in
                request.setAttribute("order", order);
                request.setAttribute("formattedDate", new SimpleDateFormat("dd/MM/yyyy HH:mm").format(order.getOrderDate()));
                request.setAttribute("autoPrint", true); // Dấu hiệu để JSP tự động in
                request.getRequestDispatcher("/ManagePayment/printBill.jsp").forward(request, response);
            } catch (SQLException | ClassNotFoundException ex) {
                Logger.getLogger(PrintBillServlet.class.getName()).log(Level.SEVERE, null, ex);
                response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error processing payment");
            }
        }
    }
}