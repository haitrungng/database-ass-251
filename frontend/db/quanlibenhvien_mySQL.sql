-- SCRIPT 1: CẤU TRÚC + DỮ LIỆU CHO MYSQL
DROP DATABASE IF EXISTS quanlibenhvien;
CREATE DATABASE IF NOT EXISTS quanlibenhvien
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE quanlibenhvien;

-- ========= BẢNG =========

CREATE TABLE BenhVien (
  ID INT PRIMARY KEY,
  Ten NVARCHAR(100),
  DiaChi NVARCHAR(255)
);

CREATE TABLE BenhVien_SoDienThoai (
  BenhVien_ID INT NOT NULL,
  SoDienThoai_BenhVien VARCHAR(10) NOT NULL,
  PRIMARY KEY (BenhVien_ID, SoDienThoai_BenhVien),
  CONSTRAINT fk_bvsdt_bv_id FOREIGN KEY (BenhVien_ID) REFERENCES BenhVien(ID)
);

CREATE TABLE Khoa (
  ID INT,
  BenhVien_ID INT,
  TenKhoa NVARCHAR(100),
  ChuyenNganh NVARCHAR(100),
  PRIMARY KEY (ID, BenhVien_ID),
  CONSTRAINT fk_khoa_bv_bvid FOREIGN KEY (BenhVien_ID) REFERENCES BenhVien(ID)
);

CREATE TABLE KiNang (
  KiNang_ID INT PRIMARY KEY,
  TenKiNang NVARCHAR(100),
  MoTa LONGTEXT
);

CREATE TABLE KhoThuoc (
  ID INT PRIMARY KEY,
  TenKho NVARCHAR(100)
);

CREATE TABLE BenhNhan (
  ID INT PRIMARY KEY,
  HoTen NVARCHAR(100),
  GioiTinh NVARCHAR(10),
  NgaySinh DATE,
  DiaChi NVARCHAR(255),
  SoDienThoai VARCHAR(10),
  BaoHiemYTe VARCHAR(20),
  NgayHetHanBHYT DATE,
  CHECK (GioiTinh IN ('Nam','Nữ'))
);

CREATE TABLE NguoiThan (
  BenhNhan_ID INT,
  HoTen NVARCHAR(100),
  SoDienThoai VARCHAR(10),
  QuanHe NVARCHAR(50),
  PRIMARY KEY (BenhNhan_ID, HoTen),
  CONSTRAINT fk_nt_bn_bnid FOREIGN KEY (BenhNhan_ID) REFERENCES BenhNhan(ID)
);

CREATE TABLE NhanVien (
  ID CHAR(7) PRIMARY KEY,
  CCCD CHAR(12) UNIQUE NOT NULL,
  Ho NVARCHAR(50),
  Ten NVARCHAR(50),
  Dem NVARCHAR(50),
  NgaySinh DATE,
  GioiTinh NVARCHAR(10),
  SoDienThoai VARCHAR(10),
  BenhVien_ID INT NOT NULL,
  Khoa_ID INT NOT NULL,
  CHECK (ID REGEXP '^[A-Z]{2}[0-9]{5}$'),
  CHECK (GioiTinh IN ('Nam','Nữ')),
  CONSTRAINT fk_nv_bv_bvid
    FOREIGN KEY (Khoa_ID, BenhVien_ID) REFERENCES Khoa(ID, BenhVien_ID)
);

CREATE TABLE QuanLi (
  ID CHAR(7) PRIMARY KEY,
  QL_ID CHAR(7) NOT NULL,
  CONSTRAINT fk_ql_nv_id FOREIGN KEY (ID) REFERENCES NhanVien(ID),
  CONSTRAINT fk_ql_nv_qlid FOREIGN KEY (QL_ID) REFERENCES NhanVien(ID)
);

CREATE TABLE BacSi (
  NhanVien_ID CHAR(7) PRIMARY KEY,
  ChuyenNganh NVARCHAR(100),
  ChungChiNganhNghe VARCHAR(30),
  CONSTRAINT fk_bs_nv_nvid FOREIGN KEY (NhanVien_ID) REFERENCES NhanVien(ID)
);

