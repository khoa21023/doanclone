import express from 'express';
import { addPromotion, updatePromotion, deletePromotion, getPromotions } from '../controllers/promotionController.js';
import { verifyToken, isAdmin } from '../middleware/auth.js';

const router = express.Router();

// Lấy danh sách (Admin & Customer đều xem được)
router.get('/', verifyToken, getPromotions);

// Chỉ Admin mới được Thêm/Sửa/Xóa
router.post('/add', verifyToken, isAdmin, addPromotion);
router.put('/update/:id', verifyToken, isAdmin, updatePromotion);
router.delete('/remove/:id', verifyToken, isAdmin, deletePromotion);
router.get('/', verifyToken, isAdmin, getPromotions);
export default router;