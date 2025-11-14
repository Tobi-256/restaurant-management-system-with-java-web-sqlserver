/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package Controller.ManageInventory;

import DAO.InventoryDAO;
import Model.InventoryItem;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.sql.SQLException;
/**
 *
 * @author DELL-Laptop
 */
@WebServlet(name = "AddInventoryItemController", urlPatterns = {"/AddInventoryItemController"})
public class AddInventoryItemController extends HttpServlet {

//    private static final String UPLOAD_DIR = "ManageInventory/item_images"; // Thư mục lưu trữ hình ảnh (trong web app)
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
            out.println("<title>Servlet AddInventoryItemController</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AddInventoryItemController at " + request.getContextPath() + "</h1>");
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
        response.setContentType("text/html;charset=UTF-8");
         HttpSession session = request.getSession();
        try {
            // 1. Lấy dữ liệu từ form (giữ nguyên)
            String itemName = request.getParameter("itemName");
            String itemType = request.getParameter("itemType");
            double itemPrice = Double.parseDouble(request.getParameter("itemPrice"));
            String itemUnit = request.getParameter("itemUnit");
            String itemDescription = request.getParameter("itemDescription");

            String quantityStr = request.getParameter("itemQuantity");
            if (quantityStr != null) {
                // Thay thế dấu phẩy bằng dấu chấm
                quantityStr = quantityStr.replace(",", ".");
            }

            double itemQuantity = Double.parseDouble(quantityStr);
            // 5. Thêm vào database
            InventoryDAO inventoryDAO = new InventoryDAO();
           //String isItemExist = inventoryDAO.isInventoryItemExist(itemName);
            try {
            // Check for duplicate phone number
            System.out.println(inventoryDAO.isInventoryItemExistForAdd(itemName));
            if (inventoryDAO.isInventoryItemExistForAdd(itemName)){
                System.out.println("ooooooooooooooooooooooooooo");
             //   System.out.println(customerDAO.isPhoneExists(customerPhone, null));
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("Inventory already exists. Please check agains.");
               
                return;
            }
            // If all validations pass, add the customer
            String itemId = inventoryDAO.generateNextInventoryId();
             System.out.println("ppppppppppppppppppppppp");
             //System.out.println(customerDAO.isPhoneExists(customerPhone, null));
            InventoryItem newItem = new InventoryItem(itemId, itemName, itemType, itemPrice, itemQuantity, itemUnit, itemDescription, 0);
            inventoryDAO.addNewInventoryItem(newItem);
            session.setAttribute("message", "Inventory added successfully!");
            
        } catch (SQLException | ClassNotFoundException ex) {
            session.setAttribute("errorMessage", "Database error: " + ex.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/ViewInventoryController");
            
            
            
            
            
            
//            if (!"None".equals(isItemExist)) {
//                InventoryItem upItem = new InventoryItem(isItemExist, itemName, itemType, itemPrice, itemQuantity, itemUnit, itemDescription);
//              
//                inventoryDAO.updateInventoryItem(upItem);
//            } else {
//                String itemID = inventoryDAO.generateNextInventoryId();
//                System.out.println(itemID);
//                InventoryItem newItem = new InventoryItem(itemID, itemName, itemType, itemPrice, itemQuantity, itemUnit, itemDescription, 0);
//               
//                System.out.println("OOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO");
//                System.out.println(newItem);
//                inventoryDAO.addNewInventoryItem(newItem);
//            }
//
//            // 6. Chuyển hướng
//            response.sendRedirect("ViewInventoryController");

        } catch (Exception e) {
            e.printStackTrace();
            response.getWriter().println("Có lỗi xảy ra khi thêm nguyên liệu: " + e.getMessage());
        }
    }
}