CREATE TABLE YTa (
  NhanVien_ID CHAR(7) PRIMARY KEY,
  MaChungChiTotNghiep VARCHAR(30),
  CONSTRAINT fk_yt_nv_nvid FOREIGN KEY (NhanVien_ID) REFERENCES NhanVien(ID)
);

CREATE TABLE NhanVienVanPhong (
  NhanVien_ID CHAR(7) PRIMARY KEY,
  CongViecDamNhan NVARCHAR(100),
  CONSTRAINT fk_vnvp_nv_nvid FOREIGN KEY (NhanVien_ID) REFERENCES NhanVien(ID)
);

CREATE TABLE KyThuatVien (
  NhanVien_ID CHAR(7) PRIMARY KEY,
  CONSTRAINT fk_ktv_nv_nvid FOREIGN KEY (NhanVien_ID) REFERENCES NhanVien(ID)
);

CREATE TABLE KyThuatVien_KiNang (
  KiNang_ID INT,
  NhanVien_ID CHAR(7),
  PRIMARY KEY (NhanVien_ID, KiNang_ID),
  CONSTRAINT ktvkn_kn_knid FOREIGN KEY (KiNang_ID) REFERENCES KiNang(KiNang_ID),
  CONSTRAINT ktvkn_ktv_nvid FOREIGN KEY (NhanVien_ID) REFERENCES KyThuatVien(NhanVien_ID)
);

CREATE TABLE KhoThuoc_ThuocDummy (
  dummy INT
); -- (bảng giả nếu MySQL không cho tạo FK trước, nhưng ta đã có KhoThuoc nên không cần – chỉ để tránh lỗi IDE, có thể bỏ)

DROP TABLE KhoThuoc_ThuocDummy;

CREATE TABLE Thuoc (
  ID INT PRIMARY KEY,
  LoaiThuoc NVARCHAR(30),
  HanSuDung DATE,
  TenThuoc VARCHAR(100),
  DonGia DECIMAL(18,2),
  KhoThuoc_ID INT NOT NULL,
  SoLuongTonKho INT,
  CONSTRAINT fk_t_kh_khid FOREIGN KEY (KhoThuoc_ID) REFERENCES KhoThuoc(ID)
);

CREATE TABLE DichVu (
  ID INT PRIMARY KEY,
  TenDichVu NVARCHAR(100),
  GiaDichVu DECIMAL(18,2),
  MoTa LONGTEXT,
  BenhVien_ID INT NOT NULL,
  CONSTRAINT fk_dv_bv_bvid FOREIGN KEY (BenhVien_ID) REFERENCES BenhVien(ID),
  CHECK (GiaDichVu >= 0)
);

CREATE TABLE CuocHen (
  ID INT PRIMARY KEY,
  NgayGio DATETIME,
  TinhTrang NVARCHAR(30),
  DiaChi NVARCHAR(255),
  BacSi_ID CHAR(7) NOT NULL,
  CONSTRAINT fk_ck_bs_bsid FOREIGN KEY (BacSi_ID) REFERENCES BacSi(NhanVien_ID)
);

CREATE TABLE DangKyDichVu (
  BenhNhan_ID INT,
  CuocHen_ID INT,
  DichVu_ID INT,
  ThoiGianDangKy DATETIME,
  ThoiGianSuDung DATETIME,
  TrangThaiThanhToan NVARCHAR(30) DEFAULT 'Chưa thanh toán',
  PRIMARY KEY (CuocHen_ID, DichVu_ID),
  CONSTRAINT fk_dkdv_ch_id FOREIGN KEY (CuocHen_ID) REFERENCES CuocHen(ID),
  CONSTRAINT fk_dkdv_dv_dvid FOREIGN KEY (DichVu_ID) REFERENCES DichVu(ID),
  CHECK (TrangThaiThanhToan IN ('Chưa thanh toán','Đã thanh toán','Đã hủy')),
  CHECK (ThoiGianDangKy <= ThoiGianSuDung)
);

CREATE TABLE LoaiXetNghiem (
  ID INT PRIMARY KEY,
  TenLoai NVARCHAR(50) UNIQUE NOT NULL,
  MoTa LONGTEXT,
  KiNangYC_ID INT NOT NULL,
  CONSTRAINT fk_lxn_kn_knid FOREIGN KEY (KiNangYC_ID) REFERENCES KiNang(KiNang_ID)
);

