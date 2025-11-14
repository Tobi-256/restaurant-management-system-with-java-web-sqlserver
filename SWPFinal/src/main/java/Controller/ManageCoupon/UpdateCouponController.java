/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Controller.ManageCoupon;

import DAO.CouponDAO;
import Model.Coupon;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.math.BigDecimal;
import java.sql.Date;
import java.text.ParseException;
import java.text.SimpleDateFormat;

/**
 *
 * @author DELL-Laptop
 */
@WebServlet(name = "UpdateCouponController", urlPatterns = {"/UpdateCouponController"})
public class UpdateCouponController extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet UpdateCouponController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet UpdateCouponController at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        processRequest(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String couponId_raw = request.getParameter("couponId");
        String discountAmount_raw = request.getParameter("discountAmount");
        String expirationDate_raw = request.getParameter("expirationDate");
        String timeUsed_raw = request.getParameter("timesUsed");
        String description_raw = request.getParameter("description");

        // 1. Kiểm tra dữ liệu đầu vào (Validation)
        if (couponId_raw == null || couponId_raw.isEmpty()
                || discountAmount_raw == null || discountAmount_raw.isEmpty()
                || expirationDate_raw == null || expirationDate_raw.isEmpty()
                || timeUsed_raw == null || timeUsed_raw.isEmpty()
                || description_raw == null || description_raw.isEmpty()) {

            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin Coupon."); // Thông báo lỗi rõ ràng hơn
            return; // Dừng xử lý tiếp nếu dữ liệu đầu vào không hợp lệ
        }

        try {
            // 2. Chuyển đổi kiểu dữ liệu và Parse

            BigDecimal discountAmount;
            try {
                discountAmount = new BigDecimal(discountAmount_raw);
                if (discountAmount.compareTo(BigDecimal.ZERO) < 0) { // Kiểm tra discountAmount không âm
                    request.setAttribute("error", "Giá trị giảm giá phải là số dương.");
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Giá trị giảm giá không hợp lệ.");
                return;
            }

            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd"); // Định dạng ngày tháng mong muốn
            java.util.Date utilDate;
            try {
                utilDate = sdf.parse(expirationDate_raw);
            } catch (ParseException e) {
                request.setAttribute("error", "Định dạng ngày hết hạn không hợp lệ (yyyy-MM-dd).");
                return;
            }
            Date sqlDate = new Date(utilDate.getTime()); // Chuyển đổi sang java.sql.Date

            int timeUsed;
            try {
                timeUsed = Integer.parseInt(timeUsed_raw);
                if (timeUsed < 0) { // Kiểm tra timeUsed không âm
                    request.setAttribute("error", "Số lần sử dụng phải là số không âm.");
                   
                    return;
                }
            } catch (NumberFormatException e) {
                request.setAttribute("error", "Số lần sử dụng không hợp lệ.");
               
                return;
            }

            // 3. Tạo đối tượng Coupon
            Coupon updateCoupon = new Coupon(couponId_raw, discountAmount, sqlDate, timeUsed, description_raw);

            // 4. Gọi CouponDAO để cập nhật
            CouponDAO upCoupon = new CouponDAO();
            upCoupon.updateCoupon(updateCoupon);

            // 5. Chuyển hướng sau khi cập nhật thành công
            response.sendRedirect("ViewCouponController"); // Chuyển hướng đến trang xem danh sách Coupon

        } catch (IOException e) { // Bắt lại ServletException và IOException để re-throw
            throw e; // Re-throw để container xử lý
        } catch (Exception e) { // Bắt các Exception khác (ví dụ từ CouponDAO)
            System.err.println("Lỗi trong quá trình xử lý cập nhật Coupon: " + e.getMessage()); // In lỗi chi tiết hơn ra console server
            e.printStackTrace(); // In stack trace để debug
            request.setAttribute("error", "Có lỗi xảy ra khi cập nhật Coupon. Vui lòng kiểm tra lại dữ liệu hoặc thử lại sau."); // Thông báo lỗi chung cho người dùng
          
        }

    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}