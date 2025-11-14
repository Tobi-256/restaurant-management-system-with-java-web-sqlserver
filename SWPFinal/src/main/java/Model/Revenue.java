package Model;

import java.util.Date;

public class Revenue {
    private String revenueId;    // RevenueId NVARCHAR(50)
    private String orderId;      // OrderId NVARCHAR(50)
    private double totalRevenue; // TotalRevenue DECIMAL
    private Date orderDate;      // OrderDate DATE

    public Revenue(String revenueId, String orderId, double totalRevenue, Date orderDate) {
        this.revenueId = revenueId;
        this.orderId = orderId;
        this.totalRevenue = totalRevenue;
        this.orderDate = orderDate;
    }

    // Getter và Setter
    public String getRevenueId() {
        return revenueId;
    }

    public void setRevenueId(String revenueId) {
        this.revenueId = revenueId;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public double getTotalRevenue() {
        return totalRevenue;
    }

    public void setTotalRevenue(double totalRevenue) {
        this.totalRevenue = totalRevenue;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }
}