CREATE TABLE DonKhamBenh (
  ID INT PRIMARY KEY,
  ChuanDoan LONGTEXT,
  CuocHen_ID INT NOT NULL,
  CONSTRAINT fk_dkb_ch_chid FOREIGN KEY (CuocHen_ID) REFERENCES CuocHen(ID)
);

CREATE TABLE HoaDon (
  ID INT PRIMARY KEY,
  NgayTaoHoaDon DATE,
  TongChiPhi DECIMAL(18,2),
  PhuongThucThanhToan NVARCHAR(30),
  DonKhamBenh_ID INT,
  CONSTRAINT fk_hd_dkb_dkbid FOREIGN KEY (DonKhamBenh_ID) REFERENCES DonKhamBenh(ID),
  CHECK (TongChiPhi >= 0),
  CHECK (PhuongThucThanhToan IN ('Tiền Mặt','Chuyển Khoản'))
);

CREATE TABLE DonKhamBenhVaThuoc (
  DonKhamBenh_ID INT,
  Thuoc_ID INT,
  SoLuong INT,
  CachDung LONGTEXT,
  PRIMARY KEY (DonKhamBenh_ID, Thuoc_ID),
  CONSTRAINT fk_dkbvt_dkb_dkbid FOREIGN KEY (DonKhamBenh_ID) REFERENCES DonKhamBenh(ID),
  CONSTRAINT fk_dkbvt_t_tid FOREIGN KEY (Thuoc_ID) REFERENCES Thuoc(ID),
  CHECK (SoLuong > 0)
);

CREATE TABLE XetNghiem (
  ID INT PRIMARY KEY,
  KetQua LONGTEXT,
  NgayThucHien DATETIME,
  LoaiXetNghiem_ID INT NOT NULL,
  DonKhamBenh_ID INT NOT NULL,
  CONSTRAINT fk_xn_lxd_lxnid FOREIGN KEY (LoaiXetNghiem_ID) REFERENCES LoaiXetNghiem(ID),
  CONSTRAINT fk_xn_dkb_dkbid FOREIGN KEY (DonKhamBenh_ID) REFERENCES DonKhamBenh(ID)
);

CREATE TABLE ThucHien (
  XetNghiem_ID INT,
  NhanVien_ID CHAR(7) NOT NULL,
  PRIMARY KEY (XetNghiem_ID, NhanVien_ID),
  CONSTRAINT fk_th_xn_xnid FOREIGN KEY (XetNghiem_ID) REFERENCES XetNghiem(ID),
  CONSTRAINT fk_th_ktv_nvid FOREIGN KEY (NhanVien_ID) REFERENCES KyThuatVien(NhanVien_ID)
);

-- ========= DỮ LIỆU MẪU =========


INSERT INTO BenhVien (ID, Ten, DiaChi) VALUES 
(1, 'Bệnh viện Đa khoa Thủ Đức', '29 Phú Châu, Tam Phú, Thủ Đức, TP Hồ Chí Minh');

INSERT INTO BenhVien_SoDienThoai (BenhVien_ID, SoDienThoai_BenhVien) VALUES 
(1, '0243888888'), 
(1, '0909123456'),
(1, '0283999999'), 
(1, '0987654321'),
(1, '0243666666');

INSERT INTO Khoa (ID, BenhVien_ID, TenKhoa, ChuyenNganh) VALUES 
(10, 1, 'Khoa Nội', 'Nội khoa tổng hợp'),
(20, 1, 'Khoa Ngoại', 'Ngoại khoa tổng hợp'),
(30, 1, 'Khoa Cấp cứu - Hồi sức', 'Hồi sức tích cực'),
(40, 1, 'Khoa Sản phụ khoa', 'Sản phụ khoa'),
(50, 1, 'Khoa Nhi', 'Nhi khoa'),
(60, 1, 'Khoa TMH - RHM - Mắt', 'Liên chuyên khoa'),
(70, 1, 'Khoa Xét nghiệm', 'Xét nghiệm y học'),
(80, 1, 'Khoa Chẩn đoán hình ảnh', 'Chẩn đoán hình ảnh'),
(90, 1, 'Khoa Dược', 'Dược lý lâm sàng'),
(100, 1, 'Khoa Gây mê hồi sức', 'Gây mê');

