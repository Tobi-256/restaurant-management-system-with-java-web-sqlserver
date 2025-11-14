package Model;

/**
 *
 * @author HuynhPhuBinh
 */
public class OrderDetail {

    private String orderDetailId;
    private String orderId;
    private String dishId;
    private int quantity;
    private double subtotal;
    private String dishName;
    private Integer quantityUsed;

    public OrderDetail() {

    }

    public OrderDetail(String orderDetailId, String orderId, String dishId, int quantity, double subtotal, String dishName, Integer quantityUsed) {
        this.orderDetailId = orderDetailId;
        this.orderId = orderId;
        this.dishId = dishId;
        this.quantity = quantity;
        this.subtotal = subtotal;
        this.dishName = dishName;
        this.quantityUsed = quantityUsed;
    }

    public String getOrderDetailId() {
        return orderDetailId;
    }

    public void setOrderDetailId(String orderDetailId) {
        this.orderDetailId = orderDetailId;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getDishId() {
        return dishId;
    }

    public void setDishId(String dishId) {
        this.dishId = dishId;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public double getSubtotal() {
        return subtotal;
    }

    public String getDishName() {
        return dishName;
    }

    public void setDishName(String dishName) {
        this.dishName = dishName;
    }

    public Integer getQuantityUsed() {
        return quantityUsed;
    }

    public void setQuantityUsed(Integer quantityUsed) {
        this.quantityUsed = quantityUsed;
    }

    public void setSubtotal(double subtotal) {
        this.subtotal = subtotal;
    }

}