import { productModel } from '../models/productModel.js';

export const getProducts = async (req, res) => {
    try {
        // Lấy các tham số lọc từ query string
        const filters = {
            category: req.query.category,
            name: req.query.name,
            sort: req.query.sort
        };

        const rows = await productModel.fetchProducts(filters);

        res.status(200).json({
            success: true,
            message: "Lấy danh sách sản phẩm thành công",
            data: rows
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Lỗi server: " + error.message
        });
    }
};

export const getProductDetail = async (req, res) => {
    try {
        const { id } = req.params;
        
        // 1. Tăng lượt xem
        await productModel.incrementView(id);

        // 2. Lấy thông tin chi tiết
        const rows = await productModel.fetchById(id);
        
        if (rows.length === 0) {
            return res.status(404).json({
                success: false,
                message: "Sản phẩm không tồn tại"
            });
        }

        res.status(200).json({
            success: true,
            data: rows[0]
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            message: "Lỗi server: " + error.message
        });
    }
};