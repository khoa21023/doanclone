import express from 'express';
import { getProducts, getProductDetail } from '../controllers/productController.js';
import { verifyToken, isCustomer } from '../middleware/auth.js';

const router = express.Router();

// Nếu bạn muốn ai cũng xem được sản phẩm (không cần đăng nhập), hãy bỏ verifyToken
// Nhưng nếu muốn theo logic cũ của bạn:
router.use(verifyToken, isCustomer);

router.get('/', getProducts);
router.get('/:id', getProductDetail);

export default router;