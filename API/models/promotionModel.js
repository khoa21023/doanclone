import db from '../config/db.js';

const promotionModel = {
    findByCode: async (maCode) => {
        const [rows] = await db.execute("SELECT * FROM khuyenmai WHERE MaCode = ?", [maCode]);
        return rows[0];
    },

    create: async (id, data) => {
        const { MaCode, SoTienGiam, DonToiThieu, SoLuong, NgayBatDau, NgayKetThuc } = data;
        const sql = `INSERT INTO khuyenmai (Id, MaCode, SoTienGiam, DonToiThieu, SoLuong, NgayBatDau, NgayKetThuc) 
                     VALUES (?, ?, ?, ?, ?, ?, ?)`;
        const [result] = await db.execute(sql, [id, MaCode, SoTienGiam, DonToiThieu, SoLuong, NgayBatDau, NgayKetThuc]);
        return result;
    },

    // 2. Cập nhật khuyến mãi theo Id
    update: async (id, data) => {
        const { MaCode, SoTienGiam, DonToiThieu, SoLuong, NgayBatDau, NgayKetThuc } = data;
        const sql = `UPDATE khuyenmai SET MaCode=?, SoTienGiam=?, DonToiThieu=?, SoLuong=?, NgayBatDau=?, NgayKetThuc=? 
                     WHERE Id=?`;
        const [result] = await db.execute(sql, [MaCode, SoTienGiam, DonToiThieu, SoLuong, NgayBatDau, NgayKetThuc, id]);
        return result;
    },

    // 3. Xóa khuyến mãi theo Id
    delete: async (id) => {
        const sql = `DELETE FROM khuyenmai WHERE Id = ?`;
        const [result] = await db.execute(sql, [id]);
        return result;
    },

    // 4. Lấy tất cả danh sách (để Admin quản lý)
    getAll: async () => {
        const [rows] = await db.execute("SELECT * FROM khuyenmai ORDER BY NgayBatDau DESC");
        return rows;
    }
};

export default promotionModel;