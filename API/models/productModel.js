import { execute } from '../config/db.js';

export const productModel = {
    // Lấy danh sách sản phẩm với bộ lọc và sắp xếp
    fetchProducts: async (filters) => {
        let sql = "SELECT * FROM sanpham WHERE TrangThai = 1";
        const params = [];

        if (filters.category) {
            sql += " AND DanhMucId = ?";
            params.push(filters.category);
        }

        if (filters.name) {
            sql += " AND TenSanPham LIKE ?";
            params.push(`%${filters.name}%`);
        }

        // Xử lý sắp xếp
        switch (filters.sort) {
            case 'new': sql += " ORDER BY NgayTao DESC"; break;
            case 'hot': sql += " ORDER BY SoLuotXem DESC"; break;
            case 'priceAsc': sql += " ORDER BY GiaBan ASC"; break;
            case 'priceDesc': sql += " ORDER BY GiaBan DESC"; break;
            default: sql += " ORDER BY Id ASC";
        }

        return await execute(sql, params);
    },

    // Lấy chi tiết 1 sản phẩm
    fetchById: async (id) => {
        const sql = "SELECT * FROM sanpham WHERE Id = ?";
        return await execute(sql, [id]);
    },

    // Tăng lượt xem
    incrementView: async (id) => {
        const sql = "UPDATE sanpham SET SoLuotXem = SoLuotXem + 1 WHERE Id = ?";
        return await execute(sql, [id]);
    }
};