INSERT INTO KiNang (KiNang_ID, TenKiNang, MoTa) VALUES
(1, 'Vận hành máy MRI/CT', 'Dành cho chẩn đoán hình ảnh'),
(2, 'Chụp X-Quang', 'Kỹ thuật chụp chiếu cơ bản'),
(3, 'Xét nghiệm Huyết học', 'Phân tích máu'),
(4, 'Xét nghiệm Vi sinh', 'Nuôi cấy vi khuẩn'),
(5, 'Vận hành máy gây mê', 'Hỗ trợ bác sĩ gây mê');

INSERT INTO LoaiXetNghiem (ID, TenLoai, KiNangYC_ID, MoTa) VALUES
(1, 'Chụp MRI Sọ não', 1, 'Cần KTV có chứng chỉ MRI'),
(2, 'Chụp X-Quang Phổi', 2, 'Thường quy'),
(3, 'Công thức máu', 3, 'Xét nghiệm cơ bản'),
(4, 'Cấy máu tìm vi khuẩn', 4, 'Vi sinh'),
(5, 'Theo dõi chỉ số gây mê', 5, 'Trong phẫu thuật');

INSERT INTO KhoThuoc VALUES (1, 'Kho Chính');

INSERT INTO Thuoc (ID, TenThuoc, LoaiThuoc, DonGia, KhoThuoc_ID, SoLuongTonKho, HanSuDung) VALUES
(1, 'Paracetamol', 'Giảm đau', 5000, 1, 1000, '2026-12-30'),
(2, 'Amoxicillin', 'Kháng sinh', 10000, 1, 500, '2026-12-30'),
(3, 'Omeprazole', 'Dạ dày', 8000, 1, 800, '2026-12-30'),
(4, 'Insulin', 'Tiểu đường', 150000, 1, 200, '2026-12-30'),
(5, 'Vitamin C', 'Bổ trợ', 2000, 1, 2000, '2026-12-30');

INSERT INTO DichVu (ID, TenDichVu, GiaDichVu, BenhVien_ID) VALUES
(1, 'Khám Tổng Quát',5000000, 1),
(2, 'Khám sản phụ khoa', 500000, 1),
(3, 'Siêu âm', 1000000, 1),
(4, 'Xét nghiệm máu', 300000, 1),
(5, 'Phẫu thuật ruột thừa', 5000000, 1);

