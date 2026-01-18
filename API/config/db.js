import mysql from 'mysql2/promise';
import dotenv from 'dotenv';
dotenv.config();

const db = mysql.createPool({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    database: process.env.DB_NAME,
    port: process.env.DB_PORT || 3306, // [Quan trọng] Thêm dòng này để đọc port từ Render
    ssl: {
        rejectUnauthorized: false // [Quan trọng] Cần thiết cho Aiven để chấp nhận kết nối SSL
    },
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

export const execute = async (sql, params) => {
    const [rows] = await db.execute(sql, params);
    return rows;
};

export default db;