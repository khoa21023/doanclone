import { orderModel } from '../models/orderModel.js';

// Xem trước đơn hàng (Màn hình 1: Xác nhận thông tin)
export const previewSelectedItems = async (req, res) => {
    try {
        const userId = req.user.id;
        const { cartItemIds } = req.body;

        if (!cartItemIds || cartItemIds.length === 0) {
            return res.status(400).json({ success: false, message: "Bạn chưa chọn sản phẩm nào." });
        }

        const items = await orderModel.getSelectedItems(cartItemIds, userId);
        let totalProvision = 0;
        const detailItems = items.map(item => {
            const subtotal = item.SoLuong * item.GiaBan;
            totalProvision += subtotal;
            return { ...item, ThanhTien: subtotal };
        });

        res.json({
            success: true,
            data: { products: detailItems, totalAmount: totalProvision, phiShip: 5000 }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Đặt hàng cuối cùng (Màn hình 3: Sau khi chọn phương thức thanh toán)
export const checkoutSelected = async (req, res) => {
    try {
        const userId = req.user.id;
        const { cartItemIds, name, phone, address, paymentMethod } = req.body;

        // 1. Kiểm tra sản phẩm
        const items = await orderModel.getSelectedItems(cartItemIds, userId);
        
        // LOGIC YÊU CẦU: Nếu không có sản phẩm thì phí ship = 0 và dừng lại
        if (!items || items.length === 0) {
            return res.status(400).json({ 
                success: false, 
                message: "Giỏ hàng rỗng hoặc không hợp lệ.",
                phiShip: 0,
                tongCuoi: 0
            });
        }

        // 2. Tính toán (Lúc này chắc chắn items.length > 0)
        let tamTinh = 0;
        items.forEach(i => tamTinh += i.GiaBan * i.SoLuong);
        
        const phiShip = 30000; // Có hàng mới tính ship
        const tongCuoi = tamTinh + phiShip;
        const orderId = 'DH' + Date.now();

        // 3. Tạo đơn hàng & Chi tiết & Thanh toán
        await orderModel.createOrder({ 
            id: orderId, userId, ten: name, sdt: phone, 
            diaChi: address, tamTinh, phiShip, tongCuoi 
        });

        for (const item of items) {
            await orderModel.createOrderDetail({
                id: 'CT' + Math.random().toString(36).substr(2, 9),
                orderId, 
                productId: item.SanPhamId, 
                name: item.TenSanPham,
                quantity: item.SoLuong, 
                price: item.GiaBan, 
                subtotal: item.GiaBan * item.SoLuong
            });
            
            await orderModel.decreaseStock(item.SanPhamId, item.SoLuong);
            
            // SỬA LỖI TẠI ĐÂY: Trong Database của cậu là item.Id (xem ảnh image_77367a.png)
            // Cũ của cậu là item.CartId (bị undefined nên gây lỗi 500)
            await orderModel.removeFromCart(item.Id, userId); 
        }

        await orderModel.createPayment({
            id: 'TT' + Math.random().toString(36).substr(2, 5).toUpperCase(),
            orderId, 
            method: paymentMethod, 
            amount: tongCuoi
        });

        res.status(200).json({ 
            success: true, 
            message: "Đặt hàng thành công!", 
            orderId,
            data: { tamTinh, phiShip, tongCuoi }
        });
    } catch (error) {
        console.error("Lỗi Checkout:", error); // Log ra để cậu dễ debug
        res.status(500).json({ success: false, message: "Lỗi hệ thống: " + error.message });
    }
};

export const getAllOrders = async (req, res) => {
    try {
        const { role, id: userId } = req.user; 
        const { status } = req.query; // Lấy trạng thái từ URL (VD: ?status=ChoXacNhan)

        let orders;

        if (role === 'admin') {
            // ADMIN: Lấy tất cả, nếu có status thì lọc theo status
            orders = await orderModel.getAllOrdersForAdmin(status);
        } else {
            // USER: Lấy đơn của mình, nếu có status thì lọc theo status của mình
            orders = await orderModel.getOrdersByUser(userId, status);
        }

        res.status(200).json({
            success: true,
            count: orders.length,
            data: orders
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// Cập nhật trạng thái đơn hàng (Ví dụ: Đã giao, Đã hủy)
export const updateOrderStatus = async (req, res) => {
    try {
        const { orderId, status } = req.body;
        
        const result = await orderModel.updateStatus(orderId, status);
        
        res.status(200).json({
            success: true,
            message: "Cập nhật trạng thái thành công"
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};