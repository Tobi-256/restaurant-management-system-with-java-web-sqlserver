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
import java.util.List;

@WebServlet("/ViewCustomerList")
public class ViewCustomerListController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        CustomerDAO customerDAO = new CustomerDAO();
        try {
            List<Customer> customerList = customerDAO.getAllCustomers();
            request.setAttribute("customerList", customerList);
            request.getRequestDispatcher("ManageCustomer/ViewCustomerList.jsp").forward(request, response);
        } catch (SQLException | ClassNotFoundException ex) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Database error: " + ex.getMessage());
        }
    }
}