INSERT INTO NhanVien (ID, CCCD, Ho, Ten, Dem, NgaySinh, GioiTinh, SoDienThoai, BenhVien_ID, Khoa_ID) VALUES
('BS00001', '001080000001', 'Nguyễn', 'Thành', 'Văn', '1980-01-01', 'Nam', '0321852963', 1, 10),
('BS00002', '001080000002', 'Phan', 'Hiếu', 'Quang', '1981-02-02', 'Nam', '0327418529', 1, 20),
('BS00003', '001080000003', 'Lê', 'Minh', 'Hoàng', '1982-03-03', 'Nam', '0329638527', 1, 30),
('BS00004', '001080000004', 'Bùi', 'Khánh', 'Thiện', '1983-04-04', 'Nữ', '0328527419', 1, 40),
('BS00005', '001080000005', 'Võ', 'Anh', 'Tuấn', '1984-05-05', 'Nam', '0327419638', 1, 50),
('BS00006', '001080000006', 'Ngô', 'Vũ', 'Quốc', '1985-06-06', 'Nam', '0329637415', 1, 60),
('BS00007', '001080000007', 'Hoàng', 'Anh', 'Tuấn', '1986-07-07', 'Nữ', '0321597534', 1, 70),
('BS00008', '001080000008', 'Trần', 'Bảo', 'Minh', '1987-08-08', 'Nam', '0323579512', 1, 80),
('BS00009', '001080000009', 'Đỗ', 'Khoa', 'Văn', '1988-09-09', 'Nữ', '0324862591', 1, 90),
('BS00010', '001080000010', 'Phạm', 'Hưng', 'Anh', '1989-10-10', 'Nam', '0321594862', 1, 100),
('YT00001', '001080000011', 'Trương', 'Lan', 'Thị', '1990-01-01', 'Nữ', '0322693574', 1, 10),
('YT00002', '001080000012', 'Vũ', 'Ngọc', 'Phúc', '1991-01-01', 'Nữ', '0323571598', 1, 20),
('YT00003', '001080000013', 'Mai', 'Vân', 'Quyên', '1992-01-01', 'Nữ', '0324861592', 1, 30),
('YT00004', '001080000014', 'Bùi', 'Anh', 'Kim', '1993-01-01', 'Nam', '0329517536', 1, 40),
('YT00005', '001080000015', 'Đặng', 'Thu', 'Thị', '1994-01-01', 'Nữ', '0327531594', 1, 50),
('YT00006', '001080000016', 'Lê', 'Hiếu', 'Quang', '1995-01-01', 'Nam', '0321593578', 1, 60),
('YT00007', '001080000017', 'Nguyễn', 'Hà', 'Quốc', '1996-01-01', 'Nữ', '0323572691', 1, 10),
('YT00008', '001080000018', 'Trần', 'Giang', 'Thị', '1997-01-01', 'Nữ', '0324869517', 1, 20),
('YT00009', '001080000019', 'Bùi', 'Chí', 'Văn', '1998-01-01', 'Nữ', '0329513572', 1, 30),
('YT00010', '001080000020', 'Lê', 'Nhân', 'Anh', '1999-01-01', 'Nam', '0327539518', 1, 40),
('KT00001', '001080000021', 'Võ', 'Trường', 'Phúc', '1990-05-01', 'Nam', '0328426195', 1, 80),
('KT00002', '001080000022', 'Ngô', 'Khoa', 'Thiện', '1991-05-01', 'Nam', '0326194825', 1, 80),
('KT00003', '001080000023', 'Hoàng', 'Quang', 'Tuấn', '1992-05-01', 'Nữ', '0329481627', 1, 80),
('KT00004', '001080000024', 'Phạm', 'Bảo', 'Văn', '1993-05-01', 'Nam', '0325169482', 1, 70),
('KT00005', '001080000025', 'Võ', 'Mai', 'Thị', '1994-05-01', 'Nữ', '0328246197', 1, 70),
('KT00006', '001080000026', 'Trần', 'Châu', 'Kim', '1995-05-01', 'Nam', '0326197248', 1, 70),
('KT00007', '001080000027', 'Lê', 'Thành', 'Văn', '1996-05-01', 'Nữ', '0329724816', 1, 100),
('KT00008', '001080000028', 'Nguyễn', 'Hưng', 'Chí', '1997-05-01', 'Nam', '0324816972', 1, 100),
('KT00009', '001080000029', 'Bùi', 'Thành', 'Văn', '1998-05-01', 'Nam', '0326972481', 1, 60),
('KT00010', '001080000030', 'Võ', 'Khoa', 'Hoàng', '1999-05-01', 'Nữ', '0321846295', 1, 60),
('VP00001', '001080000031', 'Phạm', 'Quyên', 'Anh', '1990-10-01', 'Nữ', '0325926481', 1, 90),
('VP00002', '001080000032', 'Nguyễn', 'Nhân', 'Kim', '1990-10-02', 'Nữ', '0321849562', 1, 90),
('VP00003', '001080000033', 'Bùi', 'Tuấn', 'Văn', '1990-10-03', 'Nam', '0326591842', 1, 90),
('VP00004', '001080000034', 'Võ', 'Bảo', 'Minh', '1990-10-04', 'Nữ', '0322849516', 1, 10),
('VP00005', '001080000035', 'Lê', 'Anh', 'Tuấn', '1990-10-05', 'Nữ', '0326159482', 1, 20),
('VP00006', '001080000036', 'Ngô', 'Giang', 'Hà', '1990-10-06', 'Nam', '0329516482', 1, 30),
('VP00007', '001080000037', 'Trần', 'Hiệp', 'Văn', '1990-10-07', 'Nữ', '0324826159', 1, 40),
('VP00008', '001080000038', 'Bùi', 'Châu', 'Phúc', '1990-10-08', 'Nữ', '0327591846', 1, 50),
('VP00009', '001080000039', 'Võ', 'Khoa', 'Văn', '1990-10-09', 'Nam', '0323649185', 1, 60),
('VP00010', '001080000040', 'Lê', 'Lan', 'Thị', '1990-10-10', 'Nữ', '0328159462', 1, 90);

