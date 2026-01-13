import { execute } from '../config/db.js';

export const cartModel = {
    // Lấy danh sách giỏ hàng
    getCartByUserId: async (userId) => {
        const sql = `SELECT gh.*, sp.TenSanPham, sp.GiaBan, sp.HinhAnh 
                     FROM giohang gh JOIN sanpham sp ON gh.SanPhamId = sp.Id 
                     WHERE gh.NguoiDungId = ?`;
        return await execute(sql, [userId]);
    },

    // Kiểm tra sản phẩm trong giỏ 
    findItemInCart: async (userId, productId) => {
        const sql = "SELECT * FROM giohang WHERE NguoiDungId = ? AND SanPhamId = ?";
        return await execute(sql, [userId, productId]);
    },

    // Thêm sản phẩm mới hoặc tăng số lượng
    addToCart: async (cartId, userId, productId, quantity) => {
        const sql = "INSERT INTO giohang (Id, NguoiDungId, SanPhamId, SoLuong) VALUES (?, ?, ?, ?)";
        return await execute(sql, [cartId, userId, productId, quantity]);
    },

    increaseQuantity: async (userId, productId, quantity) => {
        const sql = "UPDATE giohang SET SoLuong = SoLuong + ? WHERE NguoiDungId = ? AND SanPhamId = ?";
        return await execute(sql, [quantity, userId, productId]);
    },

    // Kiểm tra tồn kho 
    checkStock: async (cartId) => {
        const sql = `SELECT sp.TonKho, sp.TenSanPham 
                     FROM giohang gh JOIN sanpham sp ON gh.SanPhamId = sp.Id 
                     WHERE gh.Id = ?`;
        return await execute(sql, [cartId]);
    },

    // Cập nhật số lượng mới
    updateQuantity: async (cartId, quantity) => {
        const sql = "UPDATE giohang SET SoLuong = ? WHERE Id = ?";
        return await execute(sql, [quantity, cartId]);
    },

    // Xóa sản phẩm khỏi giỏ
    removeOneItem: async (cartId, userId) => {
        const sql = "DELETE FROM giohang WHERE Id = ? AND NguoiDungId = ?";
        return await execute(sql, [cartId, userId]);
    }
};