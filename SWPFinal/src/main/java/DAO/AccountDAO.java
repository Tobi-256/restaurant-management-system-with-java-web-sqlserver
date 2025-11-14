package DAO;

import Model.Account;
import DB.DBContext;
import jakarta.mail.*;
import jakarta.mail.internet.*;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;
import java.util.Random;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AccountDAO {

    private Connection conn;
    private String sql;
    private static final Logger LOGGER = Logger.getLogger(AccountDAO.class.getName());

    private static final String FROM_EMAIL = "tastyrestaurantg3@gmail.com"; // Replace with your email
    private static final String PASSWORD = "xdwa hgtj frfs cnng"; // Replace with App Password if using Gmail

    public AccountDAO() throws ClassNotFoundException, SQLException {
        conn = DBContext.getConnection();
    }

    public String generateConfirmationCode() {
        Random random = new Random();
        int code = 100000 + random.nextInt(900000);
        return String.valueOf(code);
    }

    public void sendConfirmationCodeEmail(String toEmail, String code) throws MessagingException {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Account Registration Confirmation Code");
            message.setText("Your confirmation code is: " + code + "\nThis code is valid for 3 minutes.");
            Transport.send(message);
            LOGGER.info("Confirmation email sent successfully to: " + toEmail);
        } catch (MessagingException e) {
            LOGGER.log(Level.SEVERE, "Failed to send confirmation email to: " + toEmail, e);
            String errorMessage = e.getMessage();
            if (errorMessage != null && (errorMessage.contains("Invalid Addresses") || errorMessage.contains("550"))) {
                throw new MessagingException("Invalid email address");
            } else if (errorMessage != null && (errorMessage.contains("Authentication failed") || errorMessage.contains("535"))) {
                throw new MessagingException("SMTP authentication failed");
            } else if (errorMessage != null && (errorMessage.contains("Connection refused") || errorMessage.contains("timeout"))) {
                throw new MessagingException("Unable to connect to SMTP server");
            }
            throw new MessagingException("Unknown error: " + e.getMessage());
        }
    }

    public boolean isEmailExists(String email, String excludeUserId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT UserEmail FROM Account WHERE UserEmail = ? AND (UserId != ? OR ? IS NULL)";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setString(2, excludeUserId);
            ps.setString(3, excludeUserId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        }
    }

    public boolean isPhoneExists(String phone, String excludeUserId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT UserPhone FROM Account WHERE UserPhone = ? AND (UserId != ? OR ? IS NULL)";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, phone);
            ps.setString(2, excludeUserId);
            ps.setString(3, excludeUserId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking phone existence for: " + phone, e);
            throw e;
        }
    }

    public boolean isIdentityCardExists(String identityCard, String excludeUserId) throws SQLException, ClassNotFoundException {
        String sql = "SELECT IdentityCard FROM Account WHERE IdentityCard = ? AND (UserId != ? OR ? IS NULL)";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, identityCard);
            ps.setString(2, excludeUserId);
            ps.setString(3, excludeUserId);
            ResultSet rs = ps.executeQuery();
            return rs.next();
        }
    }

    private String generateUniqueUserId(String userRole) throws SQLException, ClassNotFoundException {
        String prefix;
        switch (userRole.toLowerCase()) {
            case "admin":
                prefix = "AD";
                break;
            case "manager":
                prefix = "MG";
                break;
            case "cashier":
                prefix = "CS";
                break;
            case "waiter":
                prefix = "WT";
                break;
            case "kitchen staff":
                prefix = "KS";
                break;
            default:
                throw new IllegalArgumentException("Invalid user role: " + userRole);
        }

        String sql = "SELECT MAX(UserId) AS MaxId FROM Account WHERE UserId LIKE ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, prefix + "%");
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String maxId = rs.getString("MaxId");
                if (maxId == null) {
                    return prefix + "001";
                }
                int number = Integer.parseInt(maxId.substring(2)) + 1;
                return prefix + String.format("%03d", number);
            }
            return prefix + "001";
        }
    }

    public int createAccount(Account account, String confirmationToken) throws ClassNotFoundException, SQLException {
        if (isEmailExists(account.getUserEmail(), null)) {
            LOGGER.warning("createAccount - Email already exists: " + account.getUserEmail());
            return -1;
        }
        if (account.getIdentityCard() != null && !account.getIdentityCard().isEmpty() && isIdentityCardExists(account.getIdentityCard(), null)) {
            LOGGER.warning("createAccount - Identity card already exists: " + account.getIdentityCard());
            return -2;
        }

        String sql = "INSERT INTO Account (UserId, UserEmail, UserPassword, UserName, UserRole, IdentityCard, UserAddress, UserImage, UserPhone, IsDeleted) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DBContext.getConnection(); PreparedStatement ps = con.prepareStatement(sql)) {
            String userId = generateUniqueUserId(account.getUserRole());
            account.setUserId(userId);

            ps.setString(1, userId);
            ps.setString(2, account.getUserEmail());
            ps.setString(3, account.getUserPassword());
            ps.setString(4, account.getUserName());
            ps.setString(5, account.getUserRole());
            ps.setString(6, account.getIdentityCard());
            ps.setString(7, account.getUserAddress());
            ps.setString(8, account.getUserImage());
            ps.setString(9, account.getUserPhone());
            ps.setBoolean(10, false);

            int count = ps.executeUpdate();
            LOGGER.info("createAccount - Account created successfully: " + userId);
            return count;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "createAccount - SQLException: ", e);
            throw e;
        }
    }

    public void sendAccountInfoEmail(String toEmail, String username, String password) {
        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");

        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(FROM_EMAIL, PASSWORD);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(FROM_EMAIL));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toEmail));
            message.setSubject("Your Account Information");

            String emailContent = "Hello,\n\n"
                    + "Your account has been successfully created. Below is your login information:\n"
                    + "Email: " + toEmail + "\n"
                    + "Username: " + username + "\n"
                    + "Password: " + password + "\n\n"
                    + "Please log in to use the service.\n\n"
                    + "Best regards,\nTasty Restaurant Team";
            message.setText(emailContent);
            Transport.send(message);
            LOGGER.info("Account information email sent successfully to: " + toEmail);
        } catch (MessagingException e) {
            LOGGER.log(Level.SEVERE, "Error sending account information email to: " + toEmail, e);
        }
    }

    public Account login(String email, String password) throws ClassNotFoundException, SQLException {
        String sql = "SELECT UserId, UserEmail, UserPassword, UserName, UserRole, IdentityCard, UserAddress, UserImage, IsDeleted "
                + "FROM Account WHERE UserEmail = ? AND UserPassword = ? AND IsDeleted = 0";
        try (Connection conn = DBContext.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email);
            pstmt.setString(2, password);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                Account account = new Account();
                account.setUserId(rs.getString("UserId"));
                account.setUserEmail(rs.getString("UserEmail"));
                account.setUserPassword(rs.getString("UserPassword"));
                account.setUserName(rs.getString("UserName"));
                account.setUserRole(rs.getString("UserRole"));
                account.setIdentityCard(rs.getString("IdentityCard"));
                account.setUserAddress(rs.getString("UserAddress"));
                account.setUserImage(rs.getString("UserImage"));
                account.setIsDeleted(rs.getBoolean("IsDeleted"));
                LOGGER.info("Login successful for user: " + email);
                return account;
            } else {
                LOGGER.info("Login failed for user: " + email + " - Account does not exist or has been deleted.");
                return null;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error during login process for user: " + email, e);
            throw e;
        }
    }

    public List<Account> getAllAccount() throws SQLException, ClassNotFoundException {
        List<Account> accounts = new ArrayList<>();
        String sql = "SELECT UserId, UserEmail, UserPassword, UserName, UserRole, IdentityCard, UserAddress, UserPhone, UserImage, IsDeleted "
                + "FROM Account";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Account account = new Account();
                account.setUserId(rs.getString("UserId"));
                account.setUserEmail(rs.getString("UserEmail"));
                account.setUserPassword(rs.getString("UserPassword"));
                account.setUserName(rs.getString("UserName"));
                account.setUserRole(rs.getString("UserRole"));
                account.setIdentityCard(rs.getString("IdentityCard"));
                account.setUserAddress(rs.getString("UserAddress"));
                account.setUserPhone(rs.getString("UserPhone"));
                account.setUserImage(rs.getString("UserImage"));
                account.setIsDeleted(rs.getBoolean("IsDeleted"));
                accounts.add(account);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error retrieving all accounts", ex);
            throw ex;
        }
        return accounts;
    }

    public Account getAccountById(String id, boolean fullDetails) throws SQLException, ClassNotFoundException {
        Account obj = null;
        String sql = fullDetails
                ? "SELECT UserId, UserEmail, UserPassword, UserName, UserRole, UserPhone, IdentityCard, UserAddress, UserImage FROM Account WHERE UserId = ?"
                : "SELECT UserId, UserRole, UserEmail, UserName, UserPhone FROM Account WHERE UserId = ?";
        try (Connection con = DBContext.getConnection(); PreparedStatement pst = con.prepareStatement(sql)) {
            pst.setString(1, id);
            ResultSet rs = pst.executeQuery();
            if (rs.next()) {
                obj = new Account();
                obj.setUserId(rs.getString("UserId"));
                obj.setUserPhone(rs.getString("UserPhone"));
                if (fullDetails) {
                    obj.setUserEmail(rs.getString("UserEmail"));
                    obj.setUserPassword(rs.getString("UserPassword"));
                    obj.setUserName(rs.getString("UserName"));
                    obj.setIdentityCard(rs.getString("IdentityCard"));
                    obj.setUserAddress(rs.getString("UserAddress"));
                    obj.setUserImage(rs.getString("UserImage"));
                }
                obj.setUserRole(rs.getString("UserRole"));
            }
        }
        return obj;
    }

    public Account getAccountById(String userId) throws SQLException, ClassNotFoundException {
        String query = "SELECT UserName FROM Account WHERE UserId = ? AND IsDeleted = 0";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(query)) {
            ps.setString(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Account account = new Account();
                    account.setUserName(rs.getString("UserName"));
                    return account;
                }
            }
        }
        return null;
    }

    private String getPrefixForRole(String userRole) {
        switch (userRole) {
            case "Admin":
                return "AD";
            case "Manager":
                return "MA";
            case "Waiter":
                return "WA";
            case "Cashier":
                return "CA";
            case "Kitchen staff":
                return "KS";
            default:
                return "EM";
        }
    }

    public int updateAccount(String oldId, Account newInfo) throws SQLException, ClassNotFoundException {
        int count = 0;
        Connection con = null;
        PreparedStatement pstAccount = null;

        try {
            con = DBContext.getConnection();
            con.setAutoCommit(false);

            Account existingAccount = getAccountById(oldId, false);

            if (!existingAccount.getUserRole().equals(newInfo.getUserRole())) {
                String newUserId = generateUniqueUserId(newInfo.getUserRole());
                newInfo.setUserId(newUserId);
            } else {
                newInfo.setUserId(oldId);
            }

            if (!newInfo.getUserEmail().equals(existingAccount.getUserEmail()) && isEmailExists(newInfo.getUserEmail(), oldId)) {
                LOGGER.warning("updateAccount - Email already exists: " + newInfo.getUserEmail());
                return -1;
            }

            if (newInfo.getIdentityCard() != null && !newInfo.getIdentityCard().isEmpty()
                    && !newInfo.getIdentityCard().equals(existingAccount.getIdentityCard())
                    && isIdentityCardExists(newInfo.getIdentityCard(), oldId)) {
                LOGGER.warning("updateAccount - Identity card already exists: " + newInfo.getIdentityCard());
                return -2;
            }

            sql = "UPDATE Account SET UserId=?, UserEmail=?, UserPassword=?, UserName=?, UserRole=?, IdentityCard=?, UserAddress=?, UserImage=?, UserPhone=?, IsDeleted=? WHERE UserId=?";
            pstAccount = con.prepareStatement(sql);
            pstAccount.setString(1, newInfo.getUserId());
            pstAccount.setString(2, newInfo.getUserEmail());
            pstAccount.setString(3, newInfo.getUserPassword());
            pstAccount.setString(4, newInfo.getUserName());
            pstAccount.setString(5, newInfo.getUserRole());
            pstAccount.setString(6, newInfo.getIdentityCard());
            pstAccount.setString(7, newInfo.getUserAddress());
            pstAccount.setString(8, newInfo.getUserImage());
            pstAccount.setString(9, newInfo.getUserPhone());
            pstAccount.setBoolean(10, newInfo.isIsDeleted());
            pstAccount.setString(11, oldId);

            count = pstAccount.executeUpdate();
            con.commit();
            LOGGER.info("updateAccount - Account updated successfully, affected rows: " + count);
        } catch (SQLException ex) {
            if (con != null) {
                con.rollback();
            }
            LOGGER.log(Level.SEVERE, "updateAccount - SQLException: ", ex);
            throw ex;
        } finally {
            if (pstAccount != null) {
                pstAccount.close();
            }
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
        return count;
    }

    public int deleteAccount(String id) {
        int count = 0;
        try {
            sql = "UPDATE Account SET IsDeleted = 1 WHERE UserId = ?";
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setString(1, id);
            count = pst.executeUpdate();
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error deleting account", ex);
        }
        return count;
    }

    public int restoreAccount(String id) {
        int count = 0;
        try {
            sql = "UPDATE Account SET IsDeleted = 0 WHERE UserId = ?";
            PreparedStatement pst = conn.prepareStatement(sql);
            pst.setString(1, id);
            count = pst.executeUpdate();
            LOGGER.info("restoreAccount - Account " + id + " restored successfully, affected rows: " + count);
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error restoring account", ex);
        }
        return count;
    }

    public List<String> getAllRoles() {
        List<String> roles = new ArrayList<>();
        String sql = "SELECT DISTINCT UserRole FROM Account";
        try (Connection connection = DBContext.getConnection(); PreparedStatement ps = connection.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                roles.add(rs.getString("UserRole"));
            }
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving all roles", e);
            return null;
        }
        return roles;
    }

    public List<String> getUserIdsByRole(String role) {
        List<String> userIds = new ArrayList<>();
        String sql = "SELECT UserId FROM Account WHERE UserRole = ?";
        try (Connection connection = DBContext.getConnection(); PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, role);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    userIds.add(rs.getString("UserId"));
                }
            }
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving user IDs by role", e);
            return null;
        }
        return userIds;
    }

    public List<Account> getActiveAccounts() throws SQLException, ClassNotFoundException {
        List<Account> accounts = new ArrayList<>();
        String sql = "SELECT UserId, UserEmail, UserPassword, UserName, UserRole, IdentityCard, UserAddress, UserPhone, UserImage, IsDeleted "
                + "FROM Account WHERE IsDeleted = 0";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Account account = new Account();
                account.setUserId(rs.getString("UserId"));
                account.setUserEmail(rs.getString("UserEmail"));
                account.setUserPassword(rs.getString("UserPassword"));
                account.setUserName(rs.getString("UserName"));
                account.setUserRole(rs.getString("UserRole"));
                account.setIdentityCard(rs.getString("IdentityCard"));
                account.setUserAddress(rs.getString("UserAddress"));
                account.setUserPhone(rs.getString("UserPhone"));
                account.setUserImage(rs.getString("UserImage"));
                account.setIsDeleted(rs.getBoolean("IsDeleted"));
                accounts.add(account);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error retrieving active accounts", ex);
            throw ex;
        }
        return accounts;
    }

    public List<Account> getInactiveAccounts() throws SQLException, ClassNotFoundException {
        List<Account> accounts = new ArrayList<>();
        String sql = "SELECT UserId, UserEmail, UserPassword, UserName, UserRole, IdentityCard, UserAddress, UserPhone, UserImage, IsDeleted "
                + "FROM Account WHERE IsDeleted = 1";
        try (Connection conn = DBContext.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Account account = new Account();
                account.setUserId(rs.getString("UserId"));
                account.setUserEmail(rs.getString("UserEmail"));
                account.setUserPassword(rs.getString("UserPassword"));
                account.setUserName(rs.getString("UserName"));
                account.setUserRole(rs.getString("UserRole"));
                account.setIdentityCard(rs.getString("IdentityCard"));
                account.setUserAddress(rs.getString("UserAddress"));
                account.setUserPhone(rs.getString("UserPhone"));
                account.setUserImage(rs.getString("UserImage"));
                account.setIsDeleted(rs.getBoolean("IsDeleted"));
                accounts.add(account);
            }
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error retrieving inactive accounts", ex);
            throw ex;
        }
        return accounts;
    }
}
