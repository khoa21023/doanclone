import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import bodyParser from 'body-parser';
import fileUpload from 'express-fileupload';
import fs from 'fs';

// --- IMPORT CÁC ROUTES ---
import productRoutes from './routes/productRoutes.js';
import cartRoutes from './routes/cartRoutes.js';
import userRoutes from './routes/userRoutes.js';
import orderRoutes from './routes/orderRoutes.js'; // BƯỚC 1: Thêm dòng này

dotenv.config();
const app = express();
const PORT = process.env.PORT || 3000;

// --- MIDDLEWARE ---
app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(fileUpload());

// Tạo thư mục uploads nếu chưa có
if (!fs.existsSync('./uploads')) {
    fs.mkdirSync('./uploads');
}
app.use('/uploads', express.static('uploads'));

// --- ĐỊNH NGHĨA ROUTES ---
app.use('/api/products', productRoutes);
app.use('/api/cart', cartRoutes);
app.use('/api/users', userRoutes); // BƯỚC 2: Mở comment dòng này
app.use('/api/orders', orderRoutes);

// Route kiểm tra server
app.get('/', (req, res) => {
    res.send('Server Mobile Tech đang chạy...');
});

app.listen(PORT, () => {
    console.log(`🚀 Server is running on: http://localhost:${PORT}`);
});