INSERT INTO BacSi (NhanVien_ID, ChuyenNganh, ChungChiNganhNghe) VALUES
('BS00001', 'Nội', 'CCHN-01'), 
('BS00002', 'Ngoại', 'CCHN-02'), 
('BS00003', 'HSCC', 'CCHN-03'), 
('BS00004', 'Sản', 'CCHN-04'), 
('BS00005', 'Nhi', 'CCHN-05'),
('BS00006', 'TMH', 'CCHN-06'), 
('BS00007', 'Huyết học', 'CCHN-07'), 
('BS00008', 'CĐHA', 'CCHN-08'), 
('BS00009', 'Dược', 'CCHN-09'), 
('BS00010', 'Gây mê', 'CCHN-10');

INSERT INTO YTa (NhanVien_ID, MaChungChiTotNghiep) VALUES 
('YT00001', 'TN-01'), 
('YT00002', 'TN-02'), 
('YT00003', 'TN-03'), 
('YT00004', 'TN-04'),
('YT00005', 'TN-05'),
('YT00006', 'TN-06'), 
('YT00007', 'TN-07'), 
('YT00008', 'TN-08'), 
('YT00009', 'TN-09'), 
('YT00010', 'TN-10');

INSERT INTO KyThuatVien (NhanVien_ID) VALUES 
('KT00001'), 
('KT00002'), 
('KT00003'),
('KT00004'), 
('KT00005'),
('KT00006'),
('KT00007'),
('KT00008'), 
('KT00009'), 
('KT00010');

INSERT INTO KyThuatVien_KiNang (NhanVien_ID, KiNang_ID) VALUES
('KT00001', 1), 
('KT00002', 2),
('KT00004', 3), 
('KT00005', 4), 
('KT00007', 5);

INSERT INTO NhanVienVanPhong (NhanVien_ID, CongViecDamNhan) VALUES
('VP00001', 'Bán thuốc'),
('VP00002', 'Kho dược'),
('VP00003', 'Thống kê'), 
('VP00004', 'Hành chính'),
('VP00005', 'Hành chính'), 
('VP00006', 'Tiếp nhận'), 
('VP00007', 'Hành chính'),
('VP00008', 'Hành chính'),
('VP00009', 'Hành chính'), 
('VP00010', 'Bán thuốc');

INSERT INTO QuanLi (ID, QL_ID) VALUES 
('YT00001', 'BS00001'), 
('YT00007', 'BS00001'),
('VP00004', 'BS00001'),
('YT00002', 'BS00002'),
('YT00008', 'BS00002'),
('VP00005', 'BS00002'),
('YT00003', 'BS00003'),
('YT00009', 'BS00003'),
('VP00006', 'BS00003'),
('YT00004', 'BS00004'),
('YT00010', 'BS00004'),
('VP00007', 'BS00004'),
('YT00005', 'BS00005'),
('VP00008', 'BS00005'),
('YT00006', 'BS00006'),
('KT00009', 'BS00006'),
('KT00010', 'BS00006'),
('VP00009', 'BS00006'),
('KT00004', 'BS00007'),
('KT00005', 'BS00007'),
('KT00006', 'BS00007'),
('KT00001', 'BS00008'),
('KT00002', 'BS00008'),
('KT00003', 'BS00008'),
('VP00001', 'BS00009'),
('VP00002', 'BS00009'),
('VP00003', 'BS00009'),
('VP00010', 'BS00009'),
('KT00007', 'BS00010'),
('KT00008', 'BS00010');

INSERT INTO BenhNhan (ID, HoTen, GioiTinh, NgaySinh, DiaChi, SoDienThoai, BaoHiemYTe, NgayHetHanBHYT) VALUES
(100, 'Nguyễn Văn An', 'Nam', '1990-01-01', 'HCM', '0321594872', '0981273645', '2026-12-01'),
(101, 'Trần Thị Bích', 'Nữ', '1991-01-01', 'HCM', '0326482910', '0192837465', '2026-12-01'),
(102, 'Lê Hoàng Cường', 'Nam', '1992-01-01', 'HCM', '0329384756', '0283746159', '2026-12-01'),
(103, 'Phạm Minh Dung', 'Nữ', '1993-01-01', 'HCM', '0325719283', '0374615298', '2026-12-01'),
(104, 'Hoàng Văn Em', 'Nam', '1994-01-01', 'HCM', '0328491023', '0465719283', '2026-12-01');

