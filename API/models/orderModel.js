import { execute } from '../config/db.js';

export const orderModel = {
    // Admin lấy tất cả đơn hàng (có lọc status)
    getAllOrdersForAdmin: async (status) => {
        let sql = `SELECT dh.*, nd.HoTen 
                   FROM donhang dh 
                   JOIN nguoidung nd ON dh.NguoiDungId = nd.Id`;
        const params = [];

        if (status) {
            sql += " WHERE dh.TrangThai = ?";
            params.push(status);
        }

        sql += " ORDER BY dh.NgayDat DESC";
        const [rows] = await db.execute(sql, params);
        return rows;
    },

    // User lấy đơn hàng của chính mình (có lọc status)
    getOrdersByUser: async (userId, status) => {
        let sql = "SELECT * FROM donhang WHERE NguoiDungId = ?";
        const params = [userId];

        // Nếu User có truyền status lên, ta thêm điều kiện AND vào SQL
        if (status) {
            sql += " AND TrangThai = ?";
            params.push(status);
        }

        sql += " ORDER BY NgayDat DESC";
        const [rows] = await db.execute(sql, params);
        return rows;
    },

    // 1. Tạo đơn hàng (Bảng donhang)
    createOrder: async (data) => {
        const { id, userId, ten, sdt, diaChi, tamTinh, phiShip, tongCuoi } = data;
        const sql = `INSERT INTO donhang 
            (Id, NguoiDungId, TenNguoiNhan, SdtNguoiNhan, DiaChiGiao, TongTienHang, PhiShip, ThanhTien, TrangThaiDonHang, TrangThaiThanhToan, NgayDat) 
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'ChoXacNhan', 0, NOW())`;
        return await execute(sql, [id, userId, ten, sdt, diaChi, tamTinh, phiShip, tongCuoi]);
    },

    // 2. Lưu chi tiết đơn hàng (Bảng chitietdonhang)
    createOrderDetail: async (d) => {
        const sql = `INSERT INTO chitietdonhang (Id, DonHangId, SanPhamId, TenSanPham, SoLuong, GiaLucMua, ThanhTien) 
                     VALUES (?, ?, ?, ?, ?, ?, ?)`;
        return await execute(sql, [d.id, d.orderId, d.productId, d.name, d.quantity, d.price, d.subtotal]);
    },

    // 3. Lưu thông tin thanh toán (Bảng thanhtoan)
    createPayment: async (p) => {
        const sql = `INSERT INTO thanhtoan (Id, DonHangId, PhuongThuc, SoTienThanhToan, NgayThanhToan, TrangThai) 
                     VALUES (?, ?, ?, ?, NOW(), ?)`;
        const status = p.method === 'COD' ? 'ChoXuLy' : 'ThanhCong';
        return await execute(sql, [p.id, p.orderId, p.method, p.amount, status]);
    },

    // Lấy thông tin các sản phẩm đã chọn từ giỏ hàng để tính tiền
    getSelectedItems: async (cartItemIds, userId) => {
        const placeholders = cartItemIds.map(() => "?").join(",");
        const sql = `SELECT gh.Id as CartId, gh.SoLuong, sp.Id as SanPhamId, sp.GiaBan, sp.TenSanPham 
                     FROM giohang gh JOIN sanpham sp ON gh.SanPhamId = sp.Id 
                     WHERE gh.Id IN (${placeholders}) AND gh.NguoiDungId = ?`;
        return await execute(sql, [...cartItemIds, userId]);
    },

    // Cập nhật tồn kho và xóa giỏ hàng
    decreaseStock: async (pId, qty) => {
        return await execute("UPDATE sanpham SET TonKho = TonKho - ? WHERE Id = ?", [qty, pId]);
    },

    removeFromCart: async (cartId, userId) => {
        return await execute("DELETE FROM giohang WHERE Id = ? AND NguoiDungId = ?", [cartId, userId]);
    },

    updateStatus: async (orderId, status) => {
        const sql = "UPDATE donhang SET TrangThaiDonHang = ? WHERE Id = ?";
        return await execute(sql, [status, orderId]);
    }
};