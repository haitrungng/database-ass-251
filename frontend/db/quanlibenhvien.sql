create database Quanlibenhvien
go
use Quanlibenhvien
go

create table BenhVien(
	ID int primary key,
	Ten nvarchar(100),
	Diachi nvarchar(255)
)

create table BenhVien_SoDienThoai(
	BenhVien_ID int not null,
	SoDienThoai_BenhVien varchar(10) not null,
	primary key (BenhVien_ID, SoDienThoai_BenhVien),
	constraint fk_bvsdt_bv_id foreign key (BenhVien_ID) references BenhVien(ID)
)

create table Khoa(
	ID int,
	BenhVien_ID int,
	TenKhoa nvarchar(100),
	ChuyenNganh nvarchar(100),
	primary key (ID, BenhVien_ID),
	constraint fk_khoa_bv_bvid foreign key (BenhVien_ID) references BenhVien(ID)
)

create table KiNang(
	KiNang_ID int primary key,
	TenKiNang nvarchar(100),
	MoTa nvarchar(MAX),
)

create table KhoThuoc(
	ID int primary key,
	TenKho nvarchar(100)	
)

create table BenhNhan(
	ID int primary key,
	HoTen nvarchar(100),
	GioiTinh nvarchar(10) check (GioiTinh in (N'Nam', N'Nữ')),
	NgaySinh date check (NgaySinh <= GETDATE()),
	DiaChi nvarchar(255),
	SoDienThoai varchar(10),
	BaoHiemYTe varchar(20),
	NgayHetHanBHYT date
)

create table NguoiThan(
	BenhNhan_ID int,
	HoTen nvarchar(100),
	SoDienThoai varchar(10),
	QuanHe nvarchar(50),
	primary key (BenhNhan_ID, HoTen),
	constraint fk_nt_bn_bnid foreign key (BenhNhan_ID) references BenhNhan(ID)
)

create table NhanVien(
	ID char(7) primary key check (ID like '[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9]'),
	CCCD char(12) unique not null,
	Ho nvarchar(50),
	Ten nvarchar(50),
	Dem nvarchar(50),
	NgaySinh date check (DATEDIFF(year, NgaySinh, GETDATE()) >= 18),
	GioiTinh nvarchar(10) check (GioiTinh in (N'Nam', N'Nữ')),
	SoDienThoai varchar(10), 
	BenhVien_ID int not null,
	Khoa_ID int not null,
	constraint fk_nv_bv_bvid foreign key (Khoa_ID,BenhVien_ID) references Khoa(ID,BenhVien_ID)
)

create table QuanLi(
	ID char(7) primary key,
	QL_ID char(7) not null,
	constraint fk_ql_nv_id foreign key (ID) references NhanVien(ID),
	constraint fk_ql_nv_qlid foreign key (QL_ID) references NhanVien(ID)
)

create table BacSi (
	NhanVien_ID char(7) primary key,
	ChuyenNganh nvarchar(100),
	ChungChiNganhNghe varchar(30),
	constraint fk_bs_nv_nvid foreign key (NhanVien_ID) references NhanVien(ID)
)

create table YTa(
	NhanVien_ID char(7) primary key,
	MaChungChiTotNghiep varchar(30),
	constraint fk_yt_nv_nvid foreign key (NhanVien_ID) references NhanVien(ID)
)

create table NhanVienVanPhong(
	NhanVien_ID char(7) primary key,
	CongViecDamNhan nvarchar(100),
	constraint fk_vnvp_nv_nvid foreign key (NhanVien_ID) references NhanVien(ID)
)

create table KyThuatVien(
	NhanVien_ID char(7) primary key,
	constraint fk_ktv_nv_nvid foreign key (NhanVien_ID) references NhanVien(ID)
)

create table KyThuatVien_KiNang(
	KiNang_ID int,
	NhanVien_ID char(7),
	primary key (NhanVien_ID, KiNang_ID),
	constraint ktvkn_kn_knid foreign key (KiNang_ID) references KiNang(KiNang_ID),
	constraint ktvkn_ktv_nvid foreign key (NhanVien_ID) references KyThuatVien(NhanVien_ID)
)

