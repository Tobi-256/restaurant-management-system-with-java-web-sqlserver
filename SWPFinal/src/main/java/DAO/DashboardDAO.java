package DAO;

import DB.DBContext;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DashboardDAO {

    private static final Logger LOGGER = Logger.getLogger(DashboardDAO.class.getName());
    private static final SimpleDateFormat DATE_FORMAT = new SimpleDateFormat("yyyy-MM-dd");

    // Lấy doanh thu hôm nay
    public double getTodayRevenue() {
        String sql = "SELECT SUM(TotalRevenue) as TodayRevenue FROM Revenue WHERE OrderDate = CAST(GETDATE() AS DATE)";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble("TodayRevenue");
            }
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error getting today's revenue", e);
        }
        return 0.0;
    }

    // Lấy số đơn hàng mới hôm nay
    public int getNewOrdersCount() {
        String sql = "SELECT COUNT(*) as NewOrders FROM [Order] WHERE OrderDate >= CAST(GETDATE() AS DATE) AND OrderStatus = 'Pending'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("NewOrders");
            }
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error getting new orders count", e);
        }
        return 0;
    }

    // Lấy số món ăn đang bán
    public int getDishesForSaleCount() {
        String sql = "SELECT COUNT(*) as Dishes FROM Dish WHERE DishStatus = 'Available'";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("Dishes");
            }
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error getting dishes for sale count", e);
        }
        return 0;
    }

    // Lấy số nhân viên đang hoạt động
    public int getActiveEmployeesCount() {
        String sql = "SELECT COUNT(*) as Employees FROM Account WHERE IsDeleted = 0";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("Employees");
            }
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error getting active employees count", e);
        }
        return 0;
    }

    // Lấy dữ liệu doanh thu 7 ngày gần nhất
    public Map<String, Double> getWeeklyRevenue() {
        Map<String, Double> revenueData = new HashMap<>();
        String sql = "SELECT OrderDate, SUM(TotalRevenue) as Revenue " +
                     "FROM Revenue " +
                     "WHERE OrderDate >= DATEADD(day, -6, CAST(GETDATE() AS DATE)) " +
                     "GROUP BY OrderDate " +
                     "ORDER BY OrderDate ASC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String date = DATE_FORMAT.format(rs.getDate("OrderDate"));
                double revenue = rs.getDouble("Revenue");
                revenueData.put(date, revenue);
            }
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error getting weekly revenue", e);
        }
        return revenueData;
    }

    // Lấy danh sách đơn hàng gần đây
    public List<Map<String, Object>> getRecentOrders() {
        List<Map<String, Object>> orders = new ArrayList<>();
        String sql = "SELECT o.OrderId, c.CustomerName, o.OrderDate, o.OrderStatus, " +
                     "SUM(od.Subtotal) as TotalAmount " +
                     "FROM [Order] o " +
                     "LEFT JOIN Customer c ON o.CustomerId = c.CustomerId " +
                     "JOIN OrderDetail od ON o.OrderId = od.OrderId " +
                     "GROUP BY o.OrderId, c.CustomerName, o.OrderDate, o.OrderStatus " +
                     "ORDER BY o.OrderDate DESC " +
                     "OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Map<String, Object> order = new HashMap<>();
                order.put("OrderId", rs.getString("OrderId"));
                order.put("CustomerName", rs.getString("CustomerName") != null ? rs.getString("CustomerName") : "Unknown");
                order.put("TotalAmount", rs.getDouble("TotalAmount"));
                order.put("OrderStatus", rs.getString("OrderStatus"));
                order.put("OrderDate", rs.getTimestamp("OrderDate"));
                orders.add(order);
            }
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error getting recent orders", e);
        }
        return orders;
    }

    // Lấy top 5 món ăn bán chạy nhất
    public Map<String, Integer> getTopSellingDishes() {
        Map<String, Integer> topDishes = new HashMap<>();
        String sql = "SELECT TOP 5 d.DishName, SUM(od.Quantity) as TotalQuantity " +
                     "FROM OrderDetail od " +
                     "JOIN Dish d ON od.DishId = d.DishId " +
                     "GROUP BY d.DishName " +
                     "ORDER BY TotalQuantity DESC";
        try (Connection conn = DBContext.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                String dishName = rs.getString("DishName");
                int quantity = rs.getInt("TotalQuantity");
                topDishes.put(dishName, quantity);
            }
        } catch (SQLException | ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "Error getting top selling dishes", e);
        }
        return topDishes;
    }
}