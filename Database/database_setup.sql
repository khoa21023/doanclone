
-- 1. Khởi tạo databases
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'moblie_tech_ct')
BEGIN
    CREATE DATABASE [moblie_tech_ct]
END
GO

USE [moblie_tech_ct]
GO

-- 2. Bảng Danh Mục
CREATE TABLE [danhmuc] (
    [Id] varchar(20) NOT NULL,
    [TenDanhMuc] nvarchar(100) NOT NULL, -- Dùng nvarchar để lưu tiếng Việt
    [HinhAnh] varchar(500) NULL
);
GO

-- 3. Bảng Người Dùng
CREATE TABLE [nguoidung] (
    [Id] varchar(20) NOT NULL,
    [Email] varchar(100) NOT NULL UNIQUE,
    [MatKhau] varchar(255) NOT NULL,
    [HoTen] nvarchar(100) NULL,
    [SoDienThoai] varchar(20) NULL,
    [VaiTro] varchar(20) DEFAULT 'KhachHang',
    [DiaChi] nvarchar(MAX) NULL,
    [AnhDaiDien] varchar(255) NULL,
    [NgayTao] datetime DEFAULT GETDATE()
);
GO

-- 4. Bảng Khuyến Mãi
CREATE TABLE [khuyenmai] (
    [Id] varchar(20) NOT NULL,
    [MaCode] varchar(20) NOT NULL UNIQUE,
    [SoTienGiam] decimal(18,0) NULL,
    [DonToiThieu] decimal(18,0) DEFAULT 0,
    [SoLuong] int DEFAULT 100,
    [NgayBatDau] datetime NULL,
    [NgayKetThuc] datetime NULL
);
GO

-- 5. Bảng Revoked Tokens
CREATE TABLE [revoked_tokens] (
    [token] varchar(500) NOT NULL,
    [NgayThuHoi] datetime DEFAULT GETDATE()
);
GO

-- 6. Bảng Sản Phẩm
CREATE TABLE [sanpham] (
    [Id] varchar(20) NOT NULL,
    [DanhMucId] varchar(20) NULL,
    [TenSanPham] nvarchar(255) NOT NULL,
    [GiaBan] decimal(18,0) NOT NULL,
    [GiaGoc] decimal(18,0) NULL,
    [TonKho] int DEFAULT 0,
    [HinhAnh] varchar(500) NULL,
    [MoTa] nvarchar(MAX) NULL,
    [MauSac] nvarchar(50) NULL,
    [TuongThich] nvarchar(255) NULL,
    [ThongSo] nvarchar(MAX) NULL,
    [TrangThai] bit DEFAULT 1, -- SQL Server dùng bit thay cho tinyint cho boolean
    [NgayTao] datetime DEFAULT GETDATE(),
    [SoLuotXem] int DEFAULT 0
);
GO

-- 7. Bảng Đánh giá
CREATE TABLE [danhgia] (
    [Id] varchar(20) NOT NULL,
    [SanPhamId] varchar(20) NOT NULL,
    [NguoiDungId] varchar(20) NOT NULL,
    [SoSao] int DEFAULT 5,
    [NoiDung] nvarchar(MAX) NULL,
    [NgayTao] datetime DEFAULT GETDATE()
);
GO

