package Controller.ManageOrder;

import DAO.TableDAO;
import DAO.OrderDAO;
import DAO.CustomerDAO;
import DAO.CouponDAO;
import Model.Order;
import Model.Coupon;
import Model.Table;
import java.io.IOException;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.sql.SQLException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;

@WebServlet("/payment")
public class PaymentController extends HttpServlet {

    private OrderDAO orderDAO;
    private TableDAO tableDAO;
    private CustomerDAO customerDAO;
    private CouponDAO couponDAO;

    // VNPay configuration
    private static final String vnp_TmnCode = "F7363RA1";
    private static final String vnp_HashSecret = "VL2ZFM15UPSSC2KGEU3X80VG7O23A3XV";
    private static final String vnp_Url = "https://sandbox.vnpayment.vn/paymentv2/vpcpay.html";
    private static final String vnp_ReturnUrl = "http://localhost:8080/payment/vnpay-return";

    @Override
    public void init() throws ServletException {
        try {
            orderDAO = new OrderDAO();
            tableDAO = new TableDAO();
            customerDAO = new CustomerDAO();
            couponDAO = new CouponDAO();
        } catch (Exception e) {
            throw new ServletException("Failed to initialize DAOs", e);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "listOrders";
        }

        try {
            switch (action) {
                case "listOrders":
                    listOrders(request, response);
                    break;
                case "viewOrder":
                    viewOrder(request, response);
                    break;
                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (Exception e) {
            throw new ServletException("Error in doGet: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        System.out.println("Action received: " + action);
        System.out.println("OrderId: " + request.getParameter("orderId"));
        System.out.println("TableId: " + request.getParameter("tableId"));
        System.out.println("CouponId: " + request.getParameter("couponId"));
        try {
            if ("payOrder".equals(action)) {
                payOrder(request, response);
            } else if ("payCash".equals(action)) {
                payCash(request, response);
            } else if ("payOnline".equals(action)) {
                payOnline(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (Exception e) {
            throw new ServletException("Error in doPost: " + e.getMessage(), e);
        }
    }

    private void listOrders(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        List<Table> tables = tableDAO.getAllTables();
        for (Table table : tables) {
            Order order = orderDAO.getOrderByTableId(table.getTableId());
            table.setOrder(order);
        }
        request.setAttribute("tables", tables);
        request.getRequestDispatcher("/ManageOrder/orderPaymentList.jsp").forward(request, response);
    }

    private void viewOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String orderId = request.getParameter("orderId");
        if (orderId == null || orderId.isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order ID is missing");
            return;
        }

        Order order = orderDAO.getOrderById(orderId);
        if (order == null) {
            response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
            return;
        }

        if ("Processing".equals(order.getOrderStatus())) {
            List<Coupon> coupons = couponDAO.getAvailableCoupons();
            request.setAttribute("coupons", coupons);
        }

        request.setAttribute("order", order);
        request.getRequestDispatcher("/ManageOrder/paymentDetail.jsp").forward(request, response);
    }

    private void payOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String orderId = request.getParameter("orderId");
        String tableId = request.getParameter("tableId");
        String couponId = request.getParameter("couponId");

        if (orderId == null || tableId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing required parameters");
            return;
        }

        Order order = orderDAO.getOrderById(orderId);
        if (order == null || !"Processing".equals(order.getOrderStatus())) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order not valid for payment");
            return;
        }

        double totalBeforeDiscount = order.getTotal();
        double finalPrice = totalBeforeDiscount;

        if (couponId != null && !couponId.trim().isEmpty()) {
            Coupon coupon = couponDAO.getCouponById(couponId);
            if (coupon != null && coupon.getIsDeleted() == 0) {
                String query = "SELECT CASE WHEN ? > GETDATE() THEN 1 ELSE 0 END AS isValid";
                try (Connection conn = couponDAO.getConnection(); PreparedStatement ps = conn.prepareStatement(query)) {
                    ps.setDate(1, new java.sql.Date(coupon.getExpirationDate().getTime()));
                    ResultSet rs = ps.executeQuery();
                    if (rs.next() && rs.getInt("isValid") == 1) {
                        BigDecimal discount = coupon.getDiscountAmount();
                        BigDecimal currentTotal = BigDecimal.valueOf(totalBeforeDiscount);
                        BigDecimal newTotal = currentTotal.subtract(discount).max(BigDecimal.ZERO);
                        finalPrice = newTotal.doubleValue();
                        order.setCouponId(couponId);
                        couponDAO.incrementTimesUsed(couponId);
                        System.out.println("Applied coupon " + couponId + " with discount " + discount + ", FinalPrice: " + finalPrice);
                    } else {
                        System.out.println("Coupon " + couponId + " is expired");
                    }
                }
            }
        }

        order.setTotal(totalBeforeDiscount);
        order.setFinalPrice(finalPrice);
        order.setOrderStatus("Completed");
        orderDAO.updateOrder(order);
        customerDAO.incrementNumberOfPayment(order.getCustomerId());
        tableDAO.updateTableStatus(tableId, "Available");

        List<Coupon> coupons = couponDAO.getAvailableCoupons();
        request.setAttribute("order", order);
        request.setAttribute("coupons", coupons);
        request.setAttribute("message", "Order has been paid. New total: " + order.getFinalPrice() + " VND");
        request.getRequestDispatcher("/ManageOrder/paymentDetail.jsp").forward(request, response);
    }

    private void payCash(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String orderId = request.getParameter("orderId");
        String tableId = request.getParameter("tableId");
        String couponId = request.getParameter("couponId");

        System.out.println("payCash - OrderId: " + orderId + ", TableId: " + tableId + ", CouponId: " + couponId);

        if (orderId == null || tableId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing required parameters");
            return;
        }

        Order order = orderDAO.getOrderById(orderId);
        if (order == null || !"Processing".equals(order.getOrderStatus())) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order not valid for payment");
            return;
        }

        double totalBeforeDiscount = order.getTotal();
        double finalPrice = totalBeforeDiscount;

        if (couponId != null && !couponId.trim().isEmpty()) {
            Coupon coupon = couponDAO.getCouponById(couponId);
            if (coupon != null && coupon.getIsDeleted() == 0) {
                boolean isValid = coupon.getExpirationDate() == null || coupon.getExpirationDate().after(new java.util.Date());
                if (isValid) {
                    BigDecimal discount = coupon.getDiscountAmount();
                    BigDecimal currentTotal = BigDecimal.valueOf(totalBeforeDiscount);
                    BigDecimal newTotal = currentTotal.subtract(discount).max(BigDecimal.ZERO);
                    finalPrice = newTotal.doubleValue();
                    System.out.println("Applied coupon " + couponId + " with discount " + discount + ", FinalPrice: " + finalPrice);
                } else {
                    System.out.println("Coupon " + couponId + " is expired or invalid");
                }
            } else {
                System.out.println("Coupon " + couponId + " not found or deleted");
            }
        }

        // Lưu thông tin tạm vào session thay vì xử lý ngay
        HttpSession session = request.getSession();
        Map<String, String> orderData = new TreeMap<>();
        orderData.put("orderId", orderId);
        orderData.put("tableId", tableId);
        orderData.put("totalBeforeDiscount", String.valueOf(totalBeforeDiscount));
        orderData.put("finalPrice", String.valueOf(finalPrice));
        orderData.put("couponId", couponId != null ? couponId : "");
        session.setAttribute("pendingCashOrder", orderData);

        // Chuyển hướng đến printBill mà không cập nhật trạng thái
        response.sendRedirect("/printBill?orderId=" + orderId);
    }

    private void payOnline(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String orderId = request.getParameter("orderId");
        String tableId = request.getParameter("tableId");
        String couponId = request.getParameter("couponId");

        if (orderId == null || tableId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing required parameters");
            return;
        }

        Order order = orderDAO.getOrderById(orderId);
        if (order == null || !"Processing".equals(order.getOrderStatus())) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Order not valid for payment");
            return;
        }

        double totalBeforeDiscount = order.getTotal();
        double finalPrice = totalBeforeDiscount;

        if (couponId != null && !couponId.trim().isEmpty()) {
            Coupon coupon = couponDAO.getCouponById(couponId);
            if (coupon != null && coupon.getIsDeleted() == 0) {
                boolean isValid = coupon.getExpirationDate() == null || coupon.getExpirationDate().after(new java.util.Date());
                if (isValid) {
                    BigDecimal discount = coupon.getDiscountAmount();
                    BigDecimal currentTotal = BigDecimal.valueOf(totalBeforeDiscount);
                    BigDecimal newTotal = currentTotal.subtract(discount).max(BigDecimal.ZERO);
                    finalPrice = newTotal.doubleValue();
                    order.setCouponId(couponId);
                    couponDAO.incrementTimesUsed(couponId);
                    System.out.println("Applied coupon " + couponId + " with discount " + discount + ", FinalPrice: " + finalPrice);
                }
            }
        }

        // Store temporary info in session for VNPay callback processing
        HttpSession session = request.getSession();
        Map<String, String> orderData = new TreeMap<>();
        orderData.put("orderId", orderId);
        orderData.put("tableId", tableId);
        orderData.put("totalBeforeDiscount", String.valueOf(totalBeforeDiscount));
        orderData.put("finalPrice", String.valueOf(finalPrice));
        orderData.put("couponId", couponId != null ? couponId : "");
        session.setAttribute("pendingVNPayOrder", orderData);

        // Prepare VNPay parameters
        String vnp_Version = "2.1.0";
        String vnp_Command = "pay";
        String vnp_OrderInfo = "Payment for order " + orderId + " with total " + finalPrice + " VND";
        String orderType = "250000";
        String vnp_TxnRef = orderId + "_" + System.currentTimeMillis();
        String vnp_IpAddr = request.getRemoteAddr();
        String vnp_CreateDate = new SimpleDateFormat("yyyyMMddHHmmss").format(new Date());
        String amount = String.valueOf((int) (finalPrice * 100));

        Map<String, String> vnp_Params = new TreeMap<>();
        vnp_Params.put("vnp_Version", vnp_Version);
        vnp_Params.put("vnp_Command", vnp_Command);
        vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
        vnp_Params.put("vnp_Amount", amount);
        vnp_Params.put("vnp_CurrCode", "VND");
        vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
        vnp_Params.put("vnp_OrderInfo", vnp_OrderInfo);
        vnp_Params.put("vnp_OrderType", orderType);
        vnp_Params.put("vnp_Locale", "vn");
        vnp_Params.put("vnp_ReturnUrl", vnp_ReturnUrl);
        vnp_Params.put("vnp_IpAddr", vnp_IpAddr);
        vnp_Params.put("vnp_CreateDate", vnp_CreateDate);

        StringBuilder hashData = new StringBuilder();
        for (Map.Entry<String, String> entry : vnp_Params.entrySet()) {
            hashData.append(entry.getKey()).append("=")
                    .append(URLEncoder.encode(entry.getValue(), "UTF-8")).append("&");
        }
        hashData.setLength(hashData.length() - 1);

        String vnp_SecureHash = hmacSHA512(vnp_HashSecret, hashData.toString());
        vnp_Params.put("vnp_SecureHash", vnp_SecureHash);

        StringBuilder paymentUrl = new StringBuilder(vnp_Url).append("?");
        for (Map.Entry<String, String> entry : vnp_Params.entrySet()) {
            paymentUrl.append(URLEncoder.encode(entry.getKey(), "UTF-8"))
                      .append("=")
                      .append(URLEncoder.encode(entry.getValue(), "UTF-8"))
                      .append("&");
        }
        paymentUrl.setLength(paymentUrl.length() - 1);

        response.sendRedirect(paymentUrl.toString());
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