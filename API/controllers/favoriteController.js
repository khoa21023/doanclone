import favoriteModel from '../models/favoriteModel.js';

// API: Thêm vào yêu thích
export const addToFavorite = async (req, res) => {
    try {
        const userId = req.user.id; // Lấy từ token
        const { productId } = req.body;

        // 1. Kiểm tra trống
        if (!productId) {
            return res.status(400).json({ success: false, message: "Vui lòng cung cấp mã sản phẩm." });
        }

        // 2. Kiểm tra trùng lặp (phong cách hàm register của cậu)
        const isExist = await favoriteModel.checkExist(userId, productId);
        if (isExist) {
            return res.status(400).json({ success: false, message: "Sản phẩm đã có trong danh sách yêu thích." });
        }

        // 3. Thực hiện thêm (không cần tạo ID tự động)
        await favoriteModel.create(userId, productId);

        res.status(201).json({ 
            success: true, 
            message: "Đã thêm sản phẩm vào danh sách yêu thích." 
        });
    } catch (error) {
        res.status(500).json({ success: false, message: "Lỗi hệ thống: " + error.message });
    }
};

// API: Lấy danh sách yêu thích
export const getFavorites = async (req, res) => {
    try {
        const userId = req.user.id;
        const favorites = await favoriteModel.getFavoritesByUserId(userId);
        
        res.status(200).json({
            success: true,
            count: favorites.length,
            data: favorites
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// API: Xóa khỏi yêu thích
export const removeFromFavorite = async (req, res) => {
    try {
        const userId = req.user.id;
        const { productId } = req.params;

        const result = await favoriteModel.delete(userId, productId);

        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: "Không tìm thấy sản phẩm trong danh sách yêu thích." });
        }

        res.status(200).json({ success: true, message: "Đã xóa khỏi danh sách yêu thích." });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};