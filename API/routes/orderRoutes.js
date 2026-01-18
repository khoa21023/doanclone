import express from 'express';
import { 
    getAllOrders, 
    getOrderDetails, 
    updateOrderStatus, 
    getOrderStats, 
    getRevenuePending,
    getMyOrders,
    getMyOrderStatusStats,
    cancelMyOrder,
    createOrderAndPay
} from '../controllers/orderController.js';
import { verifyToken, isAdmin, isCustomer } from '../middleware/auth.js';

const router = express.Router();

// --- API DÀNH CHO ADMIN ---
// Lấy tất cả đơn hàng & lọc theo trạng thái
router.get('/admin/all', verifyToken, isAdmin, getAllOrders);

// Cập nhật trạng thái đơn hàng
router.put('/admin/status/:id', verifyToken, isAdmin, updateOrderStatus);

// Thống kê số lượng (Đang giao/Đã giao)
router.get('/admin/stats/count', verifyToken, isAdmin, getOrderStats);

// Tổng tiền đơn "Đã đặt"
router.get('/admin/stats/revenue-pending', verifyToken, isAdmin, getRevenuePending);

// --- API DÀNH CHO USER (CUSTOMER) ---

// Lấy danh sách đơn hàng của mình (có thể ?status=Đã Đặt)
router.get('/my-orders', verifyToken, isCustomer, getMyOrders);

// Lấy thống kê số lượng đơn theo trạng thái (để hiện Badge trên UI)
router.get('/my-orders/stats', verifyToken, isCustomer, getMyOrderStatusStats);

// Hủy đơn hàng
router.put('/my-orders/cancel/:id', verifyToken, isCustomer, cancelMyOrder);

// Đặt hàng & Thanh toán
router.post('/my-orders/create_pay', verifyToken, isCustomer, createOrderAndPay);

// --- API CHUNG ---
// Chi tiết đơn hàng (Cả Admin và User đều dùng được)
router.get('/detail/:id', verifyToken, getOrderDetails);

export default router;