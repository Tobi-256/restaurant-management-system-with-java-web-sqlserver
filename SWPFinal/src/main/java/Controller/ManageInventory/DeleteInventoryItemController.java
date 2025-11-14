package Controller.ManageInventory;

import DAO.InventoryDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

/**
 *
 * @author DELL-Laptop
 */
@WebServlet(name = "DeleteInventoryItemController", urlPatterns = {"/DeleteInventoryItemController"})
public class DeleteInventoryItemController extends HttpServlet {

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
            out.println("<title>Servlet DeleteInventoryItemController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet DeleteInventoryItemController at " + request.getContextPath() + "</h1>");
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
        String itemId_raw = request.getParameter("itemID");

        if (itemId_raw == null || itemId_raw.isEmpty()) {
            System.out.println("itemID is missing from the request.");
            return;
        }
        System.out.println("Giá trị Id nhận được từ request parameter: " + itemId_raw);

        try {

            InventoryDAO delItem = new InventoryDAO();
            delItem.deleteInventoryItemById(itemId_raw);
            response.sendRedirect("ViewInventoryController");
        } catch (NumberFormatException e) {
            System.out.println("Invalid empID: " + itemId_raw);
            response.sendRedirect("error.jsp");
        } catch (Exception e) {
            e.printStackTrace(); // In ra lỗi
            response.sendRedirect("error.jsp");
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
