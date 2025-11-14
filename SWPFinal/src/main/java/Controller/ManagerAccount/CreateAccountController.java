package Controller.ManagerAccount;

import DAO.AccountDAO;
import Model.Account;
import jakarta.mail.MessagingException;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.file.Files;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.sql.Timestamp;
import java.util.UUID;

@WebServlet("/CreateAccount")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 1024 * 1024 * 50,
        maxRequestSize = 1024 * 1024 * 100
)
public class CreateAccountController extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        StringBuilder jsonResponse = new StringBuilder();

        try {
            String action = request.getParameter("action");
            AccountDAO dao = new AccountDAO();

            if ("submitForm".equals(action)) {
                String UserEmail = request.getParameter("UserEmail");
                String UserPassword = request.getParameter("UserPassword");
                String UserName = request.getParameter("UserName");
                String UserRole = request.getParameter("UserRole");
                String IdentityCard = request.getParameter("IdentityCard");
                String UserAddress = request.getParameter("UserAddress");
                String UserPhone = request.getParameter("UserPhone");

                Part filePart = request.getPart("UserImage");
                String UserImage = null;

                if (filePart != null && filePart.getSize() > 0 && filePart.getSubmittedFileName() != null && !filePart.getSubmittedFileName().isEmpty()) {
                    String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
                    String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;

                    String uploadPath = getServletContext().getRealPath("/") + "ManageAccount/account_img";
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        uploadDir.mkdirs();
                    }

                    String filePath = uploadPath + File.separator + uniqueFileName;
                    UserImage = "ManageAccount/account_img/" + uniqueFileName;

                    try (InputStream fileContent = filePart.getInputStream()) {
                        Files.copy(fileContent, Paths.get(filePath), StandardCopyOption.REPLACE_EXISTING);
                    }
                }

                Account account = new Account(UserEmail, UserPassword, UserName, UserRole, IdentityCard, UserAddress, UserPhone, UserImage, false);

                // Kiểm tra email đã tồn tại trong hệ thống
                if (dao.isEmailExists(UserEmail, null)) {
                    jsonResponse.append("{\"success\":false,\"field\":\"UserEmail\",\"message\":\"Email đã tồn tại trong hệ thống.\"}");
                } else if (IdentityCard != null && !IdentityCard.isEmpty() && dao.isIdentityCardExists(IdentityCard, null)) {
                    jsonResponse.append("{\"success\":false,\"field\":\"IdentityCard\",\"message\":\"this phone number alredy exísts.\"}");
                }
                // Kiểm tra số điện thoại
                else if (UserPhone != null && !UserPhone.isEmpty() && dao.isPhoneExists(UserPhone, null)) {
                    jsonResponse.append("{\"success\":false,\"field\":\"UserPhone\",\"message\":\"Số điện thoại đã tồn tại trong hệ thống.\"}");
                }
                else {
                    // Tạo mã xác nhận và thời gian hết hạn
                    String confirmationToken = dao.generateConfirmationCode();
                    Timestamp codeExpiration = new Timestamp(System.currentTimeMillis() + 3 * 60 * 1000); // 3 phút

                    try {
                        dao.sendConfirmationCodeEmail(UserEmail, confirmationToken);
                        account.setConfirmationToken(confirmationToken);
                        account.setCodeExpiration(codeExpiration);
                        request.getSession().setAttribute("tempAccount", account);
                        jsonResponse.append("{\"success\":true,\"message\":\"Mã xác nhận đã được gửi đến email của bạn. Vui lòng nhập mã trong vòng 3 phút để hoàn tất đăng ký.\"}");
                    } catch (MessagingException e) {
                        String errorMessage = "Đã xảy ra lỗi khi gửi email: " + e.getMessage();
                        if (e.getMessage().equals("Invalid email address")) {
                            jsonResponse.append("{\"success\":false,\"field\":\"UserEmail\",\"message\":\"Địa chỉ email không tồn tại.\"}");
                        } else if (e.getMessage().contains("SMTP authentication failed")) {
                            jsonResponse.append("{\"success\":false,\"message\":\"Lỗi máy chủ: Không thể gửi email do vấn đề xác thực.\"}");
                        } else if (e.getMessage().contains("Unable to connect to SMTP server")) {
                            jsonResponse.append("{\"success\":false,\"message\":\"Lỗi máy chủ: Không thể kết nối đến máy chủ email. Vui lòng thử lại sau.\"}");
                        } else {
                            jsonResponse.append("{\"success\":false,\"message\":\"").append(escapeJson(errorMessage)).append("\"}");
                        }
                    }
                }
            } else if ("confirmCode".equals(action)) {
                String confirmationToken = request.getParameter("confirmationCode");
                Account tempAccount = (Account) request.getSession().getAttribute("tempAccount");

                if (tempAccount != null) {
                    if (tempAccount.getConfirmationToken() != null && tempAccount.getConfirmationToken().equals(confirmationToken)) {
                        long currentTime = System.currentTimeMillis();
                        long expirationTime = tempAccount.getCodeExpiration().getTime();
                        if (currentTime <= expirationTime) {
                            int count = dao.createAccount(tempAccount, confirmationToken);
                            if (count > 0) {
                                dao.sendAccountInfoEmail(tempAccount.getUserEmail(), tempAccount.getUserName(), tempAccount.getUserPassword());
                                request.getSession().removeAttribute("tempAccount");
                                jsonResponse.append("{\"success\":true,\"message\":\"Tài khoản đã được tạo thành công. Kiểm tra email để xem chi tiết tài khoản.\"}");
                            } else {
                                jsonResponse.append("{\"success\":false,\"message\":\"Đã xảy ra lỗi khi tạo tài khoản.\"}");
                            }
                        } else {
                            jsonResponse.append("{\"success\":false,\"message\":\"Mã xác nhận đã hết hạn. Vui lòng thử lại.\"}");
                            request.getSession().removeAttribute("tempAccount");
                        }
                    } else {
                        jsonResponse.append("{\"success\":false,\"field\":\"confirmationCode\",\"message\":\"Mã xác nhận không đúng.\"}");
                    }
                } else {
                    jsonResponse.append("{\"success\":false,\"message\":\"Phiên làm việc đã hết hạn. Vui lòng thử lại.\"}");
                }
            }

            out.print(jsonResponse.toString());
        } catch (Exception e) {
            jsonResponse.append("{\"success\":false,\"message\":\"Lỗi không xác định: ").append(escapeJson(e.getMessage())).append("\"}");
            out.print(jsonResponse.toString());
        } finally {
            out.close();
        }
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\").replace("\"", "\\\"").replace("\n", "\\n").replace("\r", "\\r").replace("\t", "\\t");
    }
}