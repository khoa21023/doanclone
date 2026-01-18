import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import {userModel} from '../models/userModel.js';

// --- ĐĂNG NHẬP ---
export const login = async (req, res) => {
    try {
        const { email, password } = req.body;
        
        const user = await userModel.findByEmail(email);
        if (!user) {
            return res.status(404).json({ success: false, message: "Email không tồn tại." });
        }

        const isMatch = await bcrypt.compare(password, user.MatKhau);
        if (!isMatch) {
            return res.status(401).json({ success: false, message: "Mật khẩu không chính xác." });
        }

        const token = jwt.sign(
            { id: user.Id, role: user.VaiTro }, 
            process.env.JWT_SECRET, 
            { expiresIn: '1d' }
        );

        res.status(200).json({
            success: true,
            message: "Đăng nhập thành công",
            token,
            user: { id: user.Id, name: user.HoTen, role: user.VaiTro }
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
// --- LẤY HỒ SƠ CHI TIẾT ---
export const getProfile = async (req, res) => {
    try {
        // userId này được trích xuất từ verifyToken và gán vào req.user
        const userId = req.user.id; 

        const user = await userModel.getUserById(userId);

        if (!user) {
            return res.status(404).json({
                success: false,
                message: "Không tìm thấy người dùng"
            });
        }

        // Trả về thông tin người dùng (không bao gồm mật khẩu)
        res.status(200).json({
            success: true,
            message: "Lấy thông tin thành công",
            data: user
        });
    } catch (error) {
        console.error("Lỗi getProfile:", error);
        res.status(500).json({
            success: false,
            message: "Lỗi hệ thống khi lấy thông tin"
        });
    }
};

// --- CẬP NHẬT HỒ SƠ ---
export const updateProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        const { HoTen, SoDienThoai, DiaChi } = req.body;
        const hoTen = HoTen;
        const soDienThoai = SoDienThoai;
        const diaChi = DiaChi;

        // 1. Kiểm tra trường trống
        if (!hoTen) {
            return res.status(400).json({ success: false, message: "Họ tên không được để trống." });
        }

        // 2. Validate Họ tên
        const nameRegex = /^[a-zA-ZÀÁÂÃÈÉÊÌÍÒÓÔÕÙÚĂĐĨŨƠàáâãèéêìíòóôõùúăđĩũơƯĂÂÊÔƠƯÀẢÃẠẰẮẲẴẶẦẤẨẪẬÈẺẼẸỀẾỂỄỆÌỈĨỊÒỎÕỌỒỐỔỖỘỜỚỞỠỢÙỦŨỤỪỨỬỮỰỳỷỹỵýÝ\s]+$/;
        if (!nameRegex.test(hoTen)) {
            return res.status(400).json({ success: false, message: "Họ tên không hợp lệ." });
        }

        // 3. Validate Số điện thoại
        const phoneRegex = /^[0-9]{10}$/;
        if (soDienThoai && !phoneRegex.test(soDienThoai)) {
            return res.status(400).json({ success: false, message: "Số điện thoại phải gồm 10 chữ số." });
        }

        // 4. Gọi Model cập nhật
        await userModel.updateProfile(userId, { 
            hoTen: hoTen, 
            soDienThoai: soDienThoai, 
            diaChi: diaChi 
        });

        res.json({ success: true, message: "Cập nhật thông tin thành công!" });
    } catch (error) {
        console.error("Lỗi Update Profile:", error);
        res.status(500).json({ success: false, message: "Lỗi hệ thống: " + error.message });
    }
};

// --- UPLOAD ẢNH ĐẠI DIỆN ---
export const uploadAvatar = async (req, res) => {
    try {
        const userId = req.user.id;

        // Kiểm tra xem Multer có nhận được file không
        if (!req.file) {
            return res.status(400).json({ success: false, message: "Vui lòng chọn ảnh (Key: avatar)" });
        }

        const fileName = req.file.filename;
        await userModel.updateAvatar(userId, fileName); // Cập nhật DB

        res.json({ 
            success: true, 
            message: "Cập nhật ảnh thành công", 
            fileName: fileName 
        });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// --- ĐĂNG KÝ ---
export const register = async (req, res) => {
    try {
        const { email, password, fullName, phone, address } = req.body;

        // 1. Kiểm tra trống
        if (!email || !password || !fullName) {
            return res.status(400).json({ success: false, message: "Vui lòng nhập đầy đủ Email, Mật khẩu và Họ tên." });
        }

        // 2. Validate Họ tên (Chỉ chữ)
        const nameRegex = /^[a-zA-ZáàảãạăâắằẳẵặấầẩẫậéèẻẽẹêếềểễệíìỉĩịóòỏõọôơốồổỗộớờởỡợúùủũụưứừửữựýỳỷỹỵđÁÀẢÃẠĂÂẮẰẲẴẶẤẦẨẪẬÉÈẺẼẸÊẾỀỂỄỆÍÌỈĨỊÓÒỎÕỌÔƠỐỒỔỖỘỚỜỞỠỢÚÙỦŨỤƯỨỪỬỮỰÝỲỶỸỴĐ\s]+$/;
        if (!nameRegex.test(fullName)) {
            return res.status(400).json({ success: false, message: "Họ tên không được chứa số hoặc ký tự đặc biệt." });
        }

        // 3. Validate Email & Phone
        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        const phoneRegex = /^[0-9]{10}$/;
        if (!emailRegex.test(email)) return res.status(400).json({ success: false, message: "Email sai định dạng." });
        if (phone && !phoneRegex.test(phone)) return res.status(400).json({ success: false, message: "Số điện thoại phải có 10 số." });

        // 4. Kiểm tra email,sdt tồn tại
        const existingE = await userModel.findByEmail(email);
        if (existingE) return res.status(400).json({ success: false, message: "Email đã được sử dụng" });

        const existingP = await userModel.findByPhone(phone);
        if (existingP) return res.status(400).json({ success: false, message: "SDT đã được sử dụng" });

        // 5. Tạo tài khoản
        const hashedPassword = await bcrypt.hash(password, 10);
        const userId = 'U' + Date.now();

        await userModel.create({
            Id: userId,
            Email: email,
            MatKhau: hashedPassword,
            HoTen: fullName,
            SoDienThoai: phone,
            DiaChi: address
        });

        res.status(201).json({ success: true, message: "Đăng ký tài khoản thành công" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// --- ĐĂNG XUẤT ---
export const logout = async (req, res) => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        if (!token) return res.status(400).json({ success: false, message: "Không tìm thấy token." });

        await userModel.revokeToken(token);
        res.status(200).json({ success: true, message: "Đăng xuất thành công" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};
// 1. ĐỔI MẬT KHẨU (Khi người dùng đang đăng nhập)
export const changePassword = async (req, res) => {
    try {
        const userId = req.user.id; // Lấy từ verifyToken
        const { oldPassword, newPassword } = req.body;

        // Tìm user
        const user = await userModel.findById(userId);
        if (!user) return res.status(404).json({ success: false, message: "User không tồn tại" });

        // Kiểm tra mật khẩu cũ
        const isMatch = await bcrypt.compare(oldPassword, user.MatKhau);
        if (!isMatch) {
            return res.status(400).json({ success: false, message: "Mật khẩu cũ không chính xác." });
        }

        // Mã hóa mật khẩu mới và lưu
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(newPassword, salt);
        await userModel.updatePassword(userId, hashedPassword);

        res.status(200).json({ success: true, message: "Đổi mật khẩu thành công!" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};

// 2. QUÊN MẬT KHẨU (Reset password)
// Lưu ý: Trong thực tế cậu nên gửi OTP về Email. Ở đây tớ làm logic reset trực tiếp qua Email để cậu nắm luồng.
export const resetPassword = async (req, res) => {
    try {
        const { email, newPassword } = req.body;

        // 1. Kiểm tra email có tồn tại không
        const user = await userModel.findByEmail(email);
        if (!user) {
            return res.status(404).json({ success: false, message: "Email không tồn tại trong hệ thống." });
        }

        // 2. Mã hóa mật khẩu mới
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(newPassword, salt);

        // 3. Cập nhật
        await userModel.updatePassword(user.Id, hashedPassword);

        res.status(200).json({ success: true, message: "Đặt lại mật khẩu thành công. Hãy đăng nhập lại!" });
    } catch (error) {
        res.status(500).json({ success: false, message: error.message });
    }
};