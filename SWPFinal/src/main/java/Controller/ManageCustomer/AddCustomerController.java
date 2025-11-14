package Controller.ManageCustomer;

import DAO.CustomerDAO;
import Model.Customer;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/AddCustomer")
public class AddCustomerController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        request.setCharacterEncoding("UTF-8");

        String customerName = request.getParameter("CustomerName");
        String customerPhone = request.getParameter("CustomerPhone");
        int numberOfPayment = 0;

        if (customerPhone == null || customerPhone.trim().isEmpty()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Phone number is required.");
            return;
        }
        if (!customerPhone.startsWith("0")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Phone number must start with 0.");
            return;
        }
        if (!customerPhone.matches("\\d{10}")) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Phone number must be exactly 10 digits, no special characters.");
            return;
        }

        CustomerDAO customerDAO = new CustomerDAO();
        try {
            if (customerDAO.isPhoneExists(customerPhone, null)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Customer phone already exists. Please check again.");
                return;
            }

            String customerId = customerDAO.generateNextCustomerId();
            Customer customer = new Customer(customerId, customerName, customerPhone, numberOfPayment, false);
            customerDAO.createCustomer(customer);
            response.getWriter().write("Customer added successfully!");
        } catch (SQLException | ClassNotFoundException ex) {
            Logger.getLogger(AddCustomerController.class.getName()).log(Level.SEVERE, null, ex);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Database error: " + ex.getMessage());
        }
    }
}