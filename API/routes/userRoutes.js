import express from 'express';
import upload from '../config/upload.js';
import { login, register, logout, getProfile,updateProfile, uploadAvatar, changePassword, resetPassword } from '../controllers/userController.js';
import { verifyToken,isCustomer,isAdmin } from '../middleware/auth.js';
const router = express.Router();
// 1. Kiểm tra Token -> 2. Kiểm tra Quyền -> 3. Cập nhật
router.put('/update-profile', verifyToken, isCustomer, updateProfile); 
// 1. Kiểm tra Token -> 2. Kiểm tra Quyền -> 3. Hiển thị Profile
router.get('/profile', verifyToken, isCustomer, getProfile);
// 1. Kiểm tra Token -> 2. Kiểm tra Quyền -> 3. Nhận File -> 4. Xử lý lưu DB
router.post('/avatar', verifyToken, isCustomer, upload.single('avatar'), uploadAvatar);

router.post('/register', register); 
router.post('/login', login);
router.post('/logout', verifyToken, logout);
// Đổi mật khẩu (Cần đăng nhập)
router.put('/change-password', verifyToken, changePassword);
// Quên mật khẩu (Không cần đăng nhập)
router.post('/reset-password', resetPassword);
export default router;