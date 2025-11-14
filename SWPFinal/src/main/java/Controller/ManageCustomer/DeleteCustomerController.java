package Controller.ManageCustomer;

import DAO.CustomerDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/DeleteCustomer")
public class DeleteCustomerController extends HttpServlet {

    private CustomerDAO customerDAO;

    @Override
    public void init() {
        customerDAO = new CustomerDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String customerId = request.getParameter("customerId");

        if (customerId == null || customerId.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing customerId");
            return;
        }

        try {
            boolean deleted = customerDAO.deleteCustomer(customerId);
            if (deleted) {
                response.setStatus(HttpServletResponse.SC_OK);
                response.getWriter().write("Customer marked as deleted successfully");
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("Customer not found or already deleted.");
            }
        } catch (SQLException | ClassNotFoundException ex) {
            Logger.getLogger(DeleteCustomerController.class.getName()).log(Level.SEVERE, null, ex);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error marking customer as deleted: " + ex.getMessage());
        }
    }
}