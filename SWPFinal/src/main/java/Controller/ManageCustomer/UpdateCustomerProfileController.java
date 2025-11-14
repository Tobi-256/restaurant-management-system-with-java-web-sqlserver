package Controller.ManageCustomer;

import DAO.CustomerDAO;
import Model.Customer;
import java.io.IOException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/UpdateCustomer")
public class UpdateCustomerProfileController extends HttpServlet {

    private CustomerDAO customerDAO;

    @Override
    public void init() {
        customerDAO = new CustomerDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String customerId = request.getParameter("customerId");
        Customer customer = null;
        try {
            customer = customerDAO.getCustomerById(customerId);
        } catch (SQLException | ClassNotFoundException ex) {
            Logger.getLogger(UpdateCustomerProfileController.class.getName()).log(Level.SEVERE, null, ex);
        }
        request.setAttribute("customer", customer);
        request.getRequestDispatcher("ManageCustomer/UpdateCustomerProfile.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        String customerId = request.getParameter("customerId");
        String customerName = request.getParameter("CustomerName");
        String customerPhone = request.getParameter("CustomerPhone");

        try {
            Customer existingCustomer = customerDAO.getCustomerById(customerId);
            if (existingCustomer == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND, "Customer not found");
                return;
            }

            if (customerDAO.isPhoneExists(customerPhone, customerId)) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Customer phone already exists. Please check again.");
                return;
            }

            // Sửa constructor: truyền đầy đủ tham số, giữ nguyên IsDeleted của existingCustomer
            Customer customer = new Customer(
                customerId, 
                customerName, 
                customerPhone, 
                existingCustomer.getNumberOfPayment(), 
                existingCustomer.isIsDeleted() // Lấy giá trị IsDeleted từ existingCustomer
            );
            customerDAO.updateCustomer(customer);
            request.getSession().setAttribute("message", "Customer updated successfully!");
        } catch (SQLException | ClassNotFoundException ex) {
            Logger.getLogger(UpdateCustomerProfileController.class.getName()).log(Level.SEVERE, null, ex);
            request.getSession().setAttribute("errorMessage", "Database error during update: " + ex.getMessage());
        }
        response.sendRedirect(request.getContextPath() + "/ViewCustomerList");
    }
}