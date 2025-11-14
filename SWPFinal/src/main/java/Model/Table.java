package Model;

public class Table {

    private String TableId;
    private String TableStatus;
    private int NumberOfSeats;
    private int FloorNumber;
    private boolean IsDeleted;
    private boolean hasOrder;
    private Order order;

    // Constructor không tham số (default constructor)
    public Table() {
        this.IsDeleted = false; // Giá trị mặc định
    }

    // Constructor đầy đủ
    public Table(String TableId, String TableStatus, int NumberOfSeats, int FloorNumber, boolean IsDeleted, boolean hasOrder) {
        this.TableId = TableId;
        this.TableStatus = TableStatus;
        this.NumberOfSeats = NumberOfSeats;
        this.FloorNumber = FloorNumber;
        this.IsDeleted = IsDeleted;
        this.hasOrder = hasOrder;
    }

    // Constructor không có TableId (cho trường hợp insert)
    public Table(String TableStatus, int NumberOfSeats, int FloorNumber) {
        this.TableStatus = TableStatus;
        this.NumberOfSeats = NumberOfSeats;
        this.FloorNumber = FloorNumber;
        this.IsDeleted = false;
    }

    // Constructor cho trường hợp lấy dữ liệu từ DB
    public Table(String TableId, String TableStatus, int NumberOfSeats, int FloorNumber) {
        this.TableId = TableId;
        this.TableStatus = TableStatus;
        this.NumberOfSeats = NumberOfSeats;
        this.FloorNumber = FloorNumber;
        this.IsDeleted = false;
    }

    // Getters and Setters
    public String getTableId() {
        return TableId;
    }

    public void setTableId(String TableId) {
        this.TableId = TableId;
    }

    public String getTableStatus() {
        return TableStatus;
    }

    public void setTableStatus(String TableStatus) {
        this.TableStatus = TableStatus;
    }

    public int getNumberOfSeats() {
        return NumberOfSeats;
    }

    public void setNumberOfSeats(int NumberOfSeats) {
        this.NumberOfSeats = NumberOfSeats;
    }

    public int getFloorNumber() {
        return FloorNumber;
    }

    public void setFloorNumber(int FloorNumber) {
        this.FloorNumber = FloorNumber;
    }

    public boolean isIsDeleted() {
        return IsDeleted;
    }

    public void setIsDeleted(boolean IsDeleted) {
        this.IsDeleted = IsDeleted;
    }

    public boolean isHasOrder() {
        return hasOrder;
    }

    public void setHasOrder(boolean hasOrder) {
        this.hasOrder = hasOrder;
    }

    public Order getOrder() {
        return order;
    }

    public void setOrder(Order order) {
        this.order = order;
    }
    
}