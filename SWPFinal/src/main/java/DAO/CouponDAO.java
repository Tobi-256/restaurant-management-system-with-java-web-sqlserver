/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package DAO;

import Model.Coupon;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import DB.DBContext;
import java.math.BigDecimal;
import java.sql.Connection;
import java.text.DecimalFormat;
import java.text.NumberFormat;
import java.util.Locale;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 *
 * @author DELL-Laptop
 */
public class CouponDAO extends DB.DBContext {

    public List<Coupon> getAllCoupon() {
        String sql = "SELECT couponId, discountAmount, expirationDate, timesUsed,description FROM Coupon Where isDeleted = 0"; // Liệt kê rõ ràng các cột
        List<Coupon> coupons = new ArrayList<>();
        try (PreparedStatement st = getConnection().prepareStatement(sql)) {
            try (ResultSet rs = st.executeQuery()) {
                while (rs.next()) {
                    Coupon coupon = new Coupon( // Tạo đối tượng Coupon với đúng thứ tự tham số
                            rs.getString("couponId"),
                            rs.getBigDecimal("discountAmount"),
                            rs.getDate("expirationDate"),
                            rs.getInt("timesUsed"),
                            rs.getString("description")
                    );
//                    if (coupon.getDiscountAmount().compareTo(BigDecimal.valueOf(100)) > 0) {
//                        // Định dạng tiền Việt Nam
//                        NumberFormat currencyFormat = NumberFormat.getNumberInstance(Locale.forLanguageTag("vi-VN"));
//                        coupon.setDiscountAmount(currencyFormat.format(coupon.getDiscountAmount()) + "đ");
//                    } else {
//                        // Định dạng phần trăm
//                        DecimalFormat percentFormat = new DecimalFormat("0.##%"); // Hoặc "0.00%" nếu bạn muốn 2 chữ số thập phân
//                        coupon.setDiscountAmount = percentFormat.format(coupon.getDiscountAmount().divide(BigDecimal.valueOf(100))); // Chia cho 100 để chuyển thành phần trăm
//                    }
                    coupons.add(coupon);
                }
                System.out.print("kkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkkk");
                return coupons;
            }

        } catch (SQLException | ClassNotFoundException e) { // Bắt cả 2 loại Exception có thể xảy ra
            System.err.println("Lỗi khi truy vấn tất cả Coupon: " + e.getMessage()); // Sử dụng System.err cho lỗi
            e.printStackTrace(); // In stack trace để debug dễ hơn
        }
        return null; // Trả về null khi có lỗi hoặc không có Coupon nào
    }

    public String generateNextCouponId() throws SQLException, ClassNotFoundException {
        String lastCouponId = getLastCouponIdFromDB();
        int nextNumber = 1; // Số bắt đầu nếu chưa có coupon nào

        if (lastCouponId != null && !lastCouponId.isEmpty()) {
            try {
                String numberPart = lastCouponId.substring(2); // Loại bỏ "CP"
                nextNumber = Integer.parseInt(numberPart) + 1;
            } catch (NumberFormatException e) {
                // Xử lý lỗi nếu phần số không đúng định dạng (ví dụ: log lỗi hoặc ném exception)
                System.err.println("Lỗi định dạng CouponId cuối cùng: " + lastCouponId);
                // Trong trường hợp lỗi định dạng, vẫn nên tạo mã mới bắt đầu từ CP001 để đảm bảo tiếp tục hoạt động
                return "CP001";
            }
        }

        // Định dạng số thành chuỗi 3 chữ số (ví dụ: 1 -> "001", 10 -> "010", 100 -> "100")
        String numberStr = String.format("%03d", nextNumber);
        return "CO" + numberStr; // **Sửa thành "CP" thay vì "CO"**
    }

