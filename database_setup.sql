
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'moblie_tech_ct')
BEGIN
    CREATE DATABASE [moblie_tech_ct]
END
GO

USE [moblie_tech_ct]
GO

-- 2. Bảng Danh Mục
CREATE TABLE [danhmuc] (
    [Id] varchar(20) NOT NULL PRIMARY KEY,
    [TenDanhMuc] nvarchar(100) NOT NULL, -- Dùng nvarchar để lưu tiếng Việt
    [HinhAnh] varchar(500) NULL
);
GO

-- 3. Bảng Người Dùng
CREATE TABLE [nguoidung] (
    [Id] varchar(20) NOT NULL PRIMARY KEY,
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
    [Id] varchar(20) NOT NULL PRIMARY KEY,
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
    [token] varchar(500) NOT NULL PRIMARY KEY,
    [NgayThuHoi] datetime DEFAULT GETDATE()
);
GO

-- 6. Bảng Sản Phẩm
CREATE TABLE [sanpham] (
    [Id] varchar(20) NOT NULL PRIMARY KEY,
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
    [SoLuotXem] int DEFAULT 0,
    FOREIGN KEY ([DanhMucId]) REFERENCES [danhmuc]([Id])
);
GO