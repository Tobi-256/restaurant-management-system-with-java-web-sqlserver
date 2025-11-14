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
@WebServlet("/AddCouponController")
public class AddCouponController extends HttpServlet {

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
            out.println("<title>Servlet AddCouponController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AddCouponController at " + request.getContextPath() + "</h1>");
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

        String discountAmount_str = request.getParameter("discountAmount");
        String expirationDate_raw = request.getParameter("expirationDate");
        String description = request.getParameter("description"); // Lấy description từ request

        BigDecimal discountAmount = null;
        Date sqlDate = null;

        try {
            // 2. Parse discountAmount
            discountAmount = new BigDecimal(discountAmount_str);

            // 3. Parse expirationDate
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            java.util.Date utilDate;
            try {
                utilDate = sdf.parse(expirationDate_raw);
                sqlDate = new Date(utilDate.getTime()); // Chuyển sang java.sql.Date
            } catch (ParseException e) {
                request.getRequestDispatcher("ViewCouponController").forward(request, response);
                return;
            }

            // 5. Gọi CouponDAO để thêm mới
            CouponDAO couponDAO = new CouponDAO();
            String couponId = couponDAO.generateNextCouponId();
            System.out.println("couponId");
            Coupon newCoupon = new Coupon(couponId, discountAmount, sqlDate, 0, 0, description); // Giả sử constructor Coupon phù hợp
            couponDAO.addNewCoupon(newCoupon);

            // 6. Chuyển hướng sau khi thêm thành công
            response.sendRedirect("ViewCouponController"); // Chuyển đến trang xem danh sách coupon

        } catch (ServletException | IOException e) {
            throw e; // Re-throw ServletException và IOException
        } catch (Exception e) { // Bắt các Exception khác (ví dụ từ CouponDAO)

            request.setAttribute("error", "Có lỗi xảy ra khi thêm mới Coupon. Vui lòng thử lại sau.");
            request.getRequestDispatcher("ViewCouponController").forward(request, response); // Chuyển đến trang lỗi
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
