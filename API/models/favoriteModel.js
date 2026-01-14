import db from '../config/db.js';

const favoriteModel = {
    // 1. Lấy danh sách: JOIN với bảng sanpham để lấy thông tin chi tiết
    getFavoritesByUserId: async (userId) => {
        const sql = `
            SELECT sp.*, yt.NgayThem 
            FROM yeuthich yt
            JOIN sanpham sp ON yt.SanPhamId = sp.Id
            WHERE yt.NguoiDungId = ?
            ORDER BY yt.NgayThem DESC`;
        const [rows] = await db.execute(sql, [userId]);
        return rows;
    },

    // 2. Kiểm tra tồn tại: Dùng cặp NguoiDungId và SanPhamId
    checkExist: async (userId, productId) => {
        const sql = "SELECT * FROM yeuthich WHERE NguoiDungId = ? AND SanPhamId = ?";
        const [rows] = await db.execute(sql, [userId, productId]);
        return rows[0];
    },

    // 3. Thêm mới: Chỉ chèn NguoiDungId và SanPhamId
    create: async (userId, productId) => {
        const sql = "INSERT INTO yeuthich (NguoiDungId, SanPhamId) VALUES (?, ?)";
        const [result] = await db.execute(sql, [userId, productId]);
        return result;
    },

    // 4. Xóa: Dựa trên cặp ID người dùng và sản phẩm
    delete: async (userId, productId) => {
        const sql = "DELETE FROM yeuthich WHERE NguoiDungId = ? AND SanPhamId = ?";
        const [result] = await db.execute(sql, [userId, productId]);
        return result;
    }
};

export default favoriteModel;