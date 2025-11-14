package Model;

public class InventoryItem {

    private String ItemId;
    private String ItemName;
    private String ItemType;
    private double ItemPrice;
    private double ItemQuantity;
    private String ItemUnit;
    private String ItemDescription;
    private int isDeleted;

    public InventoryItem() {
    }

    public InventoryItem(String ItemId, String ItemName, String ItemType, double ItemPrice, double ItemQuantity, String ItemUnit, String ItemDescription, int isDeleted) {
        this.ItemId = ItemId;
        this.ItemName = ItemName;
        this.ItemType = ItemType;
        this.ItemPrice = ItemPrice;
        this.ItemQuantity = ItemQuantity;
        this.ItemUnit = ItemUnit;
        this.ItemDescription = ItemDescription;
        this.isDeleted = isDeleted;
    }

    public InventoryItem(String ItemId, String ItemName, String ItemType, double ItemPrice, double ItemQuantity, String ItemUnit, String ItemDescription) {
        this.ItemId = ItemId;
        this.ItemName = ItemName;
        this.ItemType = ItemType;
        this.ItemPrice = ItemPrice;
        this.ItemQuantity = ItemQuantity;
        this.ItemUnit = ItemUnit;
        this.ItemDescription = ItemDescription;
    }

    public String getItemId() {
        return ItemId;
    }

    public void setItemId(String ItemId) {
        this.ItemId = ItemId;
    }

    public String getItemName() {
        return ItemName;
    }

    public void setItemName(String ItemName) {
        this.ItemName = ItemName;
    }

    public String getItemType() {
        return ItemType;
    }

    public void setItemType(String ItemType) {
        this.ItemType = ItemType;
    }

    public double getItemPrice() {
        return ItemPrice;
    }

    public void setItemPrice(double ItemPrice) {
        this.ItemPrice = ItemPrice;
    }

    public double getItemQuantity() {
        return ItemQuantity;
    }

    public void setItemQuantity(double ItemQuantity) {
        this.ItemQuantity = ItemQuantity;
    }

    public String getItemUnit() {
        return ItemUnit;
    }

    public void setItemUnit(String ItemUnit) {
        this.ItemUnit = ItemUnit;
    }

    public String getItemDescription() {
        return ItemDescription;
    }

    public void setItemDescription(String ItemDescription) {
        this.ItemDescription = ItemDescription;
    }

    public int getIsDeleted() {
        return isDeleted;
    }

    public void setIsDeleted(int isDeleted) {
        this.isDeleted = isDeleted;
    }

    
}
