package Controller.ManageOrder;

import DAO.CustomerDAO;
import DAO.MenuDAO;
import DAO.OrderDAO;
import DAO.TableDAO;
import DB.DBContext;
import Model.Account;
import Model.Customer;
import Model.Dish;
import Model.Order;
import Model.OrderDetail;
import Model.Table;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.gson.Gson;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.List;

@WebServlet(name = "OrderController", urlPatterns = {"/order"})
public class OrderController extends HttpServlet {

    private OrderDAO orderDAO;
    private TableDAO tableDAO;
    private MenuDAO menuDAO;
    private CustomerDAO customerDAO;

    @Override
    public void init() {
        orderDAO = new OrderDAO();
        tableDAO = new TableDAO();
        menuDAO = new MenuDAO();
        customerDAO = new CustomerDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
            return;
        }

        String action = request.getParameter("action");
        try {
            if (action == null || "listTables".equals(action)) {
                listTables(request, response);
            } else if ("tableOverview".equals(action)) {
                showTableOverview(request, response);
            } else if ("selectDish".equals(action)) {
                selectDish(request, response);
            } else if ("viewOrder".equals(action) && "Kitchen staff".equals(account.getUserRole())) {
                String orderId = request.getParameter("orderId");
                Order order = orderDAO.getOrderById(orderId);
                if (order != null) {
                    request.setAttribute("order", order);
                    request.getRequestDispatcher("/ManageOrder/kitchenod.jsp").forward(request, response);
                } else {
                    response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                }
            } else if ("checkOrderByTable".equals(action)) {
                checkOrderByTable(request, response);
            } else {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (SQLException | ClassNotFoundException e) {
            throw new ServletException("Error processing GET request: " + e.getMessage(), e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        if (account == null) {
            response.sendRedirect(request.getContextPath() + "/LoginPage.jsp");
            return;
        }

        String action = request.getParameter("action");
        try {
            switch (action) {
                case "submitOrder":
                    submitOrder(request, response);
                    break;
                case "editDishQuantity":
                    editDishQuantity(request, response);
                    break;
                case "deleteDish":
                    deleteDish(request, response);
                    break;
                case "selectCustomer":
                    selectCustomer(request, response);
                    break;
                case "addCustomer":
                    addCustomer(request, response);
                    break;
                case "completeOrder":
                    completeOrder(request, response);
                    break;
                case "cancelOrder":
                    String orderId = request.getParameter("orderId");
                    String tableId = request.getParameter("tableId");
                    if (orderId == null || tableId == null) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing orderId or tableId");
                        break;
                    }
                    Order order = orderDAO.getOrderById(orderId);
                    if (order == null) {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                        break;
                    }
                    if ("Pending".equals(order.getOrderStatus())) {
                        orderDAO.cancelOrder(orderId);
                        tableDAO.updateTableStatus(tableId, "Available");
                        response.sendRedirect(request.getContextPath() + "/order?action=listTables");
                    } else {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Cannot cancel order: Current status is " + order.getOrderStatus());
                    }
                    break;
                case "payOrder":
                    payOrder(request, response);
                    break;
                case "updateOrderDescription":
                    String orderIdUpdate = request.getParameter("orderId");
                    String tableIdUpdate = request.getParameter("tableId");
                    String orderDescription = request.getParameter("orderDescription");

                    if (orderIdUpdate == null || tableIdUpdate == null || orderDescription == null) {
                        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing orderId, tableId or orderDescription");
                        return;
                    }

                    Order orderToUpdate = orderDAO.getOrderById(orderIdUpdate);
                    if (orderToUpdate == null) {
                        response.sendError(HttpServletResponse.SC_NOT_FOUND, "Order not found");
                        return;
                    }

                    orderToUpdate.setOrderDescription(orderDescription);
                    orderDAO.updateOrder(orderToUpdate);
                    response.setContentType("text/plain");
                    response.getWriter().write("Order description updated successfully");
                    break;

                default:
                    response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid action");
            }
        } catch (SQLException | ClassNotFoundException e) {
            throw new ServletException("Error processing POST request: " + e.getMessage(), e);
        }
    }

    private void listTables(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        List<Table> tables = tableDAO.getAllTables();
        for (Table table : tables) {
            boolean hasOrder = tableDAO.hasOrder(table.getTableId());
            table.setHasOrder(hasOrder);
        }
        request.setAttribute("tables", tables);
        request.getRequestDispatcher("ManageOrder/listTables.jsp").forward(request, response);
    }

    private void showTableOverview(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String tableId = request.getParameter("tableId");
        if (tableId == null || tableId.trim().isEmpty()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing tableId");
            return;
        }

        HttpSession session = request.getSession();
        Account account = (Account) session.getAttribute("account");
        String orderId = orderDAO.getOrderIdByTableId(tableId);
        Order order = orderId != null ? orderDAO.getOrderById(orderId) : (Order) session.getAttribute("tempOrder");

        if (order == null || !tableId.equals(order.getTableId())) {
            order = new Order();
            order.setOrderId(orderDAO.generateNextOrderId());
            order.setUserId(account.getUserId());
            order.setTableId(tableId);
            order.setOrderStatus("Pending");
            order.setOrderType("Dine-in");
            order.setOrderDate(new Date());
            order.setTotal(0);
            order.setOrderDetails(new ArrayList<>());
            session.setAttribute("tempOrder", order);
        }

        List<Customer> customers = customerDAO.getAllCustomers();
        Customer currentCustomer = order.getCustomerId() != null ? customerDAO.getCustomerById(order.getCustomerId()) : null;
        List<Dish> dishes = menuDAO.getAvailableDishes();

        boolean hasOrder = orderId != null && orderDAO.getOrderById(orderId) != null;
        request.setAttribute("hasOrder", hasOrder);

        request.setAttribute("tableId", tableId);
        request.setAttribute("order", order);
        request.setAttribute("customers", customers);
        request.setAttribute("currentCustomer", currentCustomer);
        request.setAttribute("dishes", dishes);
        request.getRequestDispatcher("ManageOrder/tableOverview.jsp").forward(request, response);
    }

    private void selectDish(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String tableId = request.getParameter("tableId");
        String returnTo = request.getParameter("returnTo");
        if (tableId == null) {
            request.setAttribute("error", "Missing table ID.");
            request.getRequestDispatcher("ManageOrder/selectDish.jsp").forward(request, response);
            return;
        }
        List<Dish> dishes = menuDAO.getAvailableDishes();
        request.setAttribute("dishes", dishes);
        request.setAttribute("tableId", tableId);
        request.setAttribute("returnTo", returnTo != null ? returnTo : "listTables");
        request.getRequestDispatcher("ManageOrder/selectDish.jsp").forward(request, response);
    }

    private void submitOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String tableId = request.getParameter("tableId");
        HttpSession session = request.getSession();
        Order order = (Order) session.getAttribute("tempOrder");
        String orderId = orderDAO.getOrderIdByTableId(tableId);

        if (orderId != null) {
            order = orderDAO.getOrderById(orderId);
        } else if (order == null || !tableId.equals(order.getTableId())) {
            Account account = (Account) session.getAttribute("account");
            order = new Order();
            order.setOrderId(orderDAO.generateNextOrderId());
            order.setUserId(account.getUserId());
            order.setTableId(tableId);
            order.setOrderStatus("Pending");
            order.setOrderType("Dine-in");
            order.setOrderDate(new Date());
            order.setTotal(0);
            order.setOrderDetails(new ArrayList<>());
        }

        List<OrderDetail> newDetails = new ArrayList<>();
        Enumeration<String> paramNames = request.getParameterNames();
        while (paramNames.hasMoreElements()) {
            String paramName = paramNames.nextElement();
            if (paramName.startsWith("quantity_")) {
                String dishId = paramName.substring("quantity_".length());
                int quantity = Integer.parseInt(request.getParameter(paramName));
                if (quantity > 0) {
                    Dish dish = menuDAO.getDishById(dishId);
                    if (dish != null) {
                        OrderDetail detail = new OrderDetail();
                        detail.setOrderId(order.getOrderId());
                        detail.setDishId(dishId);
                        detail.setQuantity(quantity);
                        detail.setSubtotal(dish.getDishPrice() * quantity);
                        detail.setDishName(dish.getDishName());
                        newDetails.add(detail);
                    }
                }
            }
        }

        for (OrderDetail newDetail : newDetails) {
            OrderDetail existingDetail = order.getOrderDetails().stream()
                    .filter(d -> d.getDishId().equals(newDetail.getDishId()))
                    .findFirst().orElse(null);
            if (existingDetail != null) {
                existingDetail.setQuantity(existingDetail.getQuantity() + newDetail.getQuantity());
                existingDetail.setSubtotal(existingDetail.getQuantity() * (existingDetail.getSubtotal() / existingDetail.getQuantity()));
            } else {
                order.getOrderDetails().add(newDetail);
            }
        }

        order.setTotal(order.getOrderDetails().stream().mapToDouble(OrderDetail::getSubtotal).sum());
        if (orderId != null) {
            updateOrderDetail(order);
            orderDAO.updateOrder(order);
        } else {
            session.setAttribute("tempOrder", order);
        }
        response.sendRedirect("order?action=tableOverview&tableId=" + tableId);
    }

    private void updateOrderDetail(Order order) throws SQLException, ClassNotFoundException {
        Connection conn = null;
        try {
            conn = DBContext.getConnection();
            conn.setAutoCommit(false);

            ObjectMapper mapper = new ObjectMapper();
            String dishListJson = mapper.writeValueAsString(order.getOrderDetails());
            double total = order.getOrderDetails().stream().mapToDouble(OrderDetail::getSubtotal).sum();

            String checkSql = "SELECT COUNT(*) FROM OrderDetail WHERE OrderId = ?";
            try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
                checkStmt.setString(1, order.getOrderId());
                try (var rs = checkStmt.executeQuery()) {
                    rs.next();
                    if (rs.getInt(1) > 0) {
                        String updateSql = "UPDATE OrderDetail SET DishList = ?, Total = ? WHERE OrderId = ?";
                        try (PreparedStatement stmt = conn.prepareStatement(updateSql)) {
                            stmt.setString(1, dishListJson);
                            stmt.setDouble(2, total);
                            stmt.setString(3, order.getOrderId());
                            stmt.executeUpdate();
                        }
                    } else {
                        String insertSql = "INSERT INTO OrderDetail (OrderDetailId, OrderId, DishList, Total) VALUES (?, ?, ?, ?)";
                        try (PreparedStatement stmt = conn.prepareStatement(insertSql)) {
                            stmt.setString(1, "OD" + order.getOrderId().substring(2));
                            stmt.setString(2, order.getOrderId());
                            stmt.setString(3, dishListJson);
                            stmt.setDouble(4, total);
                            stmt.executeUpdate();
                        }
                    }
                }
            }

            conn.commit();
        } catch (Exception e) {
            if (conn != null) {
                conn.rollback();
            }
            throw new SQLException("Error updating OrderDetail: " + e.getMessage(), e);
        } finally {
            if (conn != null) {
                conn.close();
            }
        }
    }

