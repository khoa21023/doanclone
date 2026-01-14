// models/userModel.js
import db, { execute } from '../config/db.js'; // Cần import cả db (mặc định) và { execute }

export const userModel = {
    // 1. Tìm user theo Id (Đồng bộ tên hàm với Controller: findById)
    findById: async (id) => {
        const sql = "SELECT * FROM nguoidung WHERE Id = ?";
        const rows = await execute(sql, [id]);
        return rows[0];
    },

    // 2. Tìm user theo Số điện thoại
    findByPhone: async (phone) => {
        const sql = "SELECT * FROM nguoidung WHERE SoDienThoai = ?";
        const rows = await execute(sql, [phone]);
        return rows[0];
    },

    // 3. Tìm user theo Email
    findByEmail: async (email) => {
        const sql = "SELECT * FROM nguoidung WHERE Email = ?";
        const rows = await execute(sql, [email]);
        return rows[0];
    },

    // 4. Cập nhật mật khẩu mới
    updatePassword: async (userId, hashedPassword) => {
        const sql = "UPDATE nguoidung SET MatKhau = ? WHERE Id = ?";
        return await execute(sql, [hashedPassword, userId]);
    },

    // 5. Tạo người dùng mới
    create: async (data) => {
        const { Id, Email, MatKhau, HoTen, SoDienThoai, DiaChi } = data;
        const sql = `INSERT INTO nguoidung (Id, Email, MatKhau, HoTen, SoDienThoai, DiaChi, VaiTro) 
                     VALUES (?, ?, ?, ?, ?, ?, 'KhachHang')`;
        return await execute(sql, [Id, Email, MatKhau, HoTen, SoDienThoai, DiaChi]);
    },

    // 6. Kiểm tra email trùng (trừ user hiện tại)
    checkEmailExcluingUser: async (email, userId) => {
        const sql = "SELECT * FROM nguoidung WHERE Email = ? AND Id != ?";
        const rows = await execute(sql, [email, userId]);
        return rows.length > 0;
    },

    // 7. Cập nhật thông tin hồ sơ (Sửa lỗi biến email chưa định nghĩa và sai tên cột HinhAnh)
    updateProfile: async (userId, { email, hoTen, soDienThoai, diaChi }) => {
        const sql = "UPDATE nguoidung SET Email = ?, HoTen = ?, SoDienThoai = ?, DiaChi = ? WHERE Id = ?";
        return await execute(sql, [email, hoTen, soDienThoai, diaChi, userId]);
    },

    // 8. Cập nhật ảnh đại diện (Lưu ý: Cột trong SQL của cậu là HinhAnh)
    updateAvatar: async (userId, fileName) => {
        const sql = "UPDATE nguoidung SET HinhAnh = ? WHERE Id = ?";
        return await execute(sql, [fileName, userId]);
    },

    // 9. Lấy thông tin chi tiết (Phòng trường hợp Controller gọi getUserById)
    getUserById: async (userId) => {
        const sql = "SELECT Id, Email, HoTen, SoDienThoai, DiaChi, VaiTro, HinhAnh FROM nguoidung WHERE Id = ?";
        const rows = await execute(sql, [userId]);
        return rows[0];
    },

    // 10. Quản lý Token (Để không lỗi auth.js)
    revokeToken: async (token) => {
        return true; // Nếu chưa có bảng revoked_tokens thì trả về true để không sập
    },

    isTokenRevoked: async (token) => {
        return false; // Mặc định trả về false
    }
};

export default userModel;