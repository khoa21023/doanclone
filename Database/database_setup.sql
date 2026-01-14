-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Máy chủ: 127.0.0.1
-- Thời gian đã tạo: Th1 13, 2026 lúc 03:10 PM
-- Phiên bản máy phục vụ: 10.4.32-MariaDB
-- Phiên bản PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Cơ sở dữ liệu: `mobile_tech_ct`
--

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `chitietdonhang`
--

CREATE TABLE `chitietdonhang` (
  `Id` varchar(20) NOT NULL,
  `DonHangId` varchar(20) NOT NULL,
  `SanPhamId` varchar(20) NOT NULL,
  `TenSanPham` varchar(255) DEFAULT NULL,
  `SoLuong` int(11) NOT NULL,
  `GiaLucMua` decimal(18,0) NOT NULL,
  `ThanhTien` decimal(18,0) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `chitietdonhang`
--

INSERT INTO `chitietdonhang` (`Id`, `DonHangId`, `SanPhamId`, `TenSanPham`, `SoLuong`, `GiaLucMua`, `ThanhTien`) VALUES
('CT01', 'DH01', 'SP01', 'AirPods Pro Gen 2', 1, 5900000, 5900000),
('CT02', 'DH02', 'SP06', 'Chuột Logitech MX 3S', 1, 2200000, 2200000),
('CT03', 'DH02', 'SP07', 'Phím cơ Keychron K2', 1, 1850000, 1850000),
('CT04', 'DH03', 'SP09', 'Sony WH-1000XM5', 1, 7990000, 7990000),
('CT05', 'DH04', 'SP04', 'Ốp lưng iPhone 15', 1, 350000, 350000),
('CT06', 'DH04', 'SP08', 'Kính cường lực 15 Pro', 1, 120000, 120000),
('CT07', 'DH05', 'SP05', 'Sạc dự phòng 10k mAh', 1, 850000, 850000),
('CT08', 'DH05', 'SP17', 'Bút Stylus cho iPad', 1, 400000, 400000),
('CT09', 'DH06', 'SP06', 'Chuột Logitech MX 3S', 1, 2200000, 2200000),
('CT10', 'DH07', 'SP05', 'Sạc dự phòng 10k mAh', 1, 850000, 850000),
('CT11', 'DH08', 'SP16', 'Hub USB-C 7 in 1', 1, 550000, 550000),
('CT12', 'DH09', 'SP07', 'Phím cơ Keychron K2', 1, 1850000, 1850000),
('CT13', 'DH10', 'SP19', 'Tai nghe Gaming RGB', 1, 950000, 950000),
('CTect5ojj6n', 'DH1768194560538', 'SP01', 'AirPods Pro Gen 2', 1, 5900000, 5900000),
('CTg0ux7nly7', 'DH1768153270193', 'SP01', 'AirPods Pro Gen 2', 1, 5900000, 5900000),
('CTljx1iy260', 'DH1768161881580', 'SP01', 'AirPods Pro Gen 2', 5, 5900000, 29500000),
('CTtwrfw23ce', 'DH1768157886713', 'SP01', 'AirPods Pro Gen 2', 4, 5900000, 23600000);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `danhgia`
--

CREATE TABLE `danhgia` (
  `Id` varchar(20) NOT NULL,
  `SanPhamId` varchar(20) NOT NULL,
  `NguoiDungId` varchar(20) NOT NULL,
  `SoSao` int(11) DEFAULT 5,
  `NoiDung` text DEFAULT NULL,
  `NgayTao` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `danhgia`
--

INSERT INTO `danhgia` (`Id`, `SanPhamId`, `NguoiDungId`, `SoSao`, `NoiDung`, `NgayTao`) VALUES
('DG01', 'SP01', 'U02', 5, 'Tai nghe nghe rất hay, chống ồn tốt!', '2026-01-09 08:30:00'),
('DG02', 'SP06', 'U03', 4, 'Chuột dùng êm, nhưng hơi to so với tay mình.', '2026-01-09 10:15:00'),
('DG03', 'SP09', 'U04', 5, 'Chất lượng Sony thì không phải bàn cãi.', '2026-01-09 14:00:00');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `danhmuc`
--

CREATE TABLE `danhmuc` (
  `Id` varchar(20) NOT NULL,
  `TenDanhMuc` varchar(100) NOT NULL,
  `HinhAnh` varchar(500) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `danhmuc`
--

INSERT INTO `danhmuc` (`Id`, `TenDanhMuc`, `HinhAnh`) VALUES
('DM01', 'Âm thanh', 'audio.png'),
('DM02', 'Sạc & Cáp', 'charging.png'),
('DM03', 'Ốp lưng & Bao da', 'case.png'),
('DM04', 'Chuột & Bàn phím', 'peripherals.png');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `donhang`
--

CREATE TABLE `donhang` (
  `Id` varchar(20) NOT NULL,
  `NguoiDungId` varchar(20) NOT NULL,
  `TenNguoiNhan` varchar(100) DEFAULT NULL,
  `SdtNguoiNhan` varchar(20) DEFAULT NULL,
  `DiaChiGiao` text DEFAULT NULL,
  `TongTienHang` decimal(18,0) DEFAULT NULL,
  `PhiShip` decimal(18,0) DEFAULT 30000,
  `GiamGia` decimal(18,0) DEFAULT 0,
  `ThanhTien` decimal(18,0) DEFAULT NULL,
  `MaKhuyenMai` varchar(20) DEFAULT NULL,
  `TrangThaiDonHang` varchar(50) DEFAULT 'ChoXacNhan',
  `TrangThaiThanhToan` text DEFAULT '\'Chưa thanh toán\'',
  `NgayDat` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `donhang`
--

INSERT INTO `donhang` (`Id`, `NguoiDungId`, `TenNguoiNhan`, `SdtNguoiNhan`, `DiaChiGiao`, `TongTienHang`, `PhiShip`, `GiamGia`, `ThanhTien`, `MaKhuyenMai`, `TrangThaiDonHang`, `TrangThaiThanhToan`, `NgayDat`) VALUES
('DH01', 'U02', 'Trần Văn Khách', '0988777666', 'Quận 1, TP.HCM', 5900000, 30000, 100000, 5830000, NULL, 'DaGiao', '1', '2026-01-08 14:01:01'),
('DH02', 'U03', 'Lê Thị Lan', '0905111222', 'Cầu Giấy, Hà Nội', 4050000, 30000, 50000, 4030000, NULL, 'ChoXacNhan', '0', '2026-01-08 14:01:01'),
('DH03', 'U04', 'Phạm Minh Tuấn', '0934555666', 'Hải Châu, Đà Nẵng', 7990000, 0, 200000, 7790000, NULL, 'ChoGiaoHang', '1', '2026-01-08 14:01:01'),
('DH04', 'U02', 'Trần Văn Khách', '0988777666', 'Quận 1, TP.HCM', 470000, 30000, 30000, 470000, NULL, 'DangGiao', '0', '2026-01-08 14:01:01'),
('DH05', 'U05', 'Nguyễn Huy Hoàng', '0977888999', 'Ninh Kiều, Cần Thơ', 1250000, 30000, 20000, 1260000, NULL, 'ChoXacNhan', '0', '2026-01-08 14:01:01'),
('DH06', 'U03', 'Lê Thị Lan', '0905111222', 'Cầu Giấy, Hà Nội', 2200000, 0, 30000, 2170000, NULL, 'DaGiao', '1', '2026-01-08 14:01:01'),
('DH07', 'U04', 'Phạm Minh Tuấn', '0934555666', 'Hải Châu, Đà Nẵng', 850000, 30000, 0, 880000, NULL, 'DaHuy', '0', '2026-01-08 14:01:01'),
('DH08', 'U05', 'Nguyễn Huy Hoàng', '0977888999', 'Ninh Kiều, Cần Thơ', 550000, 30000, 30000, 550000, NULL, 'ChoGiaoHang', '1', '2026-01-08 14:01:01'),
('DH09', 'U02', 'Trần Văn Khách', '0988777666', 'Quận 1, TP.HCM', 1850000, 30000, 150000, 1730000, NULL, 'DangGiao', '1', '2026-01-08 14:01:01'),
('DH10', 'U03', 'Lê Thị Lan', '0905111222', 'Cầu Giấy, Hà Nội', 950000, 30000, 50000, 930000, NULL, 'ChoXacNhan', '0', '2026-01-08 14:01:01'),
('DH1768153270193', 'U1768044744510', NULL, '0901234567', '99 Tô Ký, Quận 12, TP.HCM', NULL, 30000, 0, 5900000, NULL, 'ChoXacNhan', '0', '2026-01-12 00:41:10'),
('DH1768157886713', 'U1768044744510', 'Nguyễn Văn Test', '0912345678', '123 Đường ABC, Quận 12', 23600000, 5000, 0, 23605000, NULL, 'ChoXacNhan', '0', '2026-01-12 01:58:06'),
('DH1768161881580', 'U1768161171082', 'Nguyễn Văn Test', '0912345678', '123 Đường ABC, Quận 12', 29500000, 5000, 0, 29505000, NULL, 'ChoXacNhan', '0', '2026-01-12 03:04:41'),
('DH1768194560538', 'U1768161171082', 'Tên Người Nhận', '0912345678', 'Địa chỉ nhận hàng', 5900000, 30000, 0, 5930000, NULL, 'ChoXacNhan', '0', '2026-01-12 12:09:20');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `giohang`
--

CREATE TABLE `giohang` (
  `Id` varchar(20) NOT NULL,
  `NguoiDungId` varchar(20) NOT NULL,
  `SanPhamId` varchar(20) NOT NULL,
  `SoLuong` int(11) DEFAULT 1,
  `NgayThem` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `giohang`
--

INSERT INTO `giohang` (`Id`, `NguoiDungId`, `SanPhamId`, `SoLuong`, `NgayThem`) VALUES
('GH1768137135949', 'U1768123282852', 'SP02', 3, '2026-01-11 20:12:15'),
('GH1768160120218', 'U1768044744510', 'SP02', 1, '2026-01-12 02:35:20'),
('GH1768162140541', 'U1768161171082', 'SP01', 1, '2026-01-12 03:09:00'),
('GH1768216511066', 'U1768214513859', 'SP01', 2, '2026-01-12 18:15:11');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `khuyenmai`
--

CREATE TABLE `khuyenmai` (
  `Id` varchar(20) NOT NULL,
  `MaCode` varchar(20) NOT NULL,
  `SoTienGiam` decimal(18,0) DEFAULT NULL,
  `DonToiThieu` decimal(18,0) DEFAULT 0,
  `SoLuong` int(11) DEFAULT 100,
  `NgayBatDau` datetime DEFAULT NULL,
  `NgayKetThuc` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `nguoidung`
--

CREATE TABLE `nguoidung` (
  `Id` varchar(20) NOT NULL,
  `Email` varchar(100) NOT NULL,
  `MatKhau` varchar(255) NOT NULL,
  `HoTen` varchar(100) DEFAULT NULL,
  `SoDienThoai` varchar(20) DEFAULT NULL,
  `VaiTro` varchar(20) DEFAULT 'KhachHang',
  `DiaChi` text DEFAULT NULL,
  `AnhDaiDien` varchar(255) DEFAULT NULL,
  `NgayTao` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `nguoidung`
--

INSERT INTO `nguoidung` (`Id`, `Email`, `MatKhau`, `HoTen`, `SoDienThoai`, `VaiTro`, `DiaChi`, `AnhDaiDien`, `NgayTao`) VALUES
('U01', 'admin@shop.com', '$2b$10$prVLMA5fyWCRaifETGMcI.qbk6frE18HXMw5VyK3X5RafCEWzFy3e', 'Nguyễn Admin', '0911222333', 'Admin', 'Hà Nội', 'image.jpg', '2026-01-08 14:01:01'),
('U02', 'khach1@gmail.com', '$2b$10$TByI0Rj5fS8Fbjn8/2fCyee6IJwm6WymGADtKC8Rc6yHrshQjpGZK', 'Trần Văn Khách', '0988777666', 'KhachHang', 'TP.HCM', NULL, '2026-01-08 14:01:01'),
('U03', 'lan.le@gmail.com', '$2b$10$TByI0Rj5fS8Fbjn8/2fCyee6IJwm6WymGADtKC8Rc6yHrshQjpGZK', 'Lê Thị Lan', '0905111222', 'KhachHang', 'Hà Nội', NULL, '2026-01-08 14:01:01'),
('U04', 'tuan.pham@yahoo.com', '$2b$10$TByI0Rj5fS8Fbjn8/2fCyee6IJwm6WymGADtKC8Rc6yHrshQjpGZK', 'Phạm Minh Tuấn', '0934555666', 'KhachHang', 'Đà Nẵng', NULL, '2026-01-08 14:01:01'),
('U05', 'hoang.nguyen@gmail.com', '$2b$10$TByI0Rj5fS8Fbjn8/2fCyee6IJwm6WymGADtKC8Rc6yHrshQjpGZK', 'Nguyễn Huy Hoàng', '0977888999', 'KhachHang', 'Hà Nội', NULL, '2026-01-08 14:01:01'),
('U1768044744510', 'helooo@gmail.com', '$2b$10$TByI0Rj5fS8Fbjn8/2fCyee6IJwm6WymGADtKC8Rc6yHrshQjpGZK', 'Doraemon Updated', '0987654321', 'KhachHang', 'Hành tinh 2112', NULL, '2026-01-10 18:32:24'),
('U1768123282852', 'admin@gmail.com', '$2b$10$prVLMA5fyWCRaifETGMcI.qbk6frE18HXMw5VyK3X5RafCEWzFy3e', 'Admin', '0123456789', 'Admin', 'Số 1 Nguyễn Trãi, Hà Nội', NULL, '2026-01-11 16:21:22'),
('U1768161171082', 'mon@gmail.com', '$2b$10$.soH6y6t5SYyClRkp7Ssf.hDOyyEcSjd8bBsoiFyuxhQCdux1d0GO', 'Doraemon', '0987654321', 'KhachHang', 'Số 1 Dãy Ngân Hà', NULL, '2026-01-12 02:52:51'),
('U1768214513859', 'heloo@gmail.com', '$2b$10$r1oMURRjcKmRAfhGRmKw..sz8o4oHahocG4of7Krz3uXyopICvxKa', 'Doraemon Updated', '0987654321', 'KhachHang', 'Hành tinh 2112', NULL, '2026-01-12 17:41:53');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `revoked_tokens`
--

CREATE TABLE `revoked_tokens` (
  `token` varchar(500) NOT NULL,
  `NgayThuHoi` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `revoked_tokens`
--

INSERT INTO `revoked_tokens` (`token`, `NgayThuHoi`) VALUES
('eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6IlUxNzY4MTYxMTcxMDgyIiwicm9sZSI6IktoYWNoSGFuZyIsImlhdCI6MTc2ODE2MTE5NSwiZXhwIjoxNzY4MjQ3NTk1fQ.Cu5dBdnh3egbwF26uUXj9cBUa-89QQJFABxTdIjaPAE', '2026-01-12 02:53:38');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `sanpham`
--

CREATE TABLE `sanpham` (
  `Id` varchar(20) NOT NULL,
  `DanhMucId` varchar(20) DEFAULT NULL,
  `TenSanPham` varchar(255) NOT NULL,
  `GiaBan` decimal(18,0) NOT NULL,
  `GiaGoc` decimal(18,0) DEFAULT NULL,
  `TonKho` int(11) DEFAULT 0,
  `HinhAnh` varchar(500) DEFAULT NULL,
  `MoTa` text DEFAULT NULL,
  `MauSac` varchar(50) DEFAULT NULL,
  `TuongThich` varchar(255) DEFAULT NULL,
  `ThongSo` text DEFAULT NULL,
  `TrangThai` tinyint(1) DEFAULT 1,
  `NgayTao` datetime DEFAULT current_timestamp(),
  `SoLuotXem` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `sanpham`
--

INSERT INTO `sanpham` (`Id`, `DanhMucId`, `TenSanPham`, `GiaBan`, `GiaGoc`, `TonKho`, `HinhAnh`, `MoTa`, `MauSac`, `TuongThich`, `ThongSo`, `TrangThai`, `NgayTao`, `SoLuotXem`) VALUES
('SP01', 'DM01', 'AirPods Pro Gen 2', 5900000, 6500000, 9, 'ap2.jpg', 'Chống ồn chủ động', 'Trắng', 'iOS', NULL, 1, '2026-01-10 08:00:00', 153),
('SP02', 'DM02', 'Sạc Anker Nano 20W', 250000, 350000, 50, 'anker.jpg', 'Sạc nhanh siêu nhỏ', 'Xanh', 'iPhone', NULL, 1, '2026-01-10 17:57:10', 0),
('SP03', 'DM02', 'Cáp sạc USB-C 1m', 450000, 550000, 100, 'cable.jpg', 'Chính hãng Apple', 'Trắng', 'Đa năng', NULL, 0, '2026-01-10 17:57:10', 0),
('SP04', 'DM03', 'Ốp lưng iPhone 15', 350000, 500000, 30, 'case15.jpg', 'Chống sốc cao cấp', 'Đen', 'iPhone 15', NULL, 1, '2026-01-10 17:57:10', 0),
('SP05', 'DM02', 'Sạc dự phòng 10k mAh', 850000, 1100000, 15, 'bank.jpg', 'Hỗ trợ sạc không dây', 'Xám', 'Đa năng', NULL, 1, '2026-01-10 17:57:10', 0),
('SP06', 'DM04', 'Chuột Logitech MX 3S', 2200000, 2500000, 10, 'mx3s.jpg', 'Chuột Silent cao cấp', 'Đen', 'PC/Mac', NULL, 1, '2026-01-10 17:57:10', 120),
('SP07', 'DM04', 'Phím cơ Keychron K2', 1850000, 2100000, 12, 'k2.jpg', 'Layout 75% gọn nhẹ', 'Xám', 'PC/Mac', NULL, 1, '2026-01-10 17:57:10', 0),
('SP08', 'DM03', 'Kính cường lực 15 Pro', 120000, 180000, 200, 'glass.jpg', 'Chống vỡ màn hình', 'Trong', 'iPhone 15', NULL, 1, '2026-01-10 17:57:10', 0),
('SP09', 'DM01', 'Sony WH-1000XM5', 7990000, 8900000, 5, 'xm5.jpg', 'Tai nghe chụp tai tốt nhất', 'Đen', 'Đa năng', NULL, 1, '2026-01-10 08:00:00', 200),
('SP10', 'DM02', 'Củ sạc Baseus 65W', 650000, 800000, 25, 'baseus.jpg', 'Sạc được cho Laptop', 'Đen', 'Laptop/ĐT', NULL, 1, '2026-01-10 17:57:10', 0),
('SP11', 'DM02', 'Cáp HDMI 8K 2m', 280000, 400000, 40, 'hdmi.jpg', 'Dây bọc dù siêu bền', 'Đen', 'TV/Monitor', NULL, 1, '2026-01-10 17:57:10', 0),
('SP12', 'DM01', 'Loa Marshall Emberton', 3800000, 4500000, 8, 'ms.jpg', 'Kháng nước chuẩn IPX7', 'Đen', 'Bluetooth', NULL, 1, '2026-01-10 08:00:00', 0),
('SP13', 'DM03', 'Túi chống sốc 14 inch', 250000, 350000, 60, 'bag.jpg', 'Lót nhung chống trầy', 'Xám', 'Laptop', NULL, 1, '2026-01-10 17:57:10', 0),
('SP14', 'DM03', 'Gậy Tripod P01', 180000, 250000, 100, 'tripod.jpg', 'Remote Bluetooth rời', 'Đen', 'Smartphone', NULL, 1, '2026-01-10 17:57:10', 0),
('SP15', 'DM02', 'Thẻ nhớ Sandisk 128GB', 320000, 450000, 80, 'sd.jpg', 'Chuẩn V30 quay phim 4K', 'Đỏ', 'Camera', NULL, 1, '2026-01-10 17:57:10', 0),
('SP16', 'DM02', 'Hub USB-C 7 in 1', 550000, 750000, 20, 'hub.jpg', 'Vỏ nhôm tản nhiệt tốt', 'Bạc', 'Macbook', NULL, 1, '2026-01-10 17:57:10', 0),
('SP17', 'DM03', 'Bút Stylus cho iPad', 450000, 600000, 15, 'pen.jpg', 'Cảm ứng độ nhạy cao', 'Trắng', 'iPad', NULL, 1, '2026-01-10 17:57:10', 0),
('SP18', 'DM04', 'Lót chuột cỡ lớn', 150000, 250000, 50, 'pad.jpg', 'Bề mặt vải Speed', 'Đen', 'PC', NULL, 1, '2026-01-10 17:57:10', 0),
('SP19', 'DM01', 'Tai nghe Gaming RGB', 950000, 1200000, 15, 'gaming.jpg', 'Âm thanh vòm 7.1', 'Đen', 'PC', NULL, 1, '2026-01-10 17:57:10', 0),
('SP20', 'DM02', 'Đế sạc 3 trong 1', 750000, 1000000, 10, '3in1.jpg', 'Sạc ĐT, Tai nghe, Watch', 'Đen', 'Apple', NULL, 1, '2026-01-10 17:57:10', 0);

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `thanhtoan`
--

CREATE TABLE `thanhtoan` (
  `Id` varchar(20) NOT NULL,
  `DonHangId` varchar(20) NOT NULL,
  `PhuongThuc` varchar(50) DEFAULT 'COD',
  `MaGiaoDich` varchar(100) DEFAULT NULL,
  `SoTienThanhToan` decimal(18,0) DEFAULT NULL,
  `NgayThanhToan` datetime DEFAULT current_timestamp(),
  `GhiChu` text DEFAULT NULL,
  `TrangThai` varchar(50) DEFAULT 'ThanhCong'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `thanhtoan`
--

INSERT INTO `thanhtoan` (`Id`, `DonHangId`, `PhuongThuc`, `MaGiaoDich`, `SoTienThanhToan`, `NgayThanhToan`, `GhiChu`, `TrangThai`) VALUES
('TT01', 'DH01', 'Banking', NULL, 5830000, '2026-01-08 14:01:01', NULL, 'ThanhCong'),
('TT02', 'DH03', 'Banking', NULL, 7790000, '2026-01-08 14:01:01', NULL, 'ThanhCong'),
('TT03', 'DH06', 'Banking', NULL, 2170000, '2026-01-08 14:01:01', NULL, 'ThanhCong'),
('TT04', 'DH08', 'COD', NULL, 550000, '2026-01-08 14:01:01', NULL, 'ThanhCong'),
('TT05', 'DH09', 'Banking', NULL, 1730000, '2026-01-08 14:01:01', NULL, 'ThanhCong');

-- --------------------------------------------------------

--
-- Cấu trúc bảng cho bảng `yeuthich`
--

CREATE TABLE `yeuthich` (
  `NguoiDungId` varchar(20) NOT NULL,
  `SanPhamId` varchar(20) NOT NULL,
  `NgayThem` datetime DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Đang đổ dữ liệu cho bảng `yeuthich`
--

INSERT INTO `yeuthich` (`NguoiDungId`, `SanPhamId`, `NgayThem`) VALUES
('U02', 'SP07', '2026-01-10 09:05:00'),
('U02', 'SP09', '2026-01-10 09:00:00'),
('U03', 'SP01', '2026-01-10 11:20:00'),
('U05', 'SP20', '2026-01-10 15:45:00'),
('U1768044744510', 'SP01', '2026-01-13 10:06:06');

--
-- Chỉ mục cho các bảng đã đổ
--

--
-- Chỉ mục cho bảng `chitietdonhang`
--
ALTER TABLE `chitietdonhang`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `DonHangId` (`DonHangId`),
  ADD KEY `SanPhamId` (`SanPhamId`);

--
-- Chỉ mục cho bảng `danhgia`
--
ALTER TABLE `danhgia`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `fk_danhgia_sanpham` (`SanPhamId`),
  ADD KEY `fk_danhgia_nguoidung` (`NguoiDungId`);

--
-- Chỉ mục cho bảng `danhmuc`
--
ALTER TABLE `danhmuc`
  ADD PRIMARY KEY (`Id`);

--
-- Chỉ mục cho bảng `donhang`
--
ALTER TABLE `donhang`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `NguoiDungId` (`NguoiDungId`),
  ADD KEY `idx_MaKhuyenMai` (`MaKhuyenMai`);

--
-- Chỉ mục cho bảng `giohang`
--
ALTER TABLE `giohang`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `NguoiDungId` (`NguoiDungId`),
  ADD KEY `SanPhamId` (`SanPhamId`);

--
-- Chỉ mục cho bảng `khuyenmai`
--
ALTER TABLE `khuyenmai`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `MaCode` (`MaCode`);

--
-- Chỉ mục cho bảng `nguoidung`
--
ALTER TABLE `nguoidung`
  ADD PRIMARY KEY (`Id`),
  ADD UNIQUE KEY `Email` (`Email`);

--
-- Chỉ mục cho bảng `revoked_tokens`
--
ALTER TABLE `revoked_tokens`
  ADD PRIMARY KEY (`token`);

--
-- Chỉ mục cho bảng `sanpham`
--
ALTER TABLE `sanpham`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `DanhMucId` (`DanhMucId`);

--
-- Chỉ mục cho bảng `thanhtoan`
--
ALTER TABLE `thanhtoan`
  ADD PRIMARY KEY (`Id`),
  ADD KEY `DonHangId` (`DonHangId`);

--
-- Chỉ mục cho bảng `yeuthich`
--
ALTER TABLE `yeuthich`
  ADD PRIMARY KEY (`NguoiDungId`,`SanPhamId`),
  ADD KEY `fk_yeuthich_sanpham` (`SanPhamId`);

--
-- Các ràng buộc cho các bảng đã đổ
--

--
-- Các ràng buộc cho bảng `chitietdonhang`
--
ALTER TABLE `chitietdonhang`
  ADD CONSTRAINT `chitietdonhang_ibfk_1` FOREIGN KEY (`DonHangId`) REFERENCES `donhang` (`Id`),
  ADD CONSTRAINT `chitietdonhang_ibfk_2` FOREIGN KEY (`SanPhamId`) REFERENCES `sanpham` (`Id`);

--
-- Các ràng buộc cho bảng `danhgia`
--
ALTER TABLE `danhgia`
  ADD CONSTRAINT `fk_danhgia_nguoidung` FOREIGN KEY (`NguoiDungId`) REFERENCES `nguoidung` (`Id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_danhgia_sanpham` FOREIGN KEY (`SanPhamId`) REFERENCES `sanpham` (`Id`) ON DELETE CASCADE;

--
-- Các ràng buộc cho bảng `donhang`
--
ALTER TABLE `donhang`
  ADD CONSTRAINT `donhang_ibfk_1` FOREIGN KEY (`NguoiDungId`) REFERENCES `nguoidung` (`Id`),
  ADD CONSTRAINT `fk_DonHang_KhuyenMai` FOREIGN KEY (`MaKhuyenMai`) REFERENCES `khuyenmai` (`MaCode`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Các ràng buộc cho bảng `giohang`
--
ALTER TABLE `giohang`
  ADD CONSTRAINT `giohang_ibfk_1` FOREIGN KEY (`NguoiDungId`) REFERENCES `nguoidung` (`Id`),
  ADD CONSTRAINT `giohang_ibfk_2` FOREIGN KEY (`SanPhamId`) REFERENCES `sanpham` (`Id`);

--
-- Các ràng buộc cho bảng `sanpham`
--
ALTER TABLE `sanpham`
  ADD CONSTRAINT `sanpham_ibfk_1` FOREIGN KEY (`DanhMucId`) REFERENCES `danhmuc` (`Id`);

--
-- Các ràng buộc cho bảng `thanhtoan`
--
ALTER TABLE `thanhtoan`
  ADD CONSTRAINT `thanhtoan_ibfk_1` FOREIGN KEY (`DonHangId`) REFERENCES `donhang` (`Id`);

--
-- Các ràng buộc cho bảng `yeuthich`
--
ALTER TABLE `yeuthich`
  ADD CONSTRAINT `fk_yeuthich_nguoidung` FOREIGN KEY (`NguoiDungId`) REFERENCES `nguoidung` (`Id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_yeuthich_sanpham` FOREIGN KEY (`SanPhamId`) REFERENCES `sanpham` (`Id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