    private void editDishQuantity(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String dishId = request.getParameter("dishId");
        int newQuantity = Integer.parseInt(request.getParameter("newQuantity"));
        String tableId = request.getParameter("tableId");

        HttpSession session = request.getSession();
        Order order = (Order) session.getAttribute("tempOrder");
        String orderId = orderDAO.getOrderIdByTableId(tableId);
        if (order == null && orderId != null) {
            order = orderDAO.getOrderById(orderId);
        }
        if (order == null) {
            Account account = (Account) session.getAttribute("account");
            order = new Order();
            order.setOrderId(orderDAO.generateNextOrderId());
            order.setUserId(account.getUserId());
            order.setTableId(tableId);
            order.setOrderStatus("Pending");
            order.setOrderType("Dine-in");
            order.setOrderDate(new Date());
            order.setTotal(0);
            order.setOrderDetails(new ArrayList<>());
            session.setAttribute("tempOrder", order);
        }

        List<OrderDetail> details = order.getOrderDetails();
        OrderDetail detail = details.stream().filter(d -> d.getDishId().equals(dishId)).findFirst().orElse(null);
        Dish dish = menuDAO.getDishById(dishId);
        if (dish == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid dish ID");
            return;
        }

        if (newQuantity <= 0) {
            details.removeIf(d -> d.getDishId().equals(dishId));
        } else if (detail != null) {
            detail.setQuantity(newQuantity);
            detail.setSubtotal(newQuantity * dish.getDishPrice());
        } else {
            detail = new OrderDetail();
            detail.setOrderId(order.getOrderId());
            detail.setDishId(dishId);
            detail.setQuantity(newQuantity);
            detail.setSubtotal(newQuantity * dish.getDishPrice());
            detail.setDishName(dish.getDishName());
            details.add(detail);
        }

        order.setTotal(details.stream().mapToDouble(OrderDetail::getSubtotal).sum());
        if (orderId != null) {
            updateOrderDetail(order);
            orderDAO.updateOrder(order);
        } else {
            session.setAttribute("tempOrder", order);
        }
        response.sendRedirect("order?action=tableOverview&tableId=" + tableId);
    }

