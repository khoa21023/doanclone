import orderModel from '../models/orderModel.js';
import db from '../config/db.js';
import { createRequire } from 'module';
const require = createRequire(import.meta.url);
const PayOSLib = require("@payos/node");
const PayOS = PayOSLib.PayOS || PayOSLib.default || PayOSLib;
// --------------------

const payos = new PayOS(
    process.env.PAYOS_CLIENT_ID,
    process.env.PAYOS_API_KEY,
    process.env.PAYOS_CHECKSUM_KEY
);

// Lấy tất cả đơn hàng (Admin)
export const getAllOrders = async (req, res) => {
    try {
        const { status } = req.query; // Ví dụ: ?status=Đã Đặt
        const orders = await orderModel.getAllOrdersByStatus(status);
        res.status(200).json({ success: true, data: orders });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Lấy chi tiết đơn hàng (Admin & User)
export const getOrderDetails = async (req, res) => {
    try {
        const { id } = req.params;
        const order = await orderModel.getById(id);
        if (!order) return res.status(404).json({ success: false, message: "Không tìm thấy đơn hàng" });

        const products = await orderModel.getDetails(id);
        res.status(200).json({ success: true, data: { ...order, products } });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Cập nhật trạng thái (Admin)
export const updateOrderStatus = async (req, res) => {
    try {
        const { id } = req.params;
        const { status } = req.body; // "Đã Đặt", "Đang Giao", "Đã Giao"

        const result = await orderModel.updateStatus(id, status);
        if (result.affectedRows === 0) return res.status(404).json({ success: false, message: "Thất bại" });

        res.status(200).json({ success: true, message: "Cập nhật trạng thái thành công" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Thống kê số lượng đơn 
export const getOrderStats = async (req, res) => {
    try {
        const stats = await orderModel.countByStatuses(["Đã Đặt", "Đã Huỷ", "Đang Giao", "Đã Giao"]);
        res.status(200).json({ success: true, data: stats });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Tổng tiền các đơn "Đã giao"
export const getRevenuePending = async (req, res) => {
    try {
        const total = await orderModel.getTotalAmountByStatus("Đã Giao");
        res.status(200).json({ success: true, totalRevenue: total });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
// 1. Lấy danh sách đơn hàng của User (Có thể lọc theo ?status=)
export const getMyOrders = async (req, res) => {
    try {
        const userId = req.user.id;
        const { status } = req.query;
        const orders = await orderModel.getOrdersByUser(userId, status);
        
        res.status(200).json({
            success: true,
            count: orders.length,
            data: orders
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// 2. Lấy số lượng đơn hàng theo trạng thái của User
export const getMyOrderStatusStats = async (req, res) => {
    try {
        const userId = req.user.id;
        const stats = await orderModel.countStatusByUser(userId);
        
        res.status(200).json({
            success: true,
            data: stats
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// 3. Hủy đơn hàng (Chỉ cho phép khi trạng thái là 'Đã Đặt')
export const cancelMyOrder = async (req, res) => {
    try {
        const userId = req.user.id;
        const { id } = req.params; // ID đơn hàng

        // Bước 1: Kiểm tra trạng thái hiện tại
        const currentStatus = await orderModel.getOrderStatus(id, userId);

        if (!currentStatus) {
            return res.status(404).json({ success: false, message: "Không tìm thấy đơn hàng." });
        }

        // Bước 2: Logic chặn hủy đơn
        if (currentStatus === 'Đang Giao' || currentStatus === 'Đã Giao') {
            return res.status(400).json({ 
                success: false, 
                message: `Không thể hủy đơn hàng khi đang ở trạng thái: ${currentStatus}` 
            });
        }
        
        if (currentStatus === 'Đã Hủy') {
            return res.status(400).json({ success: false, message: "Đơn hàng này đã được hủy trước đó." });
        }

        // Bước 3: Tiến hành hủy
        await orderModel.cancelOrder(id, userId);

        res.status(200).json({
            success: true,
            message: "Hủy đơn hàng thành công."
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Đặt hàng và thanh toán
export const createOrderAndPay = async (req, res) => {
    const userId = req.user.id; 
    // Thêm PhuongThucThanhToan để biết là COD hay VISA
    const { TenNguoiNhan, SdtNguoiNhan, DiaChiGiao, PhuongThucThanhToan } = req.body;

    try {
        console.log("Bắt đầu tạo đơn cho:", TenNguoiNhan);

        // --- BƯỚC 1: LẤY CHI TIẾT GIỎ HÀNG ---
        const sqlGetCart = `
            SELECT gh.SanPhamId, gh.SoLuong, sp.GiaBan, sp.TenSanPham, sp.HinhAnh 
            FROM giohang gh 
            JOIN sanpham sp ON gh.SanPhamId = sp.Id 
            WHERE gh.NguoiDungId = ?
        `;
        const [cartItems] = await db.query(sqlGetCart, [userId]);

        if (cartItems.length === 0) {
            return res.status(400).json({ message: "Giỏ hàng trống" });
        }

        // --- TÍNH TOÁN TIỀN ---
        let tongTienHang = 0;
        for (const item of cartItems) {
            tongTienHang += Number(item.GiaBan) * item.SoLuong;
        }
        const phiShip = 30000; 
        const giamGia = 0;     
        const thanhTien = tongTienHang + phiShip - giamGia;

        // --- BƯỚC 2: TẠO ĐƠN HÀNG ---
        const orderIdStr = `DH${Date.now()}`; 
        
        const sqlInsertOrder = `
            INSERT INTO donhang (
                Id, NguoiDungId, TenNguoiNhan, SdtNguoiNhan, DiaChiGiao, 
                TongTienHang, PhiShip, GiamGia, ThanhTien, 
                TrangThaiDonHang, TrangThaiThanhToan, NgayDat
            )
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 'ChoXacNhan', 'Chưa thanh toán', NOW())
        `;
        
        await db.query(sqlInsertOrder, [
            orderIdStr, userId, TenNguoiNhan, SdtNguoiNhan, DiaChiGiao, 
            tongTienHang, phiShip, giamGia, thanhTien
        ]);

        // --- BƯỚC 3: LƯU CHI TIẾT ĐƠN HÀNG ---
        const sqlInsertDetail = `
            INSERT INTO chitietdonhang (Id, DonHangId, SanPhamId, TenSanPham, SoLuong, GiaLucMua, ThanhTien) 
            VALUES ?
        `;
        const baseTime = Date.now();
        const detailValues = cartItems.map((item, i) => [
            `CT${baseTime}${i}`, orderIdStr, item.SanPhamId, item.TenSanPham,
            item.SoLuong, item.GiaBan, item.GiaBan * item.SoLuong
        ]);
        await db.query(sqlInsertDetail, [detailValues]);

        // --- BƯỚC 4: LƯU GIAO DỊCH ---
        const paymentCode = Date.now(); 
        const paymentId = `TT${paymentCode}`; 

        const sqlInsertPayment = `
            INSERT INTO thanhtoan (Id, DonHangId, PhuongThuc, MaGiaoDich, SoTienThanhToan, TrangThai, NgayThanhToan)
            VALUES (?, ?, ?, ?, ?, 'Pending', NOW())
        `;
        await db.query(sqlInsertPayment, [paymentId, orderIdStr, PhuongThucThanhToan, paymentCode, thanhTien]);

        // --- BƯỚC 5: XÓA GIỎ HÀNG ---
        await db.query("DELETE FROM giohang WHERE NguoiDungId = ?", [userId]);
        
        // Nếu là COD (Thanh toán khi nhận hàng) -> Trả về thành công luôn, không gọi PayOS
        if (PhuongThucThanhToan === 'cod') {
            return res.json({ 
                error: false, 
                message: "Đặt hàng thành công (COD)", 
                orderId: orderIdStr 
            });
        }

        const descriptionShort = `TT ${orderIdStr}`; 
        const paymentData = {
            orderCode: paymentCode,
            amount: thanhTien,
            description: descriptionShort,
            cancelUrl: "https://mobile-tech-ct.onrender.com/api/payment/cancel",
            returnUrl: "https://mobile-tech-ct.onrender.com/api/payment/success"
        };

        const result = await payos.createPaymentLink(paymentData);
        res.json({ error: false, message: "Tạo link thanh toán thành công", checkoutUrl: result.checkoutUrl });

    } catch (error) {
        console.error("Lỗi chi tiết:", error);
        res.status(500).json({ error: true, message: "Lỗi Server: " + error.message });
    }
};