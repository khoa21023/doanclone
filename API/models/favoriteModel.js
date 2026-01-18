import { execute } from '../config/db.js';
const favoriteModel = {
    // 1. Lấy danh sách: JOIN với bảng sanpham để lấy thông tin chi tiết
    getFavoritesByUserId: async (userId) => {
        const sql = `
            SELECT sp.*, yt.NgayThem 
            FROM yeuthich yt
            JOIN sanpham sp ON yt.SanPhamId = sp.Id
            WHERE yt.NguoiDungId = ?
            ORDER BY yt.NgayThem DESC`;
        return await execute(sql, [userId]); 
    },

    // 2. Kiểm tra tồn tại
    checkExist: async (userId, productId) => {
        const sql = "SELECT * FROM yeuthich WHERE NguoiDungId = ? AND SanPhamId = ?";
        const rows = await execute(sql, [userId, productId]);
        return rows.length > 0;
    },

    // 3. Thêm mới
    create: async (userId, productId) => {
        const sql = "INSERT INTO yeuthich (NguoiDungId, SanPhamId) VALUES (?, ?)";
        return await execute(sql, [userId, productId]);
    },

    // 4. Xóa
    delete: async (userId, productId) => {
        const sql = "DELETE FROM yeuthich WHERE NguoiDungId = ? AND SanPhamId = ?";
        return await execute(sql, [userId, productId.toString()]); 
    }
};

export default favoriteModel;