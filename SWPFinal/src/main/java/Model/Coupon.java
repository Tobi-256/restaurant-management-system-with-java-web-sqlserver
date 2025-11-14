/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package Model;

import java.math.BigDecimal;
import java.sql.Date;

/**
 *
 * @author DELL-Laptop
 */
public class Coupon {

    private String couponId;
    private BigDecimal discountAmount;
    private Date expirationDate;
    private int timesUsed;
    private int isDeleted;
    private String description;

    public Coupon(String couponId, BigDecimal discountAmount, Date expirationDate, int timesUsed, int isDeleted, String description) {
        this.couponId = couponId;
        this.discountAmount = discountAmount;
        this.expirationDate = expirationDate;
        this.timesUsed = timesUsed;
        this.isDeleted = isDeleted;
        this.description = description;
    }

    public Coupon(String couponId, BigDecimal discountAmount, Date expirationDate, int timesUsed, String description) {
        this.couponId = couponId;
        this.discountAmount = discountAmount;
        this.expirationDate = expirationDate;
        this.timesUsed = timesUsed;
        this.description = description;
    }

    
    public String getCouponId() {
        return couponId;
    }

    public void setCouponId(String couponId) {
        this.couponId = couponId;
    }

    public BigDecimal getDiscountAmount() {
        return discountAmount;
    }

    public void setDiscountAmount(BigDecimal discountAmount) {
        this.discountAmount = discountAmount;
    }

    public Date getExpirationDate() {
        return expirationDate;
    }

    public void setExpirationDate(Date expirationDate) {
        this.expirationDate = expirationDate;
    }

    public int getTimesUsed() {
        return timesUsed;
    }

    public void setTimesUsed(int timesUsed) {
        this.timesUsed = timesUsed;
    }

    public int getIsDeleted() {
        return isDeleted;
    }

    public void setIsDeleted(int isDeleted) {
        this.isDeleted = isDeleted;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    
}