    private String getLastCouponIdFromDB() throws SQLException, ClassNotFoundException {
        String lastCouponId = null;
        // **Sửa câu SQL cho đúng tên bảng và cột, và dùng TOP 1 cho SQL Server**
        String sql = "SELECT TOP 1 CouponId FROM [db1].[dbo].[Coupon] ORDER BY CouponId DESC";
        Connection connection = null; // Khai báo connection để quản lý đóng kết nối trong finally
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;

        try {
            connection = getConnection(); // Gọi phương thức getConnection() để lấy Connection - **Cần đảm bảo getConnection() được implement đúng**
            preparedStatement = connection.prepareStatement(sql);
            resultSet = preparedStatement.executeQuery();

            if (resultSet.next()) {
                lastCouponId = resultSet.getString("CouponId"); // **Sửa thành "CouponId" cho đúng tên cột**
            }
        } catch (SQLException e) {
            e.printStackTrace(); // In lỗi hoặc xử lý lỗi kết nối database
            throw e; // Re-throw để servlet xử lý nếu cần
        } finally {
            // Đóng resources trong finally block để đảm bảo giải phóng kết nối và resources
            if (resultSet != null) {
                try {
                    resultSet.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (preparedStatement != null) {
                try {
                    preparedStatement.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return lastCouponId;
    }

    public void addNewCoupon(Coupon coupon) {
        String sql = "INSERT INTO Coupon (couponId, discountAmount, expirationDate, description) VALUES (?, ?, ?, ?)";
        try (PreparedStatement st = getConnection().prepareStatement(sql)) {
            // In giá trị trước khi set vào PreparedStatement
            System.out.println("Giá trị trước khi thêm vào database:");
            System.out.println("couponId: " + coupon.getCouponId());
            System.out.println("discountAmount: " + coupon.getDiscountAmount());
            System.out.println("expirationDate: " + coupon.getExpirationDate());
            System.out.println("description: " + coupon.getDescription());

            st.setString(1, coupon.getCouponId());
            st.setBigDecimal(2, coupon.getDiscountAmount());
            st.setDate(3, new java.sql.Date(coupon.getExpirationDate().getTime())); // Chuyển java.util.Date sang java.sql.Date
            st.setString(4, coupon.getDescription());

            int rowsInserted = st.executeUpdate();
            if (rowsInserted > 0) {
                System.out.println("Thêm mới Coupon thành công!");
            }
        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Lỗi khi thêm mới Coupon: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void updateCoupon(Coupon coupon) { // Loại bỏ throws Exception không cần thiết, bắt và xử lý bên trong
        String sql = "UPDATE Coupon SET discountAmount = ?, expirationDate = ?, timesUsed = ?,description=? WHERE couponId = ?"; // Sửa thành timeUsed và bỏ isUsed
        try (PreparedStatement st = getConnection().prepareStatement(sql)) { // Try-with-resources

            st.setBigDecimal(1, coupon.getDiscountAmount());
            st.setDate(2, new java.sql.Date(coupon.getExpirationDate().getTime())); // Chuyển java.util.Date sang java.sql.Date
            st.setInt(3, coupon.getTimesUsed()); // Sử dụng timeUsed
            st.setString(4, coupon.getDescription());
            st.setString(5, coupon.getCouponId());

            System.out.println("Giá trị trước khi thêm vào database:");
            System.out.println("couponId: " + coupon.getCouponId());
            System.out.println("discountAmount: " + coupon.getDiscountAmount());
            System.out.println("expirationDate: " + coupon.getExpirationDate());
            System.out.println("description: " + coupon.getDescription());

            int rowsUpdated = st.executeUpdate();
            if (rowsUpdated > 0) {
                System.out.println("Cập nhật Coupon ID = " + coupon.getCouponId() + " thành công!");
            } else {
                System.out.println("Không tìm thấy Coupon ID = " + coupon.getCouponId() + " để cập nhật.");
            }

        } catch (SQLException | ClassNotFoundException e) {
            System.err.println("Lỗi cập nhật Coupon: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void deleteCouponById(String couponId) throws ClassNotFoundException {

        try {
            // Modified to update IsDeleted instead of deleting
            String sql = "UPDATE [Coupon] SET IsDeleted = 1 WHERE couponId=?";
            PreparedStatement st = getConnection().prepareStatement(sql);
            st.setString(1, couponId);
            int rowsUpdated = st.executeUpdate();
            if (rowsUpdated > 0) {
                System.out.println("Delete Success!");
            } else {
                System.out.println("Delte Unsuccess.");
            }

        } catch (SQLException ex) {
            Logger.getLogger(CouponDAO.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    public List<Coupon> getAvailableCoupons() throws SQLException, ClassNotFoundException {
    List<Coupon> coupons = new ArrayList<>();
    String query = "SELECT * FROM Coupon WHERE isDeleted = 0 AND expirationDate > GETDATE()";
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(query);
         ResultSet rs = ps.executeQuery()) {
        System.out.println("Executing query: " + query);
        try (PreparedStatement psDate = conn.prepareStatement("SELECT GETDATE()");
             ResultSet rsDate = psDate.executeQuery()) {
            if (rsDate.next()) {
                System.out.println("Current server date: " + rsDate.getString(1));
            }
        }
        int rowCount = 0;
        while (rs.next()) {
            Coupon coupon = new Coupon(
                rs.getString("couponId"),
                rs.getBigDecimal("discountAmount"),
                rs.getDate("expirationDate"),
                rs.getInt("timesUsed"),
                rs.getInt("isDeleted"),
                rs.getString("description")
            );
            coupons.add(coupon);
            System.out.println("Found coupon: " + coupon.getCouponId() + ", Discount: " + coupon.getDiscountAmount()
                             + ", Expire: " + coupon.getExpirationDate() + ", isDeleted: " + coupon.getIsDeleted());
            rowCount++;
        }
        System.out.println("Total rows fetched: " + rowCount + ", Fetched " + coupons.size() + " available coupons");
    } catch (SQLException e) {
        System.err.println("SQL Error in getAvailableCoupons: " + e.getMessage());
        e.printStackTrace();
        throw e;
    }
    return coupons;
}

public Coupon getCouponById(String couponId) throws SQLException, ClassNotFoundException {
    String query = "SELECT * FROM Coupon WHERE couponId = ? AND isDeleted = 0";
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        ps.setString(1, couponId);
        try (ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                Coupon coupon = new Coupon(
                    rs.getString("couponId"),
                    rs.getBigDecimal("discountAmount"),
                    rs.getDate("expirationDate"),
                    rs.getInt("timesUsed"),
                    rs.getInt("isDeleted"),
                    rs.getString("description")
                );
                System.out.println("Fetched coupon: " + couponId);
                return coupon;
            }
        }
        System.out.println("No coupon found: " + couponId);
        return null;
    }
}

public void incrementTimesUsed(String couponId) throws SQLException, ClassNotFoundException {
    String query = "UPDATE Coupon SET timesUsed = timesUsed + 1 WHERE couponId = ?";
    try (Connection conn = getConnection();
         PreparedStatement ps = conn.prepareStatement(query)) {
        ps.setString(1, couponId);
        int rowsUpdated = ps.executeUpdate();
        if (rowsUpdated > 0) {
            System.out.println("Incremented timesUsed for coupon: " + couponId);
        }
    }
}
}
