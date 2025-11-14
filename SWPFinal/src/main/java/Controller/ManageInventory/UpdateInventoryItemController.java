package Controller.ManageInventory;

import Controller.ManageCustomer.UpdateCustomerProfileController;
import DAO.InventoryDAO;
import Model.InventoryItem;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "UpdateInventoryItemController", urlPatterns = {"/UpdateInventoryItemController"})
public class UpdateInventoryItemController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // 1. Lấy tất cả các tham số từ request
        String itemId = request.getParameter("itemId");
        String itemName = request.getParameter("itemName");
        String itemType = request.getParameter("itemType");
        String itemPrice_raw = request.getParameter("itemPrice");
        String itemQuantity_raw = request.getParameter("itemQuantity");

        String itemUnit = request.getParameter("itemUnit");
        String itemDescription = request.getParameter("itemDescription");
//        System.err.println(itemQuantity_raw);
//        System.err.println(itemQuantity_raw);
//        System.err.println(itemQuantity_raw);
//        System.err.println(itemQuantity_raw);
//        System.err.println(itemQuantity_raw);
//        System.err.println(itemQuantity_raw);
        // 1. Kiểm tra dữ liệu đầu vào (Validation)
        double itemPrice = Double.parseDouble(itemPrice_raw);
        double itemQuantity = Double.parseDouble(itemQuantity_raw);

//        System.out.println("--- Giá trị đã parse trong doPost ---");
//        System.out.println("itemPrice: " + itemPrice);
//        System.out.println("itemQuantity: " + itemQuantity);
        System.out.println("------------------------------------");
          System.out.println("NGUYEN THANH PHAT");
        
        
        
        
        InventoryDAO inventoryDAO = new InventoryDAO();
        InventoryItem updatedItem = new InventoryItem();
        updatedItem.setItemId(itemId);
        updatedItem.setItemName(itemName);
        updatedItem.setItemType(itemType);
        updatedItem.setItemPrice(itemPrice);
        updatedItem.setItemQuantity(itemQuantity);
        updatedItem.setItemUnit(itemUnit);
        updatedItem.setItemDescription(itemDescription);
        
        
        
        
        if (inventoryDAO.isInventoryItemExistForUpdate(itemName,itemId)) {
            System.out.println(inventoryDAO.isInventoryItemExistForUpdate(itemName,itemId));
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.getWriter().write("Inventory item already exists. Please check agains.");
            return;
        }
        inventoryDAO.updateInventoryItem(updatedItem);
        request.getSession().setAttribute("message", "Customer updated successfully!");
        response.sendRedirect(request.getContextPath() + "/ViewInventoryController");

//        // 2. Tạo đối tượng InventoryItem để cập nhật
//        InventoryItem updatedItem = new InventoryItem();
//        updatedItem.setItemId(itemId);
//        updatedItem.setItemName(itemName);
//        updatedItem.setItemType(itemType);
//        updatedItem.setItemPrice(itemPrice);
//        updatedItem.setItemQuantity(itemQuantity);
//        updatedItem.setItemUnit(itemUnit);
//        updatedItem.setItemDescription(itemDescription);
//
//        // 3. Cập nhật sản phẩm trong kho hàng trong database
//        InventoryDAO updateDao = new InventoryDAO();
//        updateDao.updateInventoryItem(updatedItem);
//
//        // 4. Chuyển hướng đến trang danh sách sản phẩm
//        response.sendRedirect("ViewInventoryController");
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Xử lý cập nhật sản phẩm trong kho hàng.";
    } // </editor-fold>

}
