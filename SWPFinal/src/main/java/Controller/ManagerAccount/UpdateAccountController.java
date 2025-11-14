package Controller.ManagerAccount;

import DAO.AccountDAO;
import Model.Account;
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
import java.util.UUID;

@WebServlet("/UpdateAccount")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,
        maxFileSize = 1024 * 1024 * 50,
        maxRequestSize = 1024 * 1024 * 100
)
public class UpdateAccountController extends HttpServlet {

    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json;charset=UTF-8");
        PrintWriter out = response.getWriter();
        StringBuilder jsonResponse = new StringBuilder();

        try {
            String UserId = request.getParameter("UserIdHidden");
            String UserEmail = request.getParameter("UserEmail");
            String UserPassword = request.getParameter("UserPassword");
            String UserName = request.getParameter("UserName");
            String UserRole = request.getParameter("UserRole");
            String IdentityCard = request.getParameter("IdentityCard");
            String UserAddress = request.getParameter("UserAddress");
            String UserPhone = request.getParameter("UserPhone");
            String oldImagePath = request.getParameter("oldImagePath");

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

                if (oldImagePath != null && !oldImagePath.isEmpty()) {
                    String oldFilePath = getServletContext().getRealPath("/") + oldImagePath;
                    File oldFile = new File(oldFilePath);
                    if (oldFile.exists() && !oldFile.isDirectory()) {
                        oldFile.delete();
                    }
                }
            } else {
                UserImage = oldImagePath; // Giữ nguyên ảnh cũ
            }

            AccountDAO dao = new AccountDAO();
            Account account = new Account(UserId, UserEmail, UserPassword, UserName, UserRole, IdentityCard, UserAddress, UserPhone, UserImage, false);

            Account existingAccount = dao.getAccountById(UserId, false);
            // Kiểm tra email: chỉ báo lỗi nếu email thay đổi và trùng với tài khoản khác
            if (!UserEmail.equals(existingAccount.getUserEmail()) && dao.isEmailExists(UserEmail, UserId)) {
                jsonResponse.append("{\"success\":false,\"field\":\"DetailUserEmail\",\"message\":\"Email already exists for another account.\"}");
            } 
            // Kiểm tra identity card: chỉ báo lỗi nếu identity card thay đổi và trùng với tài khoản khác
            else if (IdentityCard != null && !IdentityCard.isEmpty() && !IdentityCard.equals(existingAccount.getIdentityCard()) && dao.isIdentityCardExists(IdentityCard, UserId)) {
                jsonResponse.append("{\"success\":false,\"field\":\"DetailIdentityCard\",\"message\":\"Identity card/CCCD already exists for another account.\"}");
            } 
//            else if (UserPhone != null && !UserPhone.isEmpty() && dao.isPhoneExists(UserPhone, null)) {
//jsonResponse.append("{\"success\":false,\"field\":\"DetailUserPhone\",\"message\":\"This phone number already exists.\"}");
//                 }
            else {
                int count = dao.updateAccount(UserId, account);
                if (count > 0) {
                    jsonResponse.append("{\"success\":true,\"message\":\"Account updated successfully.\"}");
                } else {
                    jsonResponse.append("{\"success\":false,\"message\":\"An error occurred while updating the account.\"}");
                }
            }

            out.print(jsonResponse.toString());
        } catch (Exception e) {
            jsonResponse.append("{\"success\":false,\"message\":\"Unknown error: ").append(escapeJson(e.getMessage())).append("\"}");
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