    private void deleteDish(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String dishId = request.getParameter("dishId");
        String tableId = request.getParameter("tableId");

        HttpSession session = request.getSession();
        Order order = (Order) session.getAttribute("tempOrder");
        String orderId = orderDAO.getOrderIdByTableId(tableId);
        if (order == null && orderId != null) {
            order = orderDAO.getOrderById(orderId);
        }

        if (order != null) {
            order.getOrderDetails().removeIf(d -> d.getDishId().equals(dishId));
            order.setTotal(order.getOrderDetails().stream().mapToDouble(OrderDetail::getSubtotal).sum());
            if (orderId != null) {
                updateOrderDetail(order);
                orderDAO.updateOrder(order);
            } else {
                session.setAttribute("tempOrder", order);
            }
        }
        response.sendRedirect("order?action=tableOverview&tableId=" + tableId);
    }

    private void completeOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String tableId = request.getParameter("tableId");
        String orderDescription = request.getParameter("orderDescription");
        HttpSession session = request.getSession();
        Order tempOrder = (Order) session.getAttribute("tempOrder");
        String orderId = orderDAO.getOrderIdByTableId(tableId);
        Order order = orderId != null ? orderDAO.getOrderById(orderId) : tempOrder;

        if (order == null || order.getOrderDetails() == null || order.getOrderDetails().isEmpty()) {
            request.setAttribute("error", "No order exists or the order is empty.");
            showTableOverview(request, response);
            return;
        }