create table Thuoc(
	ID int primary key,
	LoaiThuoc nvarchar(30),
	HanSuDung date check (HanSuDung >= GETDATE()),
	TenThuoc varchar(100),
	DonGia money,
	KhoThuoc_ID int not null,
	SoLuongTonKho int,
	constraint fk_t_kh_khid foreign key (KhoThuoc_ID) references KhoThuoc(ID),
)

create table DichVu(
	ID int primary key,
	TenDichVu nvarchar(100),
	GiaDichVu money check (GiaDichVu >= 0),
	MoTa nvarchar(MAX),
	BenhVien_ID int not null,
	constraint fk_dv_bv_bvid foreign key (BenhVien_ID) references BenhVien(ID)
)

create table CuocHen(
	ID int primary key,
	NgayGio datetime,
	TinhTrang nvarchar(30),
	DiaChi nvarchar(255),
	BacSi_ID char(7) not null,
	constraint fk_ck_bs_bsid foreign key (BacSi_ID) references BacSi(NhanVien_ID)
)

create table DangKyDichVu(
	BenhNhan_ID int,
	CuocHen_ID int,
	DichVu_ID int,
	ThoiGianDangKy datetime,
	ThoiGianSuDung datetime,
	TrangThaiThanhToan nvarchar(30) default N'Chưa thanh toán' check (TrangThaiThanhToan in (N'Chưa thanh toán', N'Đã thanh toán', N'Đã hủy')),
	primary key (CuocHen_ID, DichVu_ID),
	constraint fk_dkdv_bn_bnid foreign key (CuocHen_ID) references CuocHen(ID),
	constraint fk_dkdv_dv_dvid foreign key (DichVu_ID) references DichVu(ID),
	constraint ck_tgdkdv check (ThoiGianDangKy <= ThoiGianSuDung)
)

create table LoaiXetNghiem(
	ID int primary key,
	TenLoai nvarchar(50) unique not null,
	MoTa nvarchar(MAX),
	KiNangYC_ID int not null,
	constraint fk_lxn_kn_knid foreign key (KiNangYC_ID) references KiNang(KiNang_ID)
)

create table DonKhamBenh(
	ID int primary key,
	ChuanDoan nvarchar(MAX),
	CuocHen_ID int not null,
	constraint fk_dkb_ch_chid foreign key (CuocHen_ID) references CuocHen(ID)
)

create table HoaDon(
	ID int primary key,
	NgayTaoHoaDon date,
	TongChiPhi money check (TongChiPhi >= 0),
	PhuongThucThanhToan nvarchar(30) check (PhuongThucThanhToan in (N'Tiền Mặt', N'Chuyển Khoản')),
	DonKhamBenh_ID int,
	constraint fk_hd_dkb_dkbid foreign key (DonKhamBenh_ID) references DonKhamBenh(ID)
)

create table DonKhamBenhVaThuoc (
	DonKhamBenh_ID int,
	Thuoc_ID int,
	SoLuong int check (SoLuong > 0),
	CachDung nvarchar(MAX),
	primary key (DonKhamBenh_ID, Thuoc_ID),
	constraint fk_dkbvt_dkb_dkbid foreign key (DonKhamBenh_ID) references DonKhamBenh(ID),
	constraint fk_dkbvt_t_tid foreign key (Thuoc_ID) references Thuoc(ID)
)

create table XetNghiem(
	ID int primary key,
	KetQua nvarchar(MAX),
	NgayThucHien datetime,
	LoaiXetNghiem_ID int not null,
	DonKhamBenh_ID int not null,
	constraint fk_xn_lxd_lxnid foreign key (LoaiXetNghiem_ID) references LoaiXetNghiem(ID),
	constraint fk_xn_dkb_dkbid foreign key (DonKhamBenh_ID) references DonKhamBenh(ID)
)

