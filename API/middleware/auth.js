import jwt from 'jsonwebtoken';
import { userModel } from '../models/userModel.js';

/**
 * Middleware xác thực Token JWT
 */
export const verifyToken = async (req, res, next) => {
    try {
        const authHeader = req.headers['authorization'];
        const token = authHeader && authHeader.split(' ')[1];

        // 1. Kiểm tra sự tồn tại của Token
        if (!token) {
            return res.status(403).json({ 
                success: false, 
                message: "Quyền truy cập bị từ chối. Vui lòng đăng nhập!" 
            });
        }

        // 2. Kiểm tra Token đã bị thu hồi (Logout) chưa thông qua Model
        const isRevoked = await userModel.isTokenRevoked(token);
        if (isRevoked) {
            return res.status(401).json({ 
                success: false, 
                message: "Phiên đăng nhập đã hết hạn hoặc bạn đã đăng xuất." 
            });
        }

        // 3. Xác thực tính hợp lệ của JWT
        jwt.verify(token, process.env.JWT_SECRET, (err, decoded) => {
            if (err) {
                return res.status(401).json({ 
                    success: false, 
                    message: "Token không hợp lệ hoặc đã hết hạn." 
                });
            }

            // Lưu thông tin giải mã (id, role) vào đối tượng req để các hàm sau sử dụng
            req.user = decoded; 
            next();
        });
        
    } catch (error) {
        console.error("Auth Middleware Error:", error);
        return res.status(500).json({ 
            success: false, 
            message: "Lỗi hệ thống xác thực." 
        });
    }
};

/**
 * Middleware kiểm tra quyền Admin
 */
export const isAdmin = (req, res, next) => {
    // req.user được gán từ verifyToken phía trên
    if (!req.user || req.user.role !== 'Admin') {
        return res.status(403).json({ 
            success: false, 
            message: "Truy cập bị từ chối! Khu vực này chỉ dành cho Quản trị viên." 
        });
    }
    next();
};

/**
 * Middleware kiểm tra quyền Khách hàng
 */
export const isCustomer = (req, res, next) => {
    if (!req.user || req.user.role !== 'KhachHang') {
        return res.status(403).json({ 
            success: false, 
            message: "Tài khoản của bạn không có quyền thực hiện chức năng này!" 
        });
    }
    next();
};