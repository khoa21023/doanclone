// models/orderModel.js
import db, { execute } from '../config/db.js'; // Cần import thêm { execute }

const orderModel = {
    // 1. Lấy danh sách đơn hàng theo trạng thái (kèm tên người dùng) - Admin
    getAllOrdersByStatus: async (status) => {
        let sql = `SELECT dh.*, nd.HoTen, nd.Email, nd.SoDienThoai 
                FROM donhang dh 
                LEFT JOIN nguoidung nd ON dh.NguoiDungId = nd.Id`; 

        const params = [];
        if (status) {
            sql += " WHERE dh.TrangThaiDonHang = ?";
            params.push(status);
        }
        sql += " ORDER BY dh.NgayDat DESC";
        return await execute(sql, params);
    },

    // 2. Lấy thông tin cơ bản của 1 đơn hàng
    getById: async (id) => {
        const rows = await execute("SELECT * FROM donhang WHERE Id = ?", [id]);
        return rows[0];
    },

    // 3. Lấy chi tiết các sản phẩm trong đơn hàng
    getDetails: async (orderId) => {
        // Lưu ý: bảng sanpham là TenSP, bảng chitietdonhang là TenSanPham
        const sql = `SELECT ctdh.*, sp.TenSanPham, sp.HinhAnh 
                     FROM chitietdonhang ctdh 
                     JOIN sanpham sp ON ctdh.SanPhamId = sp.Id 
                     WHERE ctdh.DonHangId = ?`;
        return await execute(sql, [orderId]);
    },

    // 4. Cập nhật trạng thái
    updateStatus: async (id, status) => {
        const sql = "UPDATE donhang SET TrangThaiDonHang = ? WHERE Id = ?";
        return await execute(sql, [status, id]);
    },

    // 5. Thống kê số lượng đơn hàng theo nhiều trạng thái
    countByStatuses: async (statuses) => {
        const placeholders = statuses.map(() => '?').join(',');
        const sql = `SELECT TrangThaiDonHang, COUNT(*) as SoLuong 
                     FROM donhang 
                     WHERE TrangThaiDonHang IN (${placeholders}) 
                     GROUP BY TrangThaiDonHang`;
        return await execute(sql, statuses);
    },

    // 6. Tính tổng tiền theo trạng thái (Sửa: ThanhTien -> TongTien)
    getTotalAmountByStatus: async (status) => {
        const sql = "SELECT SUM(ThanhTien) as TongDoanhThu FROM donhang WHERE TrangThaiDonHang = ?";
        const rows = await execute(sql, [status]);
        return rows[0].TongDoanhThu || 0;
    },

    // 7. User lấy đơn hàng của mình
    getOrdersByUser: async (userId, status) => {
        let sql = "SELECT * FROM donhang WHERE NguoiDungId = ?";
        const params = [userId];
        if (status) {
            sql += " AND TrangThaiDonHang = ?";
            params.push(status);
        }
        sql += " ORDER BY NgayDat DESC";
        return await execute(sql, params);
    },

    // 8. Lấy số lượng đơn hàng theo từng trạng thái của 1 User
    countStatusByUser: async (userId) => {
        const sql = `
            SELECT TrangThaiDonHang, COUNT(*) as SoLuong 
            FROM donhang 
            WHERE NguoiDungId = ? 
            GROUP BY TrangThaiDonHang`;
        return await execute(sql, [userId]);
    },

    // 9. Hủy đơn hàng
    cancelOrder: async (orderId, userId) => {
        const sql = "UPDATE donhang SET TrangThaiDonHang = 'Đã Hủy' WHERE Id = ? AND NguoiDungId = ?";
        return await execute(sql, [orderId, userId]);
    },

    // 10. Kiểm tra trạng thái hiện tại (Sửa property truy cập: TrangThai -> TrangThaiDonHang)
    getOrderStatus: async (orderId, userId) => {
        const sql = "SELECT TrangThaiDonHang FROM donhang WHERE Id = ? AND NguoiDungId = ?";
        const rows = await execute(sql, [orderId, userId]);
        return rows[0] ? rows[0].TrangThaiDonHang : null; // Phải dùng chính xác tên cột
    }
};

export default orderModel;