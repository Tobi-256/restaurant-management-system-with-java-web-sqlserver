package DAO;

import Model.Dish;
import Model.InventoryItem;
import Model.DishInventory;
import DB.DBContext;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class MenuDAO {

    private static final Logger LOGGER = Logger.getLogger(MenuDAO.class.getName()); // Logger

    public String addDish(Dish dish) {
    String dishId = generateUniqueDishId();
    while (dishIdExists(dishId)) {
        dishId = generateUniqueDishId();
    }

    String sql = "INSERT INTO Dish (DishId, DishName, DishType, DishPrice, DishDescription, DishImage, DishStatus, IngredientStatus) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
    try (Connection connection = DBContext.getConnection();
         PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

        preparedStatement.setString(1, dishId);
        preparedStatement.setString(2, dish.getDishName());
        preparedStatement.setString(3, dish.getDishType());
        preparedStatement.setDouble(4, dish.getDishPrice());
        preparedStatement.setString(5, dish.getDishDescription());
        preparedStatement.setString(6, dish.getDishImage());
        preparedStatement.setString(7, dish.getDishStatus());
        preparedStatement.setString(8, "Sufficient"); // Giá trị mặc định ban đầu

        int affectedRows = preparedStatement.executeUpdate();

        if (affectedRows > 0) {
            return dishId;
        } else {
            LOGGER.log(Level.WARNING, "Creating dish failed, no rows affected.");
            return null;
        }

    } catch (SQLException | ClassNotFoundException e) {
        LOGGER.log(Level.SEVERE, "Error adding dish", e);
        return null;
    }
}

    private boolean dishIdExists(String dishId) {
        String sql = "SELECT COUNT(*) FROM Dish WHERE DishId = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, dishId);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt(1) > 0; // True if dishId exists
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error checking dishId existence", e);
            return true; // Assume exists to prevent potential duplicate
        }
        return false;
    }

    private String generateUniqueDishId() {
        String prefix = "DI";
        int nextId = getNextAvailableId();
        if (nextId == -1) {
            LOGGER.log(Level.SEVERE, "Failed to generate next available DishId");
            throw new RuntimeException("Cannot generate unique DishId");
        }
        return String.format("%s%03d", prefix, nextId);
    }

    private int getNextAvailableId() {
        String sql = "SELECT ISNULL(MAX(CAST(SUBSTRING(DishId, 3, LEN(DishId)) AS INT)), 0) + 1 FROM Dish WHERE DishId LIKE 'DI%'";
        try (Connection connection = DBContext.getConnection(); PreparedStatement preparedStatement = connection.prepareStatement(sql); ResultSet resultSet = preparedStatement.executeQuery()) {

            if (resultSet.next()) {
                return resultSet.getInt(1);
            } else {
                return 1; // Nếu không có bản ghi nào, bắt đầu từ 1
            }

        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error getting next available ID", e);
            return -1; // Báo hiệu lỗi
        }
    }

    // Check if dish name exists
    public boolean dishNameExists(String dishName) {
        String sql = "SELECT COUNT(*) FROM Dish WHERE DishName = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, dishName);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt(1) > 0; // True if dish name exists
                }
            }

        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error checking dish name existence", e);
            return false; // Assume not exists in case of error
        }
        return false; // Assume not exists in case of error
    }

    // View all dishes
    public List<Dish> getAllDishes() {
    List<Dish> dishList = new ArrayList<>();
    String sql = "SELECT DishId, DishName, DishType, DishPrice, DishDescription, DishImage, DishStatus, IngredientStatus FROM Dish";
    try (Connection connection = DBContext.getConnection(); PreparedStatement preparedStatement = connection.prepareStatement(sql); ResultSet resultSet = preparedStatement.executeQuery()) {
        while (resultSet.next()) {
            Dish dish = new Dish();
            dish.setDishId(resultSet.getString("DishId"));
            dish.setDishName(resultSet.getString("DishName"));
            dish.setDishType(resultSet.getString("DishType"));
            dish.setDishPrice(resultSet.getDouble("DishPrice"));
            dish.setDishDescription(resultSet.getString("DishDescription"));
            dish.setDishImage(resultSet.getString("DishImage"));
            dish.setDishStatus(resultSet.getString("DishStatus"));
            dish.setIngredientStatus(resultSet.getString("IngredientStatus"));
            dishList.add(dish);
        }
    } catch (SQLException | ClassNotFoundException e) {
        LOGGER.log(Level.SEVERE, "Error getting all dishes", e);
    }
    return dishList; // Trả về danh sách rỗng thay vì null
}
    // Thay đổi từ private sang public
    public boolean deleteDishInventory(String dishId) {
        String sql = "DELETE FROM Dish_Inventory WHERE DishId = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, dishId);
            int affectedRows = preparedStatement.executeUpdate();
            return affectedRows >= 0; // Consider success even if no rows were deleted (already clean)

        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error deleting dish inventory for dishId: " + dishId, e);
            return false;
        }
    }

    // Delete a dish (chỉ xóa nếu không có trong Order Detail)
    // Delete a dish and its related records in DishInventory (nếu không có trong Order Detail)
    public boolean deleteDish(String dishId) {
        Connection connection = null;
        PreparedStatement checkOrderDetailStmt = null;
        PreparedStatement deleteDishInventoryStmt = null;
        PreparedStatement deleteDishStmt = null;
        ResultSet resultSet = null;

        try {
            connection = DBContext.getConnection();
            connection.setAutoCommit(false); // Bắt đầu transaction

            // 1. Kiểm tra xem Dish có tồn tại trong Order Detail không
            String checkOrderDetailSql = "SELECT COUNT(*) FROM [OrderDetail] WHERE DishId = ?";  // nhớ dấu []
            checkOrderDetailStmt = connection.prepareStatement(checkOrderDetailSql);
            checkOrderDetailStmt.setString(1, dishId);
            resultSet = checkOrderDetailStmt.executeQuery();

            int orderDetailCount = 0;
            if (resultSet.next()) {
                orderDetailCount = resultSet.getInt(1);
            }

            if (orderDetailCount == 0) {
                // 2. Xóa các bản ghi liên quan trong DishInventory
                String deleteDishInventorySql = "DELETE FROM Dish_Inventory WHERE DishId = ?";
                deleteDishInventoryStmt = connection.prepareStatement(deleteDishInventorySql);
                deleteDishInventoryStmt.setString(1, dishId);
                deleteDishInventoryStmt.executeUpdate();

                // 3. Xóa Dish
                    String deleteDishSql = "DELETE FROM Dish WHERE DishId = ?";
                deleteDishStmt = connection.prepareStatement(deleteDishSql);
                deleteDishStmt.setString(1, dishId);
                int affectedRows = deleteDishStmt.executeUpdate();

                connection.commit(); // Commit transaction
                return affectedRows > 0;
            } else {
                connection.rollback(); // Rollback transaction nếu có trong Order Detail
                return false;
            }

        } catch (SQLException | ClassNotFoundException e) {
            if (connection != null) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackEx) {
                    LOGGER.log(Level.WARNING, "Error rolling back transaction", rollbackEx);
                }
            }
            LOGGER.log(Level.SEVERE, "Error deleting dish with ID: " + dishId, e);
            return false;
        } finally {
            // Đảm bảo đóng tất cả các resources trong finally block
            try {
                if (resultSet != null) {
                    resultSet.close();
                }
                if (checkOrderDetailStmt != null) {
                    checkOrderDetailStmt.close();
                }
                if (deleteDishInventoryStmt != null) {
                    deleteDishInventoryStmt.close();
                }
                if (deleteDishStmt != null) {
                    deleteDishStmt.close();
                }
                if (connection != null) {
                    connection.close();
                }
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing resources", e);
            }
        }
    }

    // Cập nhật updateDish để tự động kiểm tra IngredientStatus
   public boolean updateDish(Dish dish) {
    String sql = "UPDATE Dish SET DishName = ?, DishType = ?, DishPrice = ?, DishDescription = ?, DishImage = ?, DishStatus = ? WHERE DishId = ?";
    try (Connection connection = DBContext.getConnection();
         PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

        preparedStatement.setString(1, dish.getDishName());
        preparedStatement.setString(2, dish.getDishType());
        preparedStatement.setDouble(3, dish.getDishPrice());
        preparedStatement.setString(4, dish.getDishDescription());
        preparedStatement.setString(5, dish.getDishImage());
        preparedStatement.setString(6, dish.getDishStatus());
        preparedStatement.setString(7, dish.getDishId());

        int affectedRows = preparedStatement.executeUpdate();
        if (affectedRows > 0) {
            return updateIngredientStatus(dish.getDishId()); // Tự động cập nhật IngredientStatus
        }
        return false;

    } catch (SQLException | ClassNotFoundException e) {
        LOGGER.log(Level.SEVERE, "Error updating dish", e);
        return false;
    }
}

    // Method to get a specific dish by ID
    public Dish getDishById(String dishId) {
        String sql = "SELECT DishId, DishName, DishType, DishPrice, DishDescription, DishImage, DishStatus, IngredientStatus FROM Dish WHERE DishId = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, dishId);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    Dish dish = new Dish();
                    dish.setDishId(resultSet.getString("DishId"));
                    dish.setDishName(resultSet.getString("DishName"));
                    dish.setDishType(resultSet.getString("DishType"));
                    dish.setDishPrice(resultSet.getDouble("DishPrice"));
                    dish.setDishDescription(resultSet.getString("DishDescription"));
                    dish.setDishImage(resultSet.getString("DishImage"));
                    dish.setDishStatus(resultSet.getString("DishStatus"));
                    dish.setIngredientStatus(resultSet.getString("IngredientStatus"));

                    return dish;
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error getting dish by ID", e);
            return null; // Indicate failure
        }
        return null; // Dish not found
    }

    // Method to get ingredients (DishInventory) for a specific dish
    public List<DishInventory> getDishIngredients(String dishId) {
    List<DishInventory> dishIngredients = new ArrayList<>();
    String sql = "SELECT DishId, ItemId, QuantityUsed FROM Dish_Inventory WHERE DishId = ?";
    try (Connection connection = DBContext.getConnection(); PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
        preparedStatement.setString(1, dishId);
        try (ResultSet resultSet = preparedStatement.executeQuery()) {
            while (resultSet.next()) {
                DishInventory dishInventory = new DishInventory();
                dishInventory.setDishId(resultSet.getString("DishId"));
                dishInventory.setItemId(resultSet.getString("ItemId"));
                dishInventory.setQuantityUsed(resultSet.getDouble("QuantityUsed"));
                dishIngredients.add(dishInventory);
            }
        }
    } catch (SQLException | ClassNotFoundException e) {
        LOGGER.log(Level.SEVERE, "Error getting dish ingredients", e);
    }
    return dishIngredients; // Trả về danh sách rỗng thay vì null
}

    // InventoryItem operations
    public List<InventoryItem> getAllInventory() {
    List<InventoryItem> inventoryList = new ArrayList<>();
    String sql = "SELECT ItemId, ItemName, ItemType, ItemPrice, ItemQuantity, ItemUnit, ItemDescription FROM Inventory WHERE IsDeleted = 0";
    try (Connection connection = DBContext.getConnection(); PreparedStatement preparedStatement = connection.prepareStatement(sql); ResultSet resultSet = preparedStatement.executeQuery()) {
        while (resultSet.next()) {
            InventoryItem inventory = new InventoryItem();
            inventory.setItemId(resultSet.getString("ItemId"));
            inventory.setItemName(resultSet.getString("ItemName"));
            inventory.setItemType(resultSet.getString("ItemType"));
            inventory.setItemPrice(resultSet.getDouble("ItemPrice"));
            inventory.setItemQuantity(resultSet.getInt("ItemQuantity"));
            inventory.setItemUnit(resultSet.getString("ItemUnit"));
            inventory.setItemDescription(resultSet.getString("ItemDescription"));
            inventoryList.add(inventory);
        }
    } catch (SQLException | ClassNotFoundException e) {
        LOGGER.log(Level.SEVERE, "Error getting all inventory", e);
    }
    return inventoryList; // Trả về danh sách rỗng thay vì null
}
    // DishInventory operations
    public boolean addDishInventory(DishInventory dishInventory) {
    String sql = "INSERT INTO Dish_Inventory (DishId, ItemId, QuantityUsed) VALUES (?, ?, ?)";
    try (Connection connection = DBContext.getConnection();
         PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

        preparedStatement.setString(1, dishInventory.getDishId());
        preparedStatement.setString(2, dishInventory.getItemId());
        preparedStatement.setDouble(3, dishInventory.getQuantityUsed());

        int affectedRows = preparedStatement.executeUpdate();
        return affectedRows > 0;

    } catch (SQLException | ClassNotFoundException e) {
        LOGGER.log(Level.SEVERE, "Error adding dish inventory for dishId: " + dishInventory.getDishId() + 
                   ", itemId: " + dishInventory.getItemId(), e);
        return false;
    }
}

    public InventoryItem getInventoryItemById(String itemId) {
        String sql = "SELECT ItemId, ItemName, ItemType, ItemPrice, ItemQuantity, ItemUnit, ItemDescription FROM Inventory WHERE ItemId = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            preparedStatement.setString(1, itemId);
            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                if (resultSet.next()) {
                    InventoryItem inventory = new InventoryItem();
                    inventory.setItemId(resultSet.getString("ItemId"));
                    inventory.setItemName(resultSet.getString("ItemName"));
                    inventory.setItemType(resultSet.getString("ItemType"));
                    inventory.setItemPrice(resultSet.getDouble("ItemPrice"));
                    inventory.setItemQuantity(resultSet.getInt("ItemQuantity"));
                    inventory.setItemUnit(resultSet.getString("ItemUnit"));
                    inventory.setItemDescription(resultSet.getString("ItemDescription"));
                    return inventory;
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error getting inventory item by ID", e);
            return null;
        }
        return null;
    }

    public List<Dish> searchAndFilterDishes(String keyword, String status, String ingredientStatus) {
        List<Dish> dishList = new ArrayList<>();
        String sql = "SELECT DishId, DishName, DishType, DishPrice, DishDescription, DishImage, DishStatus, IngredientStatus FROM Dish WHERE 1=1"; // 1=1 để dễ dàng thêm các điều kiện AND

        if (keyword != null && !keyword.isEmpty()) {
            sql += " AND DishName LIKE ?";
        }
        if (status != null && !status.isEmpty()) {
            sql += " AND DishStatus = ?";
        }
        if (ingredientStatus != null && !ingredientStatus.isEmpty()) {
            sql += " AND IngredientStatus = ?";
        }

        try (Connection connection = DBContext.getConnection(); PreparedStatement preparedStatement = connection.prepareStatement(sql)) {

            int parameterIndex = 1;
            if (keyword != null && !keyword.isEmpty()) {
                preparedStatement.setString(parameterIndex++, "%" + keyword + "%");
            }
            if (status != null && !status.isEmpty()) {
                preparedStatement.setString(parameterIndex++, status);
            }
            if (ingredientStatus != null && !ingredientStatus.isEmpty()) {
                preparedStatement.setString(parameterIndex++, ingredientStatus);
            }

            try (ResultSet resultSet = preparedStatement.executeQuery()) {
                while (resultSet.next()) {
                    Dish dish = new Dish();
                    dish.setDishId(resultSet.getString("DishId"));
                    dish.setDishName(resultSet.getString("DishName"));
                    dish.setDishType(resultSet.getString("DishType"));
                    dish.setDishPrice(resultSet.getDouble("DishPrice"));
                    dish.setDishDescription(resultSet.getString("DishDescription"));
                    dish.setDishImage(resultSet.getString("DishImage"));
                    dish.setDishStatus(resultSet.getString("DishStatus"));
                    dish.setIngredientStatus(resultSet.getString("IngredientStatus"));
                    dishList.add(dish);
                }
            }

        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error searching and filtering dishes", e);
            return null;
        }
        return dishList;
    }
    // Phương thức kiểm tra và cập nhật IngredientStatus

   public boolean updateIngredientStatus(String dishId) {
    List<DishInventory> ingredients = getDishIngredients(dishId);
    if (ingredients == null || ingredients.isEmpty()) {
        return setIngredientStatus(dishId, "Sufficient");
    }

    boolean allSufficient = true;
    for (DishInventory ingredient : ingredients) {
        InventoryItem inventory = getInventoryItemById(ingredient.getItemId());
        if (inventory == null || inventory.getItemQuantity() < ingredient.getQuantityUsed()) {
            allSufficient = false;
            break;
        }
    }

    String newStatus = allSufficient ? "Sufficient" : "Insufficient";
    return setIngredientStatus(dishId, newStatus);
}

    // Phương thức phụ để cập nhật IngredientStatus trong bảng Dish
    private boolean setIngredientStatus(String dishId, String status) {
        String sql = "UPDATE Dish SET IngredientStatus = ? WHERE DishId = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement preparedStatement = connection.prepareStatement(sql)) {
            preparedStatement.setString(1, status);
            preparedStatement.setString(2, dishId);
            int affectedRows = preparedStatement.executeUpdate();
            return affectedRows > 0;
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error setting IngredientStatus for dishId: " + dishId, e);
            return false;
        }
    }
    public List<Dish> getAvailableDishes() {
    List<Dish> dishList = new ArrayList<>();
    String sql = "SELECT DishId, DishName, DishType, DishPrice, DishDescription, DishImage, DishStatus, IngredientStatus " +
                 "FROM Dish WHERE DishStatus = 'Available' AND IngredientStatus = 'Sufficient'";
    try (Connection connection = DBContext.getConnection();
         PreparedStatement preparedStatement = connection.prepareStatement(sql);
         ResultSet resultSet = preparedStatement.executeQuery()) {
        while (resultSet.next()) {
            Dish dish = new Dish();
            dish.setDishId(resultSet.getString("DishId"));
            dish.setDishName(resultSet.getString("DishName"));
            dish.setDishType(resultSet.getString("DishType"));
            dish.setDishPrice(resultSet.getDouble("DishPrice"));
            dish.setDishDescription(resultSet.getString("DishDescription"));
            dish.setDishImage(resultSet.getString("DishImage"));
            dish.setDishStatus(resultSet.getString("DishStatus"));
            dish.setIngredientStatus(resultSet.getString("IngredientStatus"));
            dishList.add(dish);
        }
    } catch (SQLException | ClassNotFoundException e) {
        LOGGER.log(Level.SEVERE, "Error getting available dishes", e);
    }
    return dishList;
}
}
