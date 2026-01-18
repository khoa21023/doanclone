import express from 'express';
import { handleWebhook, paymentSuccess, paymentCancel } from '../controllers/paymentController.js';

const router = express.Router();

router.post('/webhook', handleWebhook);
router.get('/success', paymentSuccess);
router.get('/cancel',paymentCancel);

export default router;