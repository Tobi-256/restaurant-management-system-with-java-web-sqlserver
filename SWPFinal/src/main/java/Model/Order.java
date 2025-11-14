/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Model;

/**
 *
 * @author HuynhPhuBinh
 */

import java.util.Date;
import java.util.List;

public class Order {
    private String orderId;  // Changed to String to match NVARCHAR(50) in DB
    private String userId;   // Changed to String to match NVARCHAR(50) in DB
    private String customerId; // Changed to String to match NVARCHAR(50) in DB, nullable
    private Date orderDate;
    private String orderStatus;
    private String orderType;
    private String orderDescription;
    private String couponId;  // Changed to String to match NVARCHAR(50) in DB, nullable
    private String tableId;   // Changed to String to match NVARCHAR(50) in DB, nullable
    private List<OrderDetail> orderDetails; // Keep this
    private String customerPhone;
    private String customerName;
    private double total;
    private double finalPrice;

    // Constructors (Optional, but good practice)

    public Order() {
    }

    public Order(String orderId, String userId, String customerId, Date orderDate, String orderStatus, String orderType, String orderDescription, String couponId, String tableId, List<OrderDetail> orderDetails, String customerPhone, String customerName, double total, double finalPrice) {
        this.orderId = orderId;
        this.userId = userId;
        this.customerId = customerId;
        this.orderDate = orderDate;
        this.orderStatus = orderStatus;
        this.orderType = orderType;
        this.orderDescription = orderDescription;
        this.couponId = couponId;
        this.tableId = tableId;
        this.orderDetails = orderDetails;
        this.customerPhone = customerPhone;
        this.customerName = customerName;
        this.total = total;
        this.finalPrice = finalPrice;
    }

    public String getOrderId() {
        return orderId;
    }

    public void setOrderId(String orderId) {
        this.orderId = orderId;
    }

    public String getUserId() {
        return userId;
    }

    public void setUserId(String userId) {
        this.userId = userId;
    }

    public String getCustomerId() {
        return customerId;
    }

    public void setCustomerId(String customerId) {
        this.customerId = customerId;
    }

    public Date getOrderDate() {
        return orderDate;
    }

    public void setOrderDate(Date orderDate) {
        this.orderDate = orderDate;
    }

    public String getOrderStatus() {
        return orderStatus;
    }

    public void setOrderStatus(String orderStatus) {
        this.orderStatus = orderStatus;
    }

    public String getOrderType() {
        return orderType;
    }

    public void setOrderType(String orderType) {
        this.orderType = orderType;
    }

    public String getOrderDescription() {
        return orderDescription;
    }

    public void setOrderDescription(String orderDescription) {
        this.orderDescription = orderDescription;
    }

    public String getCouponId() {
        return couponId;
    }

    public void setCouponId(String couponId) {
        this.couponId = couponId;
    }

    public String getTableId() {
        return tableId;
    }

    public void setTableId(String tableId) {
        this.tableId = tableId;
    }

    public List<OrderDetail> getOrderDetails() {
        return orderDetails;
    }

    public void setOrderDetails(List<OrderDetail> orderDetails) {
        this.orderDetails = orderDetails;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public double getTotal() {
        return total;
    }

    public void setTotal(double total) {
        this.total = total;
    }

    public double getFinalPrice() {
        return finalPrice;
    }

    public void setFinalPrice(double finalPrice) {
        this.finalPrice = finalPrice;
    }

    
}