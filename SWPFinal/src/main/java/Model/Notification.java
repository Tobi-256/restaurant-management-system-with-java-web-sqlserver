package Model;

import java.util.Date;

public class Notification {

    private int NotificationId;          // NotificationId
    private String UserId;              // UserId (sửa từ userId)
    private String NotificationContent; // NotificationContent
    private Date NotificationCreateAt;  // NotificationCreateAt
    private String UserRole;            // UserRole
    private String UserName;            // UserName

    // Constructor mặc định
    public Notification() {
    }

    // Constructor đầy đủ
    public Notification(int NotificationId, String UserId, String NotificationContent, Date NotificationCreateAt, String UserRole, String UserName) {
        this.NotificationId = NotificationId;
        this.UserId = UserId;
        this.NotificationContent = NotificationContent;
        this.NotificationCreateAt = NotificationCreateAt;
        this.UserRole = UserRole;
        this.UserName = UserName;
    }

    // Getter và Setter
    public int getNotificationId() {
        return NotificationId;
    }

    public void setNotificationId(int NotificationId) {
        this.NotificationId = NotificationId;
    }

    public String getUserId() {
        return UserId;
    }

    public void setUserId(String UserId) {
        this.UserId = UserId;
    }

    public String getNotificationContent() {
        return NotificationContent;
    }

    public void setNotificationContent(String NotificationContent) {
        this.NotificationContent = NotificationContent;
    }

    public Date getNotificationCreateAt() {
        return NotificationCreateAt;
    }

    public void setNotificationCreateAt(Date NotificationCreateAt) {
        this.NotificationCreateAt = NotificationCreateAt;
    }

    public String getUserRole() {
        return UserRole;
    }

    public void setUserRole(String UserRole) {
        this.UserRole = UserRole;
    }

    public String getUserName() {
        return UserName;
    }

    public void setUserName(String UserName) {
        this.UserName = UserName;
    }
}