create table ThucHien(
	XetNghiem_ID int,
	NhanVien_ID char(7) not null,
	primary key (XetNghiem_ID, NhanVien_ID),
	constraint fk_th_xn_xnid foreign key (XetNghiem_ID) references XetNghiem(ID),
	constraint fk_th_ktv_nvid foreign key (NhanVien_ID) references KyThuatVien(NhanVien_ID)
)



insert into BenhVien (ID, Ten, DiaChi) values (1, N'Bệnh viện Đa khoa Thủ Đức', N'29 Phú Châu, Tam Phú, Thủ Đức, TP Hồ Chí Minh');

INSERT INTO BenhVien_SoDienThoai (BenhVien_ID, SoDienThoai_BenhVien) VALUES 
(1, '0243888888'), 
(1, '0909123456'),
(1, '0283999999'), 
(1, '0987654321'),
(1, '0243666666');

INSERT INTO Khoa (ID, BenhVien_ID, TenKhoa, ChuyenNganh) VALUES 
(10, 1, N'Khoa Nội', N'Nội khoa tổng hợp'),
(20, 1, N'Khoa Ngoại', N'Ngoại khoa tổng hợp'),
(30, 1, N'Khoa Cấp cứu - Hồi sức', N'Hồi sức tích cực'),
(40, 1, N'Khoa Sản phụ khoa', N'Sản phụ khoa'),
(50, 1, N'Khoa Nhi', N'Nhi khoa'),
(60, 1, N'Khoa TMH - RHM - Mắt', N'Liên chuyên khoa'),
(70, 1, N'Khoa Xét nghiệm', N'Xét nghiệm y học'),
(80, 1, N'Khoa Chẩn đoán hình ảnh', N'Chẩn đoán hình ảnh'),
(90, 1, N'Khoa Dược', N'Dược lý lâm sàng'),
(100, 1, N'Khoa Gây mê hồi sức', N'Gây mê');

INSERT INTO KiNang (KiNang_ID, TenKiNang, MoTa) VALUES
(1, N'Vận hành máy MRI/CT', N'Dành cho chẩn đoán hình ảnh'),
(2, N'Chụp X-Quang', N'Kỹ thuật chụp chiếu cơ bản'),
(3, N'Xét nghiệm Huyết học', N'Phân tích máu'),
(4, N'Xét nghiệm Vi sinh', N'Nuôi cấy vi khuẩn'),
(5, N'Vận hành máy gây mê', N'Hỗ trợ bác sĩ gây mê');

INSERT INTO LoaiXetNghiem (ID, TenLoai, KiNangYC_ID, MoTa) VALUES
(1, N'Chụp MRI Sọ não', 1, N'Cần KTV có chứng chỉ MRI'),
(2, N'Chụp X-Quang Phổi', 2, N'Thường quy'),
(3, N'Công thức máu', 3, N'Xét nghiệm cơ bản'),
(4, N'Cấy máu tìm vi khuẩn', 4, N'Vi sinh'),
(5, N'Theo dõi chỉ số gây mê', 5, N'Trong phẫu thuật');

INSERT INTO KhoThuoc VALUES (1, N'Kho Chính');

INSERT INTO Thuoc (ID, TenThuoc, LoaiThuoc, DonGia, KhoThuoc_ID, SoLuongTonKho, HanSuDung) VALUES
(1, 'Paracetamol', N'Giảm đau', 5000, 1, 1000, '2026-12-30'),
(2, 'Amoxicillin', N'Kháng sinh', 10000, 1, 500, '2026-12-30'),
(3, 'Omeprazole', N'Dạ dày', 8000, 1, 800, '2026-12-30'),
(4, 'Insulin', N'Tiểu đường', 150000, 1, 200, '2026-12-30'),
(5, 'Vitamin C', N'Bổ trợ', 2000, 1, 2000, '2026-12-30');

INSERT INTO DichVu (ID, TenDichVu, GiaDichVu, BenhVien_ID) VALUES
(1, N'Khám Tổng Quát',5000000, 1),
(2, N'Khám sản phụ khoa', 500000, 1),
(3, N'Siêu âm', 1000000, 1),
(4, N'Xét nghiệm máu', 300000, 1),
(5, N'Phẫu thuật ruột thừa', 5000000, 1);