        if (orderDescription != null && !orderDescription.trim().isEmpty()) {
            order.setOrderDescription(orderDescription);
        }

        order.setTotal(order.getOrderDetails().stream().mapToDouble(OrderDetail::getSubtotal).sum());

        // Check inventory before creating order
        try {
            orderDAO.checkInventoryForOrder(order.getOrderDetails());
        } catch (SQLException e) {
            request.setAttribute("error", e.getMessage());
            showTableOverview(request, response);
            return;
        }

        if (orderId == null) {
            orderDAO.createOrder(order);
            tableDAO.updateTableStatus(tableId, "Occupied");
        } else {
            orderDAO.updateOrder(order);
            updateOrderDetail(order);
        }

        session.removeAttribute("tempOrder");
        response.sendRedirect("order?action=listTables");
    }

    private void payOrder(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String orderId = request.getParameter("orderId");
        Order order = orderDAO.getOrderById(orderId);
        if (order == null || !"Pending".equals(order.getOrderStatus())) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid order or status");
            return;
        }

        order.setOrderStatus("Paid");
        orderDAO.updateOrder(order);
        if (order.getCustomerId() != null) {
            customerDAO.incrementNumberOfPayment(order.getCustomerId());
        }
        tableDAO.updateTableStatus(order.getTableId(), "Available");
        response.sendRedirect("order?action=listTables");
    }

    private void selectCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String tableId = request.getParameter("tableId");
        String customerId = request.getParameter("customerId");
        String orderId = request.getParameter("orderId");

        HttpSession session = request.getSession();
        Order order = (Order) session.getAttribute("tempOrder");
        if (order == null || (orderId != null && !orderId.equals(order.getOrderId()))) {
            order = orderId != null ? orderDAO.getOrderById(orderId) : null;
        }

        if (order != null && customerId != null && !customerId.isEmpty()) {
            Customer customer = customerDAO.getCustomerById(customerId);
            if (customer != null) {
                order.setCustomerId(customerId);
                order.setCustomerPhone(customer.getCustomerPhone());
                if (orderId != null) {
                    orderDAO.updateOrder(order);
                }
                session.setAttribute("tempOrder", order);
            }
        }
        response.sendRedirect("order?action=tableOverview&tableId=" + tableId);
    }

    private void addCustomer(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException, SQLException, ClassNotFoundException {
        String tableId = request.getParameter("tableId");
        String customerName = request.getParameter("customerName");
        String customerPhone = request.getParameter("customerPhone");
        String orderId = request.getParameter("orderId");

        HttpSession session = request.getSession();
        Order order = (Order) session.getAttribute("tempOrder");
        if (order == null || (orderId != null && !orderId.equals(order.getOrderId()))) {
            order = orderId != null ? orderDAO.getOrderById(orderId) : null;
        }

        if (order != null) {
            Customer customer = new Customer();
            customer.setCustomerName(customerName);
            customer.setCustomerPhone(customerPhone);
            String customerId = customerDAO.createCustomer(customer);
            order.setCustomerId(customerId);
            order.setCustomerPhone(customerPhone);
            if (orderId != null) {
                orderDAO.updateOrder(order);
            }
            session.setAttribute("tempOrder", order);
        }
        response.sendRedirect("order?action=tableOverview&tableId=" + tableId);
    }

    private void checkOrderByTable(HttpServletRequest request, HttpServletResponse response) throws IOException {
        String tableId = request.getParameter("tableId");
        try {
            String orderId = orderDAO.getOrderIdByTableId(tableId);
            response.setContentType("application/json");
            PrintWriter out = response.getWriter();
            out.print(new Gson().toJson(new OrderResponse(orderId)));
            out.flush();
        } catch (Exception e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error checking order: " + e.getMessage());
        }
    }

    private static class OrderResponse {
        String orderId;

        OrderResponse(String orderId) {
            this.orderId = orderId;
        }
    }
}