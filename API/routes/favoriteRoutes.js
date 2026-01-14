import express from 'express';
import { getFavorites, addToFavorite, removeFromFavorite } from '../controllers/favoriteController.js';
import { verifyToken, isCustomer } from '../middleware/auth.js';

const router = express.Router();

// Tất cả đều cần đăng nhập
router.get('/', verifyToken, isCustomer, getFavorites);
router.post('/add', verifyToken, isCustomer, addToFavorite);
router.delete('/remove/:productId', verifyToken, isCustomer, removeFromFavorite);

export default router;