INSERT INTO NguoiThan (BenhNhan_ID, HoTen, QuanHe, SoDienThoai) VALUES
(100, 'Nguyễn Thị Mai', 'Vợ', '0328472910'),
(101, 'Trần Văn Hùng', 'Chồng', '0321938475'),
(102, 'Lê Thị Lan', 'Mẹ', '0325728391'),
(103, 'Phạm Văn Bình', 'Bố', '0326384920'),
(104, 'Hoàng Minh Tuấn', 'Con', '0324829103');

INSERT INTO CuocHen (ID, NgayGio, TinhTrang, DiaChi, BacSi_ID) VALUES
(1, DATE_ADD(NOW(), INTERVAL 1 HOUR), 'Đang chờ', 'P.101', 'BS00001'),
(2, DATE_ADD(NOW(), INTERVAL 2 HOUR), 'Đang chờ', 'P.201', 'BS00002'),
(3, DATE_ADD(NOW(), INTERVAL 3 HOUR), 'Đang chờ', 'P.301', 'BS00003'),
(4, DATE_ADD(NOW(), INTERVAL 4 HOUR), 'Đang chờ', 'P.401', 'BS00004'),
(5, DATE_ADD(NOW(), INTERVAL 5 HOUR), 'Đang chờ', 'P.501', 'BS00005');

INSERT INTO DonKhamBenh (ID, CuocHen_ID, ChuanDoan) VALUES
(1, 1, 'Tăng huyết áp'),
(2, 2, 'Viêm ruột thừa'),
(3, 3, 'Sốc phản vệ'), 
(4, 4, 'Khám thai định kỳ'),
(5, 5, 'Sốt xuất huyết');

INSERT INTO XetNghiem (ID, LoaiXetNghiem_ID, DonKhamBenh_ID, NgayThucHien, KetQua) VALUES
(1, 1, 1, NOW(), 'Bình thường'), -- MRI 
(2, 2, 2, NOW(), 'Viêm phổi'),   -- XQuang 
(3, 3, 3, NOW(), 'Bạch cầu tăng'), -- Huyết học 
(4, 4, 4, NOW(), 'Âm tính'),      -- Vi sinh 
(5, 5, 5, NOW(), 'Ổn định');      -- Gây mê 

INSERT INTO ThucHien (XetNghiem_ID, NhanVien_ID) VALUES
(1, 'KT00001'), 
(2, 'KT00002'), 
(3, 'KT00004'), 
(4, 'KT00005'), 
(5, 'KT00007');

INSERT INTO DonKhamBenhVaThuoc (DonKhamBenh_ID, Thuoc_ID, SoLuong, CachDung) VALUES
(1, 1, 10, 'Sáng 1 chiều 1'),
(2, 2, 20, 'Sáng 2 tối 2'),
(3, 5, 5, 'Tiêm tĩnh mạch'), 
(4, 5, 10, 'Uống mỗi ngày'), 
(5, 1, 15, 'Uống khi sốt');

INSERT INTO HoaDon (ID, DonKhamBenh_ID, NgayTaoHoaDon, TongChiPhi, PhuongThucThanhToan) VALUES
(1, 1, NOW(), 500000, 'Tiền Mặt'),
(2, 2, NOW(), 1500000, 'Chuyển Khoản'),
(3, 3, NOW(), 2000000, 'Tiền Mặt'), 
(4, 4, NOW(), 300000, 'Tiền Mặt'),
(5, 5, NOW(), 800000, 'Chuyển Khoản');

INSERT INTO DangKyDichVu (BenhNhan_ID, CuocHen_ID, DichVu_ID, ThoiGianDangKy, ThoiGianSuDung, TrangThaiThanhToan) VALUES
(100, 1, 1, NOW(), NOW(), 'Đã thanh toán'),
(101, 2, 2, NOW(), NOW(), 'Chưa thanh toán'),
(102, 3, 3, NOW(), NOW(), 'Đã thanh toán'), 
(103, 4, 4, NOW(), NOW(), 'Chưa thanh toán'),
(104, 5, 5, NOW(), NOW(), 'Đã thanh toán');
