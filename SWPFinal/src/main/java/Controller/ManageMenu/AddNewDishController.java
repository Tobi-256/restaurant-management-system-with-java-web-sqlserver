package Controller.ManageMenu;

import DAO.MenuDAO;
import Model.Dish;
import Model.DishInventory;
import Model.InventoryItem;
import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet("/addnewdish")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024,  // 1MB
    maxFileSize = 1024 * 1024 * 10,   // 10MB
    maxRequestSize = 1024 * 1024 * 100 // 100MB
)
public class AddNewDishController extends HttpServlet {

    private final MenuDAO menuDAO = new MenuDAO();
    private static final String UPLOAD_DIRECTORY = "dish_img"; // Thư mục con trong ManageMenu
    private static final Logger LOGGER = Logger.getLogger(AddNewDishController.class.getName());

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        List<InventoryItem> inventoryList = menuDAO.getAllInventory();
        if (inventoryList != null && !inventoryList.isEmpty()) {
            LOGGER.info("Inventory list retrieved with " + inventoryList.size() + " items.");
            request.setAttribute("inventoryList", inventoryList);
        } else {
            LOGGER.warning("Inventory list is null or empty.");
            request.setAttribute("errorMessage", "No inventory items available.");
        }
        RequestDispatcher dispatcher = request.getRequestDispatcher("ManageMenu/AddNewDish.jsp");
        dispatcher.forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");

        String dishName = request.getParameter("dishName");
        String dishType = request.getParameter("dishType");
        String dishPriceStr = request.getParameter("dishPrice");
        String dishDescription = request.getParameter("dishDescription");

        // Validation variables
        List<String> errors = new ArrayList<>();
        double dishPrice = 0;

        // Validate dishName
        if (dishName == null || dishName.trim().isEmpty()) {
            errors.add("Dish name is required.");
        } else if (menuDAO.dishNameExists(dishName)) {
            errors.add("Dish name already exists.");
        }

        // Validate dishPrice
        try {
            dishPrice = Double.parseDouble(dishPriceStr);
            if (dishPrice <= 0) {
                errors.add("Price must be greater than 0.");
            }
        } catch (NumberFormatException e) {
            errors.add("Invalid dish price format.");
        }

        // Handle image upload
        String webAppRoot = getServletContext().getRealPath("/");
        File webAppRootDir = new File(webAppRoot);
        File targetDir = webAppRootDir.getParentFile();
        File projectRootDir = targetDir.getParentFile();
        String srcWebAppPath = new File(projectRootDir, "src/main/webapp/ManageMenu").getAbsolutePath();
        String uploadPath = srcWebAppPath + File.separator + UPLOAD_DIRECTORY;

        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) uploadDir.mkdirs();

        String dishImage = null;
        Part filePart = request.getPart("dishImage");
        if (filePart != null && filePart.getSize() > 0 && filePart.getSubmittedFileName() != null && !filePart.getSubmittedFileName().isEmpty()) {
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;
            String filePath = uploadPath + File.separator + uniqueFileName;
            dishImage = "/ManageMenu/" + UPLOAD_DIRECTORY + "/" + uniqueFileName; // Đường dẫn tương đối để hiển thị

            try (InputStream fileContent = filePart.getInputStream()) {
                Files.copy(fileContent, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
                LOGGER.info("File saved successfully to: " + filePath);
            } catch (IOException e) {
                errors.add("Error uploading image: " + e.getMessage());
            }
        }

        // Nếu có lỗi, trả lại trang với thông báo lỗi
        if (!errors.isEmpty()) {
            request.setAttribute("errors", errors);
            request.setAttribute("inventoryList", menuDAO.getAllInventory());
            request.getRequestDispatcher("ManageMenu/AddNewDish.jsp").forward(request, response);
            return;
        }

        // Nếu không có lỗi, tiếp tục xử lý
        Dish dish = new Dish();
        dish.setDishName(dishName);
        dish.setDishType(dishType);
        dish.setDishPrice(dishPrice);
        dish.setDishDescription(dishDescription);
        dish.setDishImage(dishImage);
        dish.setDishStatus("Available");

        String newDishId = menuDAO.addDish(dish);
        if (newDishId != null) {
            String[] itemIds = request.getParameterValues("itemId");
            boolean hasError = false;

            if (itemIds != null && itemIds.length > 0) {
                for (String itemId : itemIds) {
                    try {
                        String quantityParam = request.getParameter("quantityUsed" + itemId);
                        double quantityUsed = quantityParam != null && !quantityParam.isEmpty() ? Double.parseDouble(quantityParam) : 0;
                        if (quantityUsed > 0) {
                            DishInventory dishInventory = new DishInventory(newDishId, itemId, quantityUsed);
                            if (!menuDAO.addDishInventory(dishInventory)) {
                                hasError = true;
                                break;
                            }
                        }
                    } catch (NumberFormatException e) {
                        hasError = true;
                        break;
                    }
                }
            }

            menuDAO.updateIngredientStatus(newDishId);

            if (!hasError) {
                request.setAttribute("message", "Dish added successfully!");
            } else {
                request.setAttribute("errorMessage", "Dish added but some ingredients failed.");
            }
        } else {
            request.setAttribute("errorMessage", "Failed to add dish.");
        }

        request.setAttribute("inventoryList", menuDAO.getAllInventory());
        request.getRequestDispatcher("ManageMenu/AddNewDish.jsp").forward(request, response);
    }
}