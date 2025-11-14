package Model;

public class Dish {
    private String DishId; // Tên thuộc tính khớp với tên cột trong DB
    private String DishName;
    private String DishType;
    private double DishPrice;
    private String DishDescription;
    private String DishImage;
    private String DishStatus;
    private String IngredientStatus;

    // Constructors
    public Dish() {}

    public Dish(String dishId, String dishName, String dishType, double dishPrice, String dishDescription, String dishImage, String dishStatus,String ingredientStatus) {
        DishId = dishId;
        DishName = dishName;
        DishType = dishType;
        DishPrice = dishPrice;
        DishDescription = dishDescription;
        DishImage = dishImage;
        DishStatus = dishStatus;
        IngredientStatus = ingredientStatus;
    }

    // Getters and setters
    public String getDishId() {
        return DishId;
    }

    public void setDishId(String dishId) {
        DishId = dishId;
    }

    public String getDishName() {
        return DishName;
    }

    public void setDishName(String dishName) {
        DishName = dishName;
    }

    public String getDishType() {
        return DishType;
    }

    public void setDishType(String dishType) {
        DishType = dishType;
    }

    public double getDishPrice() {
        return DishPrice;
    }

    public void setDishPrice(double dishPrice) {
        DishPrice = dishPrice;
    }

    public String getDishDescription() {
        return DishDescription;
    }

    public void setDishDescription(String dishDescription) {
        DishDescription = dishDescription;
    }

    public String getDishImage() {
        return DishImage;
    }

    public void setDishImage(String dishImage) {
        DishImage = dishImage;
    }

    public String getDishStatus() {
        return DishStatus;
    }

    public void setDishStatus(String dishStatus) {
        DishStatus = dishStatus;
    }

       public String getIngredientStatus() {
        return IngredientStatus;
    }

    public void setIngredientStatus(String ingredientStatus) {
        IngredientStatus = ingredientStatus;
    }
}