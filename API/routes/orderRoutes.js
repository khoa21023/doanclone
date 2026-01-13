import express from 'express';
import { previewSelectedItems, checkoutSelected, getAllOrders, updateOrderStatus } from '../controllers/orderController.js';
import { verifyToken, isAdmin, isCustomer } from '../middleware/auth.js';

const router = express.Router();

// Route cho khách hàng
router.post('/preview', verifyToken, isCustomer, previewSelectedItems);
router.post('/checkout', verifyToken, isCustomer, checkoutSelected);

// Route cho admin
router.get('/all', verifyToken, isAdmin, getAllOrders);
router.put('/update-status', verifyToken, isAdmin, updateOrderStatus);

export default router;