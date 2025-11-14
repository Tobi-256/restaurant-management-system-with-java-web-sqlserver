package Model;

/**
 *
 * @author HuynhPhuBinh
 */
public class Customer {

    private String customerId; // Changed to String
    private String customerName;
    private String customerPhone;
    private int numberOfPayment;
    private boolean IsDeleted;

    public Customer() {
    }

    public Customer(String customerId, String customerName, String customerPhone, int numberOfPayment, boolean IsDeleted) { // Changed to String
        this.customerId = customerId;
        this.customerName = customerName;
        this.customerPhone = customerPhone;
        this.numberOfPayment = numberOfPayment;
        this.IsDeleted = IsDeleted;
    }

    public String getCustomerId() { // Changed to String
        return customerId;
    }

    public void setCustomerId(String customerId) { // Changed to String
        this.customerId = customerId;
    }

    public String getCustomerName() {
        return customerName;
    }

    public void setCustomerName(String customerName) {
        this.customerName = customerName;
    }

    public String getCustomerPhone() {
        return customerPhone;
    }

    public void setCustomerPhone(String customerPhone) {
        this.customerPhone = customerPhone;
    }

    public int getNumberOfPayment() {
        return numberOfPayment;
    }

    public void setNumberOfPayment(int numberOfPayment) {
        this.numberOfPayment = numberOfPayment;
    }

    public boolean isIsDeleted() {
        return IsDeleted;
    }

    public void setIsDeleted(boolean IsDeleted) {
        this.IsDeleted = IsDeleted;
    }
    
}
