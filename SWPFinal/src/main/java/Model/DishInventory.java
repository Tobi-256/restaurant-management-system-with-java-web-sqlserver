package Model;

public class DishInventory {
    private String DishId; // Tên thuộc tính khớp với tên cột trong DB
    private String ItemId; // Tên thuộc tính khớp với tên cột trong DB
    private double QuantityUsed;

    // Constructors
    public DishInventory() {}

    public DishInventory(String dishId, String itemId, double quantityUsed) {
        DishId = dishId;
        ItemId = itemId;
        QuantityUsed = quantityUsed;
    }

    // Getters and setters
    public String getDishId() {
        return DishId;
    }

    public void setDishId(String dishId) {
        DishId = dishId;
    }

    public String getItemId() {
        return ItemId;
    }

    public void setItemId(String itemId) {
        ItemId = itemId;
    }

    public double getQuantityUsed() {
        return QuantityUsed;
    }

    public void setQuantityUsed(double quantityUsed) {
        QuantityUsed = quantityUsed;
    }
}