package Controller.ManagePayment;

import DAO.OrderDAO;
import DAO.CustomerDAO;
import DAO.TableDAO;
import DAO.CouponDAO;
import Model.Order;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.net.URLEncoder;
import java.sql.SQLException;
import java.util.Map;
import java.util.TreeMap;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/payment/vnpay-return")
public class VNPayReturnServlet extends HttpServlet {

    private static final String vnp_HashSecret = "VL2ZFM15UPSSC2KGEU3X80VG7O23A3XV"; // Thay bằng HashSecret của bạn
    private OrderDAO orderDAO;
    private CustomerDAO customerDAO;
    private TableDAO tableDAO;

    @Override
    public void init() throws ServletException {
        orderDAO = new OrderDAO();
        customerDAO = new CustomerDAO();
        tableDAO = new TableDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();

        // Lấy tất cả tham số trả về từ VNPay
        Map<String, String> fields = new TreeMap<>();
        for (String key : request.getParameterMap().keySet()) {
            String value = request.getParameter(key);
            if (value != null && !value.isEmpty()) {
                fields.put(key, value);
            }
        }

        // Lấy checksum từ VNPay
        String vnp_SecureHash = fields.remove("vnp_SecureHash");

        // Tạo chuỗi hash data để kiểm tra
        StringBuilder hashData = new StringBuilder();
        for (Map.Entry<String, String> entry : fields.entrySet()) {
            hashData.append(entry.getKey()).append("=")
                    .append(URLEncoder.encode(entry.getValue(), "UTF-8")).append("&");
        }
        hashData.setLength(hashData.length() - 1);

        // Tạo checksum từ dữ liệu trả về
        String calculatedHash = hmacSHA512(vnp_HashSecret, hashData.toString());

        // Kiểm tra giao dịch
        String transactionStatus = fields.get("vnp_TransactionStatus");
        boolean isSuccess = "00".equals(transactionStatus) && calculatedHash.equalsIgnoreCase(vnp_SecureHash);

        if (isSuccess) {
            try {
                // Lấy thông tin từ session
                Map<String, String> orderData = (Map<String, String>) session.getAttribute("pendingVNPayOrder");
                if (orderData == null) {
                    response.sendRedirect("/ManagePayment/paymentFailed.jsp?message=SessionExpired");
                    return;
                }
                
                String orderId = orderData.get("orderId");
                String tableId = orderData.get("tableId");
                String totalBeforeDiscount = orderData.get("totalBeforeDiscount");
                String finalPrice = orderData.get("finalPrice");
                String couponId = orderData.get("couponId");
                
                Order order = orderDAO.getOrderById(orderId);
                if (order == null || !"Processing".equals(order.getOrderStatus())) {
                    response.sendRedirect("/ManagePayment/paymentFailed.jsp?message=OrderInvalid&orderId=" + orderId);
                    return;
                }
                
                // Cập nhật đơn hàng
                order.setTotal(Double.parseDouble(totalBeforeDiscount));
                order.setFinalPrice(Double.parseDouble(finalPrice));
                order.setOrderStatus("Completed");
                if (!couponId.isEmpty()) {
                    order.setCouponId(couponId);
                }
                orderDAO.updateOrder(order);
                customerDAO.incrementNumberOfPayment(order.getCustomerId());
                tableDAO.updateTableStatus(tableId, "Available");
                
                // Xóa dữ liệu tạm trong session
                session.removeAttribute("pendingVNPayOrder");
                
                // Chuyển hướng đến trang thành công
                request.setAttribute("order", order);
                request.getRequestDispatcher("/ManagePayment/paymentSuccess.jsp").forward(request, response);
            } catch (SQLException ex) {
                Logger.getLogger(VNPayReturnServlet.class.getName()).log(Level.SEVERE, null, ex);
            } catch (ClassNotFoundException ex) {
                Logger.getLogger(VNPayReturnServlet.class.getName()).log(Level.SEVERE, null, ex);
            }
        } else {
            // Thanh toán thất bại
            String orderId = fields.get("vnp_TxnRef").split("_")[0]; // Lấy orderId từ vnp_TxnRef
            String message = "Giao dịch thất bại. Mã lỗi: " + transactionStatus;
            response.sendRedirect("/ManagePayment/paymentFailed.jsp?orderId=" + orderId + "&message=" + URLEncoder.encode(message, "UTF-8"));
        }
    }

    private String hmacSHA512(String key, String data) {
        try {
            javax.crypto.Mac mac = javax.crypto.Mac.getInstance("HmacSHA512");
            mac.init(new javax.crypto.spec.SecretKeySpec(key.getBytes("UTF-8"), "HmacSHA512"));
            byte[] hmac = mac.doFinal(data.getBytes("UTF-8"));
            StringBuilder sb = new StringBuilder();
            for (byte b : hmac) {
                sb.append(String.format("%02x", b));
            }
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Failed to calculate hmac-sha512", e);
        }
    }
}