import promotionModel from '../models/promotionModel.js';

export const addPromotion = async (req, res) => {
    try {
        const { MaCode, SoTienGiam, DonToiThieu, SoLuong, NgayBatDau, NgayKetThuc } = req.body;

        // 1. Kiểm tra trống các trường bắt buộc
        if (!MaCode || !SoTienGiam || !NgayBatDau || !NgayKetThuc) {
            return res.status(400).json({ 
                success: false, 
                message: "Vui lòng nhập đầy đủ Mã code, Số tiền giảm, Ngày bắt đầu và Kết thúc." 
            });
        }

        // 2. Validate định dạng MaCode (Chỉ chữ và số, không khoảng trắng)
        const codeRegex = /^[a-zA-Z0-9]+$/;
        if (!codeRegex.test(MaCode)) {
            return res.status(400).json({ 
                success: false, 
                message: "Mã khuyến mãi chỉ được chứa chữ và số, không có ký tự đặc biệt hoặc khoảng trắng." 
            });
        }

        // 3. Validate giá trị số (Phải là số dương)
        if (SoTienGiam <= 0 || SoLuong < 0) {
            return res.status(400).json({ 
                success: false, 
                message: "Số tiền giảm phải lớn hơn 0 và số lượng không được âm." 
            });
        }
        // 4. Validate Logic Ngày tháng
        const start = new Date(NgayBatDau);
        const end = new Date(NgayKetThuc);
        if (end <= start) {
            return res.status(400).json({ 
                success: false, 
                message: "Ngày kết thúc phải diễn ra sau ngày bắt đầu." 
            });
        }
        // 5. Kiểm tra MaCode đã tồn tại chưa (giống kiểm tra email tồn tại)
        const existing = await promotionModel.findByCode(MaCode);
        if (existing) {
            return res.status(400).json({ 
                success: false, 
                message: "Mã khuyến mãi này đã có trên hệ thống." 
            });
        }

        // 6. Tạo ID theo dạng P + thời gian và Lưu
        const promoId = 'P' + Date.now();

        await promotionModel.create(promoId, {
            MaCode: MaCode.toUpperCase(), // Tự động viết hoa mã code cho đẹp
            SoTienGiam,
            DonToiThieu: DonToiThieu || 0,
            SoLuong: SoLuong || 0,
            NgayBatDau,
            NgayKetThuc
        });

        res.status(201).json({ 
            success: true, 
            message: "Tạo chương trình khuyến mãi thành công!", 
            id: promoId 
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const updatePromotion = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await promotionModel.update(id, req.body);
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: "Không tìm thấy mã khuyến mãi để cập nhật" });
        }
        res.json({ success: true, message: "Cập nhật khuyến mãi thành công" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const deletePromotion = async (req, res) => {
    try {
        const { id } = req.params;
        const result = await promotionModel.delete(id);
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: "Mã không tồn tại" });
        }
        res.json({ success: true, message: "Xóa thành công" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

export const getPromotions = async (req, res) => {
    try {
        const data = await promotionModel.getAll();
        res.json({ success: true, data });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};