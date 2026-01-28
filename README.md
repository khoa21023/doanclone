# Mobile Tech CT

Ứng dụng thương mại điện tử bán phụ kiện công nghệ được phát triển với Flutter và Node.js.

## Mục lục

- [Giới thiệu](#-giới-thiệu)
- [Tính năng](#-tính-năng)
- [Công nghệ sử dụng](#-công-nghệ-sử-dụng)
- [Cấu trúc dự án](#-cấu-trúc-dự-án)
- [Cài đặt](#-cài-đặt)
- [Cấu hình](#-cấu-hình)
- [Chạy ứng dụng](#-chạy-ứng-dụng)
- [API Endpoints](#-api-endpoints)
- [Ảnh chụp màn hình](#-ảnh-chụp-màn-hình)
- [Đóng góp](#-đóng-góp)
- [Giấy phép](#-giấy-phép)

## Giới thiệu

Mobile Tech CT là ứng dụng mua sắm phụ kiện công nghệ với giao diện hiện đại, hỗ trợ đa nền tảng (Android, iOS, Web). Ứng dụng cho phép người dùng duyệt sản phẩm, thêm vào giỏ hàng, đặt hàng và thanh toán trực tuyến.

## Tính năng

### Người dùng
- Đăng ký / Đăng nhập với JWT authentication
- Quản lý thông tin cá nhân & ảnh đại diện
- Xem lịch sử đơn hàng

### Mua sắm
- Duyệt sản phẩm theo danh mục
- Tìm kiếm sản phẩm
- Xem chi tiết & đánh giá sản phẩm
- Quản lý sản phẩm yêu thích

### Giỏ hàng & Đặt hàng
- Thêm/Xóa sản phẩm trong giỏ hàng
- Áp dụng mã khuyến mãi
- Đặt hàng với nhiều trạng thái theo dõi

### Thanh toán
- Thanh toán khi nhận hàng (COD)
- Thanh toán online qua PayOS

### Quản trị (Admin)
- Quản lý sản phẩm & danh mục
- Quản lý đơn hàng
- Quản lý người dùng
- Quản lý khuyến mãi

## Công nghệ sử dụng

### Frontend (Mobile App)
| Công nghệ | Phiên bản | Mô tả |
|-----------|-----------|-------|
| Flutter | ^3.9.2 | Framework UI đa nền tảng |
| Provider | ^6.1.5 | State management |
| HTTP | ^1.6.0 | HTTP client |
| Shared Preferences | ^2.5.4 | Lưu trữ local |
| Image Picker | ^1.2.1 | Chọn ảnh từ thiết bị |
| URL Launcher | ^6.3.2 | Mở link ngoài |
| App Links | ^6.4.1 | Deep linking |

### Backend (REST API)
| Công nghệ | Phiên bản | Mô tả |
|-----------|-----------|-------|
| Node.js | - | Runtime JavaScript |
| Express | ^4.18.2 | Web framework |
| MySQL2 | ^3.9.1 | Database connector |
| JWT | ^9.0.2 | Authentication |
| Bcrypt | ^5.1.1 | Password hashing |
| PayOS | ^1.0.10 | Cổng thanh toán |
| Multer | ^2.0.2 | Upload file |

### Database
- MySQL/MariaDB với các bảng chính: `NguoiDung`, `SanPham`, `DanhMuc`, `DonHang`, `ChiTietDonHang`, `GioHang`, `YeuThich`, `DanhGia`, `KhuyenMai`, `ThanhToan`

## Cấu trúc dự án

```
mobiel_tech_ct/
├── API/                    # Backend Node.js
│   ├── config/             # Cấu hình database
│   ├── controllers/        # Xử lý logic nghiệp vụ
│   │   ├── cartController.js
│   │   ├── favoriteController.js
│   │   ├── orderController.js
│   │   ├── paymentController.js
│   │   ├── productController.js
│   │   ├── promotionController.js
│   │   └── userController.js
│   ├── middleware/         # Middleware (auth, ...)
│   ├── models/             # Data models
│   ├── routes/             # API routes
│   ├── index.js            # Entry point
│   └── package.json
│
├── GiaoDien/               # Frontend Flutter
│   ├── lib/
│   │   ├── data/           # Data layer (API, models)
│   │   ├── features/       # Tính năng theo module
│   │   │   ├── admin/      # Module quản trị
│   │   │   ├── auth/       # Module xác thực
│   │   │   └── client/     # Module khách hàng
│   │   └── main.dart       # Entry point
│   ├── assets/             # Tài nguyên (hình ảnh, ...)
│   └── pubspec.yaml
│
├── Database/               # Database scripts
│   └── database_setup.sql  # Script tạo database
│
└── README.md
```

## Cài đặt

### Yêu cầu hệ thống
- Node.js >= 18.x
- Flutter SDK >= 3.9.2
- MySQL >= 8.0 hoặc MariaDB >= 10.4
- Git

### 1. Clone repository

```bash
git clone https://github.com/your-username/mobiel_tech_ct.git
cd mobiel_tech_ct
```

### 2. Cài đặt Database

```bash
# Đăng nhập MySQL
mysql -u root -p

# Tạo database và import dữ liệu
source Database/database_setup.sql
```

### 3. Cài đặt Backend

```bash
cd API
npm install
```

### 4. Cài đặt Frontend

```bash
cd GiaoDien
flutter pub get
```

## Cấu hình

### Backend (.env)

Tạo file `.env` trong thư mục `API/`:

```env
PORT=3000
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=your_password
DB_NAME=mobile_tech_ct
JWT_SECRET=your_secret_key

# PayOS Configuration
PAYOS_CLIENT_ID=your_client_id
PAYOS_API_KEY=your_api_key
PAYOS_CHECKSUM_KEY=your_checksum_key
```

### Frontend

Cập nhật base URL API trong file cấu hình Flutter (nếu cần):

```dart
// lib/data/api_config.dart
const String baseUrl = 'http://localhost:3000/api';
```

## Chạy ứng dụng

### Chạy Backend

```bash
cd API

# Development mode (với hot reload)
npm run dev

# Production mode
npm start
```

Server sẽ chạy tại: `http://localhost:3000`

### Chạy Frontend

```bash
cd GiaoDien

# Chạy trên thiết bị/emulator
flutter run

# Chạy trên web
flutter run -d chrome

# Chạy trên Windows
flutter run -d windows
```

## API Endpoints

### Authentication
| Method | Endpoint | Mô tả |
|--------|----------|-------|
| POST | `/api/users/register` | Đăng ký tài khoản |
| POST | `/api/users/login` | Đăng nhập |
| POST | `/api/users/logout` | Đăng xuất |
| GET | `/api/users/profile` | Lấy thông tin user |
| PUT | `/api/users/profile` | Cập nhật thông tin |

### Products
| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/api/products` | Lấy danh sách sản phẩm |
| GET | `/api/products/:id` | Chi tiết sản phẩm |
| GET | `/api/products/category/:id` | Sản phẩm theo danh mục |

### Cart
| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/api/cart` | Lấy giỏ hàng |
| POST | `/api/cart` | Thêm vào giỏ |
| PUT | `/api/cart/:id` | Cập nhật số lượng |
| DELETE | `/api/cart/:id` | Xóa khỏi giỏ |

### Orders
| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/api/orders` | Lấy danh sách đơn hàng |
| POST | `/api/orders` | Tạo đơn hàng mới |
| PUT | `/api/orders/:id/status` | Cập nhật trạng thái |

### Favorites
| Method | Endpoint | Mô tả |
|--------|----------|-------|
| GET | `/api/favorites` | Lấy danh sách yêu thích |
| POST | `/api/favorites` | Thêm yêu thích |
| DELETE | `/api/favorites/:id` | Xóa yêu thích |

### Payment
| Method | Endpoint | Mô tả |
|--------|----------|-------|
| POST | `/api/payment/create` | Tạo link thanh toán |
| POST | `/api/payment/webhook` | Webhook PayOS |

## Đóng góp

Mọi đóng góp đều được chào đón! Vui lòng:

1. Fork repository
2. Tạo branch mới (`git checkout -b feature/TinhNangMoi`)
3. Commit thay đổi (`git commit -m 'Thêm tính năng mới'`)
4. Push lên branch (`git push origin feature/TinhNangMoi`)
5. Tạo Pull Request

---