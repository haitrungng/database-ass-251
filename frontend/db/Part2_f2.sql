USE Quanlibenhvien
GO

-- 2.1 THỦ TỤC INSERT / UPDATE / DELETE

-- 2.1.1 Thủ tục INSERT Nhân viên
CREATE OR ALTER PROCEDURE sp_InsertNhanVien
    @ID CHAR(7),
    @CCCD CHAR(12),
    @Ho NVARCHAR(50),
    @Ten NVARCHAR(50),
    @Dem NVARCHAR(50),
    @NgaySinh DATE,
    @GioiTinh NVARCHAR(10),
    @SoDienThoai VARCHAR(10),
    @BenhVien_ID INT,
    @Khoa_ID INT
AS
BEGIN
    -- 1. Validate ID Format
    IF (@ID NOT LIKE '[A-Z][A-Z][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        RAISERROR (N'Lỗi: Mã nhân viên phải có định dạng 2 chữ cái + 5 số (VD: BS00012).', 16, 1);
        RETURN;
    END

    -- 2. Validate trung ID
    IF EXISTS (SELECT 1 FROM NhanVien WHERE ID = @ID)
    BEGIN
        RAISERROR (N'Lỗi: Mã nhân viên đã tồn tại.', 16, 1);
        RETURN;
    END

    -- 3. Validate trung CCCD
    IF EXISTS (SELECT 1 FROM NhanVien WHERE CCCD = @CCCD)
    BEGIN
        RAISERROR (N'Lỗi: Số CCCD đã tồn tại trong hệ thống.', 16, 1);
        RETURN;
    END

    -- 4. Validate Tuổi
    -- Logic: Nếu ngày sinh + 18 năm > ngày hiện tại => Chưa đủ 18 tuổi
    IF (DATEADD(YEAR, 18, @NgaySinh) > GETDATE())
    BEGIN
        RAISERROR (N'Lỗi: Nhân viên phải từ 18 tuổi trở lên (tính theo ngày sinh).', 16, 1);
        RETURN;
    END

    -- 5. Validate Số điện thoại (Chỉ chứa số vaf chứa 10 số)
    IF (@SoDienThoai NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        RAISERROR (N'Lỗi: Số điện thoại phải gồm đúng 10 chữ số.', 16, 1);
        RETURN;
    END

    -- 6. Validate Khoa thuộc Bệnh viện
    IF NOT EXISTS (
        SELECT 1 FROM Khoa
        WHERE ID = @Khoa_ID AND BenhVien_ID = @BenhVien_ID
    )
    BEGIN
        RAISERROR (N'Lỗi: Khoa không tồn tại hoặc không thuộc bệnh viện này.', 16, 1);
        RETURN;
    END

    -- Insert
    INSERT INTO NhanVien (ID, CCCD, Ho, Ten, Dem, NgaySinh, GioiTinh, SoDienThoai, BenhVien_ID, Khoa_ID)
    VALUES (@ID, @CCCD, @Ho, @Ten, @Dem, @NgaySinh, @GioiTinh, @SoDienThoai, @BenhVien_ID, @Khoa_ID);
END
GO

-- 2.1.2 Thủ tục UPDATE Nhân viên
CREATE OR ALTER PROCEDURE sp_UpdateNhanVien
    @ID CHAR(7),
    @SoDienThoai VARCHAR(10),
    @Khoa_ID INT,
    @BenhVien_ID INT
AS
BEGIN
    -- Validate Tồn tại
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE ID = @ID)
    BEGIN
        RAISERROR (N'Lỗi: Không tìm thấy nhân viên có mã %s.', 16, 1, @ID);
        RETURN;
    END

    -- Validate SĐT
    IF (@SoDienThoai NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    BEGIN
        RAISERROR (N'Lỗi: Số điện thoại không hợp lệ.', 16, 1);
        RETURN;
    END

    -- Validate Khoa
    IF NOT EXISTS (SELECT 1 FROM Khoa WHERE ID = @Khoa_ID AND BenhVien_ID = @BenhVien_ID)
    BEGIN
        RAISERROR (N'Lỗi: Khoa và Bệnh viện không khớp.', 16, 1);
        RETURN;
    END

    UPDATE NhanVien
    SET SoDienThoai = @SoDienThoai,
        Khoa_ID = @Khoa_ID,
        BenhVien_ID = @BenhVien_ID
    WHERE ID = @ID;
END
GO

-- 2.1.3 Thủ tục DELETE Nhân viên
CREATE OR ALTER PROCEDURE sp_DeleteNhanVien
    @ID CHAR(7)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE ID = @ID)
    BEGIN
        RAISERROR (N'Lỗi: Nhân viên không tồn tại.', 16, 1);
        RETURN;
    END

    -- 1. Kiểm tra có đang là quản lý (QL_ID chứa ID của người này)
    IF EXISTS (SELECT 1 FROM QuanLi WHERE QL_ID = @ID)
    BEGIN
        RAISERROR (N'Lỗi: Không thể xóa vì nhân viên này đang quản lý nhân viên khác.', 16, 1);
        RETURN;
    END

    -- 2. Kiểm tra Bác sĩ có cuộc hẹn sắp tới, chưa hoàn thành thì khoong được xóa
    IF EXISTS (
        SELECT 1 
        FROM CuocHen 
        WHERE BacSi_ID = @ID 
          AND NgayGio >= GETDATE()
          AND TinhTrang NOT IN (N'Hoàn thành', N'Đã hủy')
    )
    BEGIN
        RAISERROR (N'Lỗi: Không thể xóa bác sĩ vì còn lịch hẹn chưa hoàn thành.', 16, 1);
        RETURN;
    END

    -- 3. Kiểm tra Kỹ thuật viên đang thực hiện xét nghiệm chưa có kết quả
    IF EXISTS (
        SELECT 1 
        FROM ThucHien TH
        INNER JOIN XetNghiem XN ON TH.XetNghiem_ID = XN.ID
        WHERE TH.NhanVien_ID = @ID 
          AND (XN.KetQua IS NULL OR XN.KetQua = '')
    )
    BEGIN
        RAISERROR (N'Lỗi: Không thể xóa KTV vì đang thực hiện xét nghiệm chưa có kết quả.', 16, 1);
        RETURN;
    END

    -- Xóa các bảng con trước (NhanVien)
    BEGIN TRANSACTION
        BEGIN TRY
            -- Xóa vai trò (nếu có)
            DELETE FROM BacSi WHERE NhanVien_ID = @ID;
            DELETE FROM YTa WHERE NhanVien_ID = @ID;
            DELETE FROM KyThuatVien WHERE NhanVien_ID = @ID;
            DELETE FROM NhanVienVanPhong WHERE NhanVien_ID = @ID;
            DELETE FROM QuanLi WHERE ID = @ID; -- Xóa chính họ khỏi bảng quản lý (vai trò nhân viên)
            
            -- Xóa nhân viên
            DELETE FROM NhanVien WHERE ID = @ID;
            
            COMMIT TRANSACTION;
        END TRY
        BEGIN CATCH
            ROLLBACK TRANSACTION;
            DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
            RAISERROR (@ErrorMessage, 16, 1);
        END CATCH
END
GO

-- 2.2 TRIGGER

-- 2.2.1 Trigger Ràng buộc Kỹ năng KTV
CREATE OR ALTER TRIGGER trg_Check_KyNang_KTV
ON ThucHien
AFTER INSERT, UPDATE
AS
BEGIN
    
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN XetNghiem xn ON xn.ID = i.XetNghiem_ID
        JOIN LoaiXetNghiem lx ON lx.ID = xn.LoaiXetNghiem_ID
        -- LEFT JOIN để tìm KTV KHÔNG có kỹ năng yêu cầu
        LEFT JOIN KyThuatVien_KiNang kk 
               ON kk.NhanVien_ID = i.NhanVien_ID 
              AND kk.KiNang_ID = lx.KiNangYC_ID
        WHERE kk.KiNang_ID IS NULL -- NULL = không khớp kỹ năng
    )
    BEGIN
        RAISERROR (N'Lỗi ràng buộc: Kỹ thuật viên không có kỹ năng phù hợp với loại xét nghiệm này.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END
GO

-- 2.2.2 Trigger tính Tổng chi phí 
--  DonKhamBenh -> CuocHen -> DangKyDichVu (qua CuocHen_ID) -> DichVu
CREATE OR ALTER TRIGGER trg_Update_TongChiPhi
ON HoaDon
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE hd
    SET TongChiPhi = (
        -- 1. Tổng tiền thuốc
        ISNULL((
            SELECT SUM(t.DonGia * dvt.SoLuong)
            FROM DonKhamBenhVaThuoc dvt
            JOIN Thuoc t ON t.ID = dvt.Thuoc_ID
            WHERE dvt.DonKhamBenh_ID = hd.DonKhamBenh_ID
        ), 0)
        +
        -- 2. Tổng tiền dịch vụ 
        ISNULL((
            SELECT SUM(dv.GiaDichVu)
            FROM DonKhamBenh dk
            JOIN CuocHen ch ON ch.ID = dk.CuocHen_ID
            JOIN DangKyDichVu dd ON dd.CuocHen_ID = ch.ID
            JOIN DichVu dv ON dv.ID = dd.DichVu_ID
            WHERE dk.ID = hd.DonKhamBenh_ID
        ), 0)
    )
    FROM HoaDon hd
    JOIN inserted i ON i.ID = hd.ID; -- Chỉ update dòng vừa tác động
END
GO


-- 2.3 THỦ TỤC TRUY VẤN

-- 2.3.1 Liệt kê cuộc hẹn của Bác sĩ 
CREATE OR ALTER PROCEDURE sp_ListAppointments
    @BacSiID CHAR(7)
AS
BEGIN

-- NOTE: một cuộc hẹn có thể đăng ký nhiều dịch vụ -> sinh ra nhiều dòng trùng
    SELECT DISTINCT 
        ch.ID AS MaCuocHen,
        bn.HoTen AS TenBenhNhan,
        ch.NgayGio,
        ch.TinhTrang
    FROM CuocHen ch
    JOIN DangKyDichVu dk ON dk.CuocHen_ID = ch.ID
    JOIN BenhNhan bn ON bn.ID = dk.BenhNhan_ID
    WHERE ch.BacSi_ID = @BacSiID
    ORDER BY ch.NgayGio DESC;
END
GO

-- 2.3.2 Thống kê dịch vụ theo bệnh nhân 
CREATE OR ALTER PROCEDURE sp_DichVuTheoBenhNhan
    @MinSoLuong INT
AS
BEGIN
    SELECT 
        bn.ID, 
        bn.HoTen, 
        COUNT(*) AS SoLanSuDung
    FROM DangKyDichVu d
    JOIN BenhNhan bn ON bn.ID = d.BenhNhan_ID
    GROUP BY bn.ID, bn.HoTen
    HAVING COUNT(*) >= @MinSoLuong
    ORDER BY SoLanSuDung DESC;
END
GO

-- 2.4 HÀM (FUNCTIONS)

-- 2.4.1 Tính tổng tiền thuốc 
CREATE OR ALTER FUNCTION fn_TongTienThuoc(@DonKham_ID INT)
RETURNS MONEY
AS
BEGIN
    DECLARE @Tong MONEY = 0;
    DECLARE @Gia MONEY;
    DECLARE @SL INT;

    DECLARE cur CURSOR FOR
        SELECT t.DonGia, d.SoLuong
        FROM DonKhamBenhVaThuoc d
        JOIN Thuoc t ON t.ID = d.Thuoc_ID
        WHERE d.DonKhamBenh_ID = @DonKham_ID;

    OPEN cur;
    FETCH NEXT FROM cur INTO @Gia, @SL;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Tong = @Tong + (@Gia * @SL);
        FETCH NEXT FROM cur INTO @Gia, @SL;
    END

    CLOSE cur;
    DEALLOCATE cur;

    RETURN @Tong;
END
GO

-- 2.4.2 Kiểm tra BHYT 
CREATE OR ALTER FUNCTION fn_BHYT_HopLe(@BenhNhan_ID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @NgayHetHan DATE;

    SELECT @NgayHetHan = NgayHetHanBHYT
    FROM BenhNhan
    WHERE ID = @BenhNhan_ID;

-- Nếu không có ngày hết hạn (NULL) -> Coi như không hợp lệ hoặc không có BHYT
    IF (@NgayHetHan IS NULL) 
        RETURN 0;

    IF (@NgayHetHan >= GETDATE())
        RETURN 1;
    
    RETURN 0;
END
GO