import db from '../config/db.js';
import { createRequire } from 'module';

const require = createRequire(import.meta.url);
const PayOSLib = require("@payos/node");
const PayOS = PayOSLib.PayOS || PayOSLib.default || PayOSLib;
// ---------------------------------------------

// Khởi tạo PayOS
const payos = new PayOS(
    process.env.PAYOS_CLIENT_ID,
    process.env.PAYOS_API_KEY,
    process.env.PAYOS_CHECKSUM_KEY
);

// 1. WEBHOOK
export const handleWebhook = async (req, res) => {
    console.log("Webhook received body:", req.body);

    try {
        // Kiểm tra hàm verify
        if (!payos.verifyPaymentWebhookData) {
            console.error("DEBUG PAYOS WEBHOOK:", payos);
            throw new Error("Lỗi thư viện: verifyPaymentWebhookData không tồn tại.");
        }

        const webhookData = payos.verifyPaymentWebhookData(req.body);

        // Nếu thanh toán thành công
        if (webhookData.desc === 'success' || webhookData.code === '00') {
            const paymentCode = webhookData.orderCode; 
            console.log(`Thanh toán thành công đơn: ${paymentCode}`);

            // Cập nhật bảng thanhtoan
            await db.query(
                "UPDATE thanhtoan SET TrangThai = 'ThanhCong' WHERE MaGiaoDich = ?", 
                [paymentCode]
            );

            // Cập nhật bảng donhang
            const sqlUpdateOrder = `
                UPDATE donhang 
                SET TrangThaiThanhToan = 'Đã thanh toán' 
                WHERE Id = (SELECT DonHangId FROM thanhtoan WHERE MaGiaoDich = ? LIMIT 1)
            `;
            await db.query(sqlUpdateOrder, [paymentCode]);
        }
        
        res.json({ success: true });

    } catch (error) {
        console.error("Lỗi Webhook:", error.message);
        res.json({ success: false, message: error.message }); 
    }
};

// 2. TRANG BÁO THÀNH CÔNG
export const paymentSuccess = (req, res) => {
    const packageName = "com.example.mobile_tech_ct"; 
    const scheme = "mobiletech";
    const path = "payment/success";
    const androidIntent = `intent://${path}#Intent;scheme=${scheme};package=${packageName};end`;
    const iosLink = `${scheme}://${path}`;

    res.send(`
        <html>
            <head>
                <meta name="viewport" content="width=device-width, initial-scale=1">
                <style>
                    body { font-family: Arial, sans-serif; text-align: center; padding-top: 50px; }
                    .btn {
                        display: inline-block;
                        background-color: #2563EB;
                        color: white;
                        padding: 12px 24px;
                        text-decoration: none;
                        border-radius: 8px;
                        font-weight: bold;
                        margin-top: 20px;
                    }
                </style>
            </head>
            <body>
                <h1 style="color:green">Thanh toán thành công!</h1>
                <p>Đang chuyển hướng về ứng dụng...</p>
                
                <a id="btn-app" href="${iosLink}" class="btn">Quay về ứng dụng ngay</a>

                <script>
                    // Phát hiện hệ điều hành
                    var userAgent = navigator.userAgent || navigator.vendor || window.opera;
                    var isAndroid = /android/i.test(userAgent);

                    var url = isAndroid ? "${androidIntent}" : "${iosLink}";
                    
                    // Cập nhật link cho nút bấm
                    document.getElementById('btn-app').href = url;

                    // Thử tự động chuyển hướng
                    setTimeout(function() {
                        window.location.replace(url);
                    }, 1000);
                </script>
            </body>
        </html>
    `);
};

// 3. TRANG BÁO HỦY
export const paymentCancel = (req, res) => {
    res.send(`
        <html>
            <head><meta name="viewport" content="width=device-width, initial-scale=1"></head>
            <body style="text-align:center; padding-top:50px;">
                <h1 style="color:red">Đã hủy thanh toán</h1>
                <script>
                    setTimeout(() => { window.location.href = "mobiletech://payment/cancel"; }, 1000);
                </script>
            </body>
        </html>
    `);
};