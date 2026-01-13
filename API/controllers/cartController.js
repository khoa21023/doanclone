import { cartModel } from '../models/cartModel.js';

export const addToCart = async (req, res) => {
    try {
        const { productId, quantity } = req.body;
        const userId = req.user.id;

        const existing = await cartModel.findItemInCart(userId, productId);

        if (existing.length > 0) {
            await cartModel.increaseQuantity(userId, productId, quantity);
        } else {
            const cartId = 'GH' + Date.now();
            await cartModel.addToCart(cartId, userId, productId, quantity);
        }
        return res.json({ success: true, message: "Đã thêm vào giỏ hàng" });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

export const getCart = async (req, res) => {
    try {
        const userId = req.user.id;
        const items = await cartModel.getCartByUserId(userId);
        // 1. Nếu giỏ hàng rỗng
        if (!items || items.length === 0) {
            return res.json({
                success: true,
                data: { 
                    items: [], 
                    summary: { 
                        tamTinh: 0, 
                        phiShip: 0, 
                        thanhTien: 0 
                    } 
                }
            });
        }

        // 2. Nếu có hàng thì mới tính toán
        const phiShip = 30000;
        let tamTinh = 0;

        const detailItems = items.map(item => {
            const sum = item.GiaBan * item.SoLuong;
            tamTinh += sum;
            return { ...item, ThanhTienMon: sum };
        });

        return res.json({
            success: true,
            data: { items: detailItems, summary: { tamTinh, phiShip, thanhTien: tamTinh + phiShip } }
        });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};

export const updateCartQuantity = async (req, res) => {
    try {
        const { cartId, quantity } = req.body;

        // 1. Kiểm tra tồn kho
        const stockResult = await cartModel.checkStock(cartId);
        if (!stockResult.length) return res.status(404).json({ success: false, message: "Không tìm thấy sản phẩm" });

        const { TonKho, TenSanPham } = stockResult[0];
        if (TonKho < quantity) {
            return res.status(400).json({ success: false, message: `Sản phẩm ${TenSanPham} chỉ còn ${TonKho} cái.` });
        }

        // 2. Cập nhật
        await cartModel.updateQuantity(cartId, quantity);
        return res.status(200).json({ success: true, message: "Đã cập nhật số lượng thành công" });
    } catch (error) {
        // Thứ tự (req, res) ở đầu hàm sẽ giúp hết lỗi "res.status is not a function"
        return res.status(500).json({ success: false, message: error.message });
    }
};

export const deleteSingleCartItem = async (req, res) => {
    try {
        const { cartId } = req.params;
        const userId = req.user.id;
        await cartModel.removeOneItem(cartId, userId); 
        return res.json({ success: true, message: "Đã xóa sản phẩm khỏi giỏ hàng" });
    } catch (error) {
        return res.status(500).json({ success: false, message: error.message });
    }
};