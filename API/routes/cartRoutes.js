import express from 'express';
import { addToCart, getCart, deleteSingleCartItem, updateCartQuantity } from '../controllers/cartController.js';
import { verifyToken, isCustomer } from '../middleware/auth.js';

const router = express.Router();

// Tất cả các route giỏ hàng yêu cầu Token và quyền Customer
router.use(verifyToken, isCustomer);

router.post('/add', addToCart);
router.get('/', getCart);
router.post('/update-quantity', updateCartQuantity); // Route POST cho update
router.delete('/remove/:cartId', deleteSingleCartItem);

export default router;