-- 8. Bảng đơn hàng
CREATE TABLE [donhang] (
    [Id] varchar(20) NOT NULL,
    [NguoiDungId] varchar(20) NOT NULL,
    [TenNguoiNhan] nvarchar(100) NULL,
    [SdtNguoiNhan] varchar(20) NULL,
    [DiaChiGiao] nvarchar(MAX) NULL,
    [TongTienHang] decimal(18,0) DEFAULT 0,
    [PhiShip] decimal(18,0) DEFAULT 30000,
    [GiamGia] decimal(18,0) DEFAULT 0,
    [ThanhTien] decimal(18,0) DEFAULT 0,
    [MaKhuyenMai] varchar(20) NULL,
    [TrangThaiDonHang] nvarchar(50) DEFAULT N'ChoXacNhan',
    [TrangThaiThanhToan] nvarchar(50) DEFAULT N'Chưa thanh toán',
    [NgayDat] datetime DEFAULT GETDATE()
);
GO
-- 9. Bảng chi tiết đơn hàng
CREATE TABLE [chitietdonhang] (
    [Id] varchar(20) NOT NULL,
    [DonHangId] varchar(20) NOT NULL,
    [SanPhamId] varchar(20) NOT NULL,
    [TenSanPham] nvarchar(255) NULL,
    [SoLuong] int NOT NULL,
    [GiaLucMua] decimal(18,0) NOT NULL,
    [ThanhTien] decimal(18,0) NULL
);
GO
-- 10. Bảng giỏ hàng
CREATE TABLE [giohang] (
    [Id] varchar(20) NOT NULL,
    [NguoiDungId] varchar(20) NOT NULL,
    [SanPhamId] varchar(20) NOT NULL,
    [SoLuong] int DEFAULT 1,
    [NgayThem] datetime DEFAULT GETDATE()
);
GO
-- 11. Bảng thanh toán
CREATE TABLE [thanhtoan] (
    [Id] varchar(20) NOT NULL,
    [DonHangId] varchar(20) NOT NULL,
    [PhuongThuc] nvarchar(50) DEFAULT 'COD',
    [MaGiaoDichNganHang] varchar(100) NULL,
    [SoTienThanhToan] decimal(18,0) NULL,
    [NgayThanhToan] datetime DEFAULT GETDATE(),
    [GhiChu] nvarchar(MAX) NULL,
    [TrangThai] nvarchar(50) DEFAULT N'ThanhCong'
);
GO
--12. Bảng yêu thích
CREATE TABLE [yeuthich] (
    [NguoiDungId] varchar(20) NOT NULL,
    [SanPhamId] varchar(20) NOT NULL,
    [NgayThem] datetime DEFAULT GETDATE()
);
GO
-- nguoidung
ALTER TABLE nguoidung
  ADD PRIMARY KEY (Id),
  ADD UNIQUE KEY Email (Email);

-- danhmuc
ALTER TABLE danhmuc
  ADD PRIMARY KEY (Id);

-- khuyenmai
ALTER TABLE khuyenmai
  ADD PRIMARY KEY (Id),
  ADD UNIQUE KEY MaCode (MaCode);

-- revoked_tokens
ALTER TABLE revoked_tokens
  ADD PRIMARY KEY (token);

-- sanpham
ALTER TABLE sanpham
  ADD PRIMARY KEY (Id),
  ADD KEY DanhMucId (DanhMucId);

-- donhang
ALTER TABLE donhang
  ADD PRIMARY KEY (Id),
  ADD KEY NguoiDungId (NguoiDungId),
  ADD KEY idx_MaKhuyenMai (MaKhuyenMai);

-- chitietdonhang
ALTER TABLE chitietdonhang
  ADD PRIMARY KEY (Id),
  ADD KEY DonHangId (DonHangId),
  ADD KEY SanPhamId (SanPhamId);

-- giohang
ALTER TABLE giohang
  ADD PRIMARY KEY (Id),
  ADD KEY NguoiDungId (NguoiDungId),
  ADD KEY SanPhamId (SanPhamId);

-- danhgia
ALTER TABLE danhgia
  ADD PRIMARY KEY (Id),
  ADD KEY SanPhamId (SanPhamId),
  ADD KEY NguoiDungId (NguoiDungId);

-- yeuthich
ALTER TABLE yeuthich
  ADD PRIMARY KEY (NguoiDungId, SanPhamId),
  ADD KEY SanPhamId (SanPhamId);

-- thanhtoan
ALTER TABLE thanhtoan
  ADD PRIMARY KEY (Id),
  ADD KEY DonHangId (DonHangId);
