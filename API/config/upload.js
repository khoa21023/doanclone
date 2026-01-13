// config/upload.js
import multer from 'multer';
import path from 'path';

const storage = multer.diskStorage({
    destination: (_, __, cb) => { // Dùng dấu gạch dưới cho biến không dùng
        cb(null, 'uploads/avatar/'); // Sửa đường dẫn để vào đúng thư mục avatar cậu đã tạo
    },
    filename: (_, file, cb) => {
        cb(null, 'avatar-' + Date.now() + path.extname(file.originalname));
    }
});

const upload = multer({ storage: storage });

export default upload; // <--- Cậu phải có dòng này