INSERT INTO NhanVien (ID, CCCD, Ho, Ten, Dem, NgaySinh, GioiTinh, SoDienThoai, BenhVien_ID, Khoa_ID) VALUES
('BS00001', '001080000001', N'Nguyễn', N'Thành', N'Văn', '1980-01-01', N'Nam', '0321852963', 1, 10),
('BS00002', '001080000002', N'Phan', N'Hiếu', N'Quang', '1981-02-02', N'Nam', '0327418529', 1, 20),
('BS00003', '001080000003', N'Lê', N'Minh', N'Hoàng', '1982-03-03', N'Nam', '0329638527', 1, 30),
('BS00004', '001080000004', N'Bùi', N'Khánh', N'Thiện', '1983-04-04', N'Nữ', '0328527419', 1, 40),
('BS00005', '001080000005', N'Võ', N'Anh', N'Tuấn', '1984-05-05', N'Nam', '0327419638', 1, 50),
('BS00006', '001080000006', N'Ngô', N'Vũ', N'Quốc', '1985-06-06', N'Nam', '0329637415', 1, 60),
('BS00007', '001080000007', N'Hoàng', N'Anh', N'Tuấn', '1986-07-07', N'Nữ', '0321597534', 1, 70),
('BS00008', '001080000008', N'Trần', N'Bảo', N'Minh', '1987-08-08', N'Nam', '0323579512', 1, 80),
('BS00009', '001080000009', N'Đỗ', N'Khoa', N'Văn', '1988-09-09', N'Nữ', '0324862591', 1, 90),
('BS00010', '001080000010', N'Phạm', N'Hưng', N'Anh', '1989-10-10', N'Nam', '0321594862', 1, 100),
('YT00001', '001080000011', N'Trương', N'Lan', N'Thị', '1990-01-01', N'Nữ', '0322693574', 1, 10),
('YT00002', '001080000012', N'Vũ', N'Ngọc', N'Phúc', '1991-01-01', N'Nữ', '0323571598', 1, 20),
('YT00003', '001080000013', N'Mai', N'Vân', N'Quyên', '1992-01-01', N'Nữ', '0324861592', 1, 30),
('YT00004', '001080000014', N'Bùi', N'Anh', N'Kim', '1993-01-01', N'Nam', '0329517536', 1, 40),
('YT00005', '001080000015', N'Đặng', N'Thu', N'Thị', '1994-01-01', N'Nữ', '0327531594', 1, 50),
('YT00006', '001080000016', N'Lê', N'Hiếu', N'Quang', '1995-01-01', N'Nam', '0321593578', 1, 60),
('YT00007', '001080000017', N'Nguyễn', N'Hà', N'Quốc', '1996-01-01', N'Nữ', '0323572691', 1, 10),
('YT00008', '001080000018', N'Trần', N'Giang', N'Thị', '1997-01-01', N'Nữ', '0324869517', 1, 20),
('YT00009', '001080000019', N'Bùi', N'Chí', N'Văn', '1998-01-01', N'Nữ', '0329513572', 1, 30),
('YT00010', '001080000020', N'Lê', N'Nhân', N'Anh', '1999-01-01', N'Nam', '0327539518', 1, 40),
('KT00001', '001080000021', N'Võ', N'Trường', N'Phúc', '1990-05-01', N'Nam', '0328426195', 1, 80),
('KT00002', '001080000022', N'Ngô', N'Khoa', N'Thiện', '1991-05-01', N'Nam', '0326194825', 1, 80),
('KT00003', '001080000023', N'Hoàng', N'Quang', N'Tuấn', '1992-05-01', N'Nữ', '0329481627', 1, 80),
('KT00004', '001080000024', N'Phạm', N'Bảo', N'Văn', '1993-05-01', N'Nam', '0325169482', 1, 70),
('KT00005', '001080000025', N'Võ', N'Mai', N'Thị', '1994-05-01', N'Nữ', '0328246197', 1, 70),
('KT00006', '001080000026', N'Trần', N'Châu', N'Kim', '1995-05-01', N'Nam', '0326197248', 1, 70),
('KT00007', '001080000027', N'Lê', N'Thành', N'Văn', '1996-05-01', N'Nữ', '0329724816', 1, 100),
('KT00008', '001080000028', N'Nguyễn', N'Hưng', N'Chí', '1997-05-01', N'Nam', '0324816972', 1, 100),
('KT00009', '001080000029', N'Bùi', N'Thành', N'Văn', '1998-05-01', N'Nam', '0326972481', 1, 60),
('KT00010', '001080000030', N'Võ', N'Khoa', N'Hoàng', '1999-05-01', N'Nữ', '0321846295', 1, 60),
('VP00001', '001080000031', N'Phạm', N'Quyên', N'Anh', '1990-10-01', N'Nữ', '0325926481', 1, 90),
('VP00002', '001080000032', N'Nguyễn', N'Nhân', N'Kim', '1990-10-02', N'Nữ', '0321849562', 1, 90),
('VP00003', '001080000033', N'Bùi', N'Tuấn', N'Văn', '1990-10-03', N'Nam', '0326591842', 1, 90),
('VP00004', '001080000034', N'Võ', N'Bảo', N'Minh', '1990-10-04', N'Nữ', '0322849516', 1, 10),
('VP00005', '001080000035', N'Lê', N'Anh', N'Tuấn', '1990-10-05', N'Nữ', '0326159482', 1, 20),
('VP00006', '001080000036', N'Ngô', N'Giang', N'Hà', '1990-10-06', N'Nam', '0329516482', 1, 30),
('VP00007', '001080000037', N'Trần', N'Hiệp', N'Văn', '1990-10-07', N'Nữ', '0324826159', 1, 40),
('VP00008', '001080000038', N'Bùi', N'Châu', N'Phúc', '1990-10-08', N'Nữ', '0327591846', 1, 50),
('VP00009', '001080000039', N'Võ', N'Khoa', N'Văn', '1990-10-09', N'Nam', '0323649185', 1, 60),
('VP00010', '001080000040', N'Lê', N'Lan', N'Thị', '1990-10-10', N'Nữ', '0328159462', 1, 90);

INSERT INTO BacSi (NhanVien_ID, ChuyenNganh, ChungChiNganhNghe) VALUES
('BS00001', N'Nội', 'CCHN-01'), 
('BS00002', N'Ngoại', 'CCHN-02'), 
('BS00003', N'HSCC', 'CCHN-03'), 
('BS00004', N'Sản', 'CCHN-04'), 
('BS00005', N'Nhi', 'CCHN-05'),
('BS00006', N'TMH', 'CCHN-06'), 
('BS00007', N'Huyết học', 'CCHN-07'), 
('BS00008', N'CĐHA', 'CCHN-08'), 
('BS00009', N'Dược', 'CCHN-09'), 
('BS00010', N'Gây mê', 'CCHN-10');
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
('VP00001', N'Bán thuốc'),
('VP00002', N'Kho dược'),
('VP00003', N'Thống kê'), 
('VP00004', N'Hành chính'),
('VP00005', N'Hành chính'), 
('VP00006', N'Tiếp nhận'), 
('VP00007', N'Hành chính'),
('VP00008', N'Hành chính'),
('VP00009', N'Hành chính'), 
('VP00010', N'Bán thuốc');

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
(100, N'Nguyễn Văn An', N'Nam', '1990-01-01', N'HCM', '0321594872', '0981273645', '2026-12-01'),
(101, N'Trần Thị Bích', N'Nữ', '1991-01-01', N'HCM', '0326482910', '0192837465', '2026-12-01'),
(102, N'Lê Hoàng Cường', N'Nam', '1992-01-01', N'HCM', '0329384756', '0283746159', '2026-12-01'),
(103, N'Phạm Minh Dung', N'Nữ', '1993-01-01', N'HCM', '0325719283', '0374615298', '2026-12-01'),
(104, N'Hoàng Văn Em', N'Nam', '1994-01-01', N'HCM', '0328491023', '0465719283', '2026-12-01');


INSERT INTO NguoiThan (BenhNhan_ID, HoTen, QuanHe, SoDienThoai) VALUES
(100, N'Nguyễn Thị Mai', N'Vợ', '0328472910'),
(101, N'Trần Văn Hùng', N'Chồng', '0321938475'),
(102, N'Lê Thị Lan', N'Mẹ', '0325728391'),
(103, N'Phạm Văn Bình', N'Bố', '0326384920'),
(104, N'Hoàng Minh Tuấn', N'Con', '0324829103');


INSERT INTO CuocHen (ID, NgayGio, TinhTrang, DiaChi, BacSi_ID) VALUES
(1, DATEADD(hour, 1, GETDATE()), N'Đang chờ', N'P.101', 'BS00001'),
(2, DATEADD(hour, 2, GETDATE()), N'Đang chờ', N'P.201', 'BS00002'),
(3, DATEADD(hour, 3, GETDATE()), N'Đang chờ', N'P.301', 'BS00003'),
(4, DATEADD(hour, 4, GETDATE()), N'Đang chờ', N'P.401', 'BS00004'),
(5, DATEADD(hour, 5, GETDATE()), N'Đang chờ', N'P.501', 'BS00005');

INSERT INTO DonKhamBenh (ID, CuocHen_ID, ChuanDoan) VALUES
(1, 1, N'Tăng huyết áp'),
(2, 2, N'Viêm ruột thừa'),
(3, 3, N'Sốc phản vệ'), 
(4, 4, N'Khám thai định kỳ'),
(5, 5, N'Sốt xuất huyết');

INSERT INTO XetNghiem (ID, LoaiXetNghiem_ID, DonKhamBenh_ID, NgayThucHien, KetQua) VALUES
(1, 1, 1, GETDATE(), N'Bình thường'), -- MRI 
(2, 2, 2, GETDATE(), N'Viêm phổi'),   -- XQuang 
(3, 3, 3, GETDATE(), N'Bạch cầu tăng'), -- Huyết học 
(4, 4, 4, GETDATE(), N'Âm tính'),      -- Vi sinh 
(5, 5, 5, GETDATE(), N'Ổn định');      -- Gây mê 

INSERT INTO ThucHien (XetNghiem_ID, NhanVien_ID) VALUES
(1, 'KT00001'), 
(2, 'KT00002'), 
(3, 'KT00004'), 
(4, 'KT00005'), 
(5, 'KT00007');

INSERT INTO DonKhamBenhVaThuoc (DonKhamBenh_ID, Thuoc_ID, SoLuong, CachDung) VALUES
(1, 1, 10, N'Sáng 1 chiều 1'),
(2, 2, 20, N'Sáng 2 tối 2'),
(3, 5, 5, N'Tiêm tĩnh mạch'), 
(4, 5, 10, N'Uống mỗi ngày'), 
(5, 1, 15, N'Uống khi sốt');

INSERT INTO HoaDon (ID, DonKhamBenh_ID, NgayTaoHoaDon, TongChiPhi, PhuongThucThanhToan) VALUES
(1, 1, GETDATE(), 500000, N'Tiền Mặt'),
(2, 2, GETDATE(), 1500000, N'Chuyển Khoản'),
(3, 3, GETDATE(), 2000000, N'Tiền Mặt'), 
(4, 4, GETDATE(), 300000, N'Tiền Mặt'),
(5, 5, GETDATE(), 800000, N'Chuyển Khoản');

INSERT INTO DangKyDichVu (BenhNhan_ID, CuocHen_ID, DichVu_ID, ThoiGianDangKy, ThoiGianSuDung, TrangThaiThanhToan) VALUES
(100, 1, 1, GETDATE(), GETDATE(), N'Đã thanh toán'),
(101, 2, 2, GETDATE(), GETDATE(), N'Chưa thanh toán'),
(102, 3, 3, GETDATE(), GETDATE(), N'Đã thanh toán'), 
(103, 4, 4, GETDATE(), GETDATE(), N'Chưa thanh toán'),
(104, 5, 5, GETDATE(), GETDATE(), N'Đã thanh toán');
