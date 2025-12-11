-- ============================================
--  CHỌN DATABASE
-- ============================================
USE Quanlibenhvien;

-- ============================================
--  2.1 THỦ TỤC INSERT / UPDATE / DELETE
-- ============================================

-- 2.1.1 Thủ tục INSERT Nhân viên
DROP PROCEDURE IF EXISTS sp_InsertNhanVien;
DELIMITER $$

CREATE PROCEDURE sp_InsertNhanVien(
    IN p_ID CHAR(7),
    IN p_CCCD CHAR(12),
    IN p_Ho NVARCHAR(50),
    IN p_Ten NVARCHAR(50),
    IN p_Dem NVARCHAR(50),
    IN p_NgaySinh DATE,
    IN p_GioiTinh NVARCHAR(10),
    IN p_SoDienThoai VARCHAR(10),
    IN p_BenhVien_ID INT,
    IN p_Khoa_ID INT
)
BEGIN
    -- 1. Validate ID Format: 2 chữ cái + 5 số
    IF (p_ID NOT REGEXP '^[A-Z]{2}[0-9]{5}$') THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Mã nhân viên phải có định dạng 2 chữ cái + 5 số (VD: BS00012).';
    END IF;

    -- 2. Validate trùng ID
    IF EXISTS (SELECT 1 FROM NhanVien WHERE ID = p_ID) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Mã nhân viên đã tồn tại.';
    END IF;

    -- 3. Validate trùng CCCD
    IF EXISTS (SELECT 1 FROM NhanVien WHERE CCCD = p_CCCD) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Số CCCD đã tồn tại trong hệ thống.';
    END IF;

    -- 4. Validate Tuổi: >= 18
    IF (DATE_ADD(p_NgaySinh, INTERVAL 18 YEAR) > CURDATE()) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Nhân viên phải từ 18 tuổi trở lên (tính theo ngày sinh).';
    END IF;

    -- 5. Validate Số điện thoại (10 số)
    IF (p_SoDienThoai NOT REGEXP '^[0-9]{10}$') THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Số điện thoại phải gồm đúng 10 chữ số.';
    END IF;

    -- 6. Validate Khoa thuộc Bệnh viện
    IF NOT EXISTS (
        SELECT 1 
        FROM Khoa
        WHERE ID = p_Khoa_ID AND BenhVien_ID = p_BenhVien_ID
    ) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Khoa không tồn tại hoặc không thuộc bệnh viện này.';
    END IF;

    -- Insert
    INSERT INTO NhanVien (ID, CCCD, Ho, Ten, Dem, NgaySinh, GioiTinh, SoDienThoai, BenhVien_ID, Khoa_ID)
    VALUES (p_ID, p_CCCD, p_Ho, p_Ten, p_Dem, p_NgaySinh, p_GioiTinh, p_SoDienThoai, p_BenhVien_ID, p_Khoa_ID);
END$$
DELIMITER ;


-- 2.1.2 Thủ tục UPDATE Nhân viên
DROP PROCEDURE IF EXISTS sp_UpdateNhanVien;
DELIMITER $$

CREATE PROCEDURE sp_UpdateNhanVien(
    IN p_ID CHAR(7),
    IN p_SoDienThoai VARCHAR(10),
    IN p_Khoa_ID INT,
    IN p_BenhVien_ID INT
)
BEGIN
    -- Validate Tồn tại
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE ID = p_ID) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Không tìm thấy nhân viên có mã này.';
    END IF;

    -- Validate SĐT
    IF (p_SoDienThoai NOT REGEXP '^[0-9]{10}$') THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Số điện thoại không hợp lệ.';
    END IF;

    -- Validate Khoa
    IF NOT EXISTS (
        SELECT 1 FROM Khoa 
        WHERE ID = p_Khoa_ID AND BenhVien_ID = p_BenhVien_ID
    ) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Khoa và Bệnh viện không khớp.';
    END IF;

    UPDATE NhanVien
    SET SoDienThoai = p_SoDienThoai,
        Khoa_ID      = p_Khoa_ID,
        BenhVien_ID  = p_BenhVien_ID
    WHERE ID = p_ID;
END$$
DELIMITER ;


-- 2.1.3 Thủ tục DELETE Nhân viên
DROP PROCEDURE IF EXISTS sp_DeleteNhanVien;
DELIMITER $$

CREATE PROCEDURE sp_DeleteNhanVien(IN p_ID CHAR(7))
BEGIN
    -- ❶ Các DECLARE phải đứng đầu block
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi hệ thống khi xóa nhân viên.';
    END;

    -- ❷ Các kiểm tra điều kiện
    IF NOT EXISTS (SELECT 1 FROM NhanVien WHERE ID = p_ID) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Nhân viên không tồn tại.';
    END IF;

    IF EXISTS (SELECT 1 FROM QuanLi WHERE QL_ID = p_ID) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Không thể xóa vì nhân viên này đang quản lý nhân viên khác.';
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM CuocHen 
        WHERE BacSi_ID = p_ID 
          AND NgayGio >= NOW()
          AND TinhTrang NOT IN ('Hoàn thành', 'Đã hủy')
    ) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Không thể xóa bác sĩ vì còn lịch hẹn chưa hoàn thành.';
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM ThucHien TH
        INNER JOIN XetNghiem XN ON TH.XetNghiem_ID = XN.ID
        WHERE TH.NhanVien_ID = p_ID 
          AND (XN.KetQua IS NULL OR XN.KetQua = '')
    ) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Không thể xóa KTV vì đang thực hiện xét nghiệm chưa có kết quả.';
    END IF;

    -- ❸ Transaction xóa dữ liệu
    START TRANSACTION;
        DELETE FROM ThucHien WHERE NhanVien_ID = p_ID;

        DELETE FROM DonKhamBenh 
        WHERE CuocHen_ID IN (SELECT ID FROM CuocHen WHERE BacSi_ID = p_ID);

        DELETE FROM DangKyDichVu 
        WHERE CuocHen_ID IN (SELECT ID FROM CuocHen WHERE BacSi_ID = p_ID);

        DELETE FROM CuocHen WHERE BacSi_ID = p_ID;

        DELETE FROM KyThuatVien_KiNang WHERE NhanVien_ID = p_ID;

        DELETE FROM BacSi            WHERE NhanVien_ID = p_ID;
        DELETE FROM YTa             WHERE NhanVien_ID = p_ID;
        DELETE FROM KyThuatVien     WHERE NhanVien_ID = p_ID;
        DELETE FROM NhanVienVanPhong WHERE NhanVien_ID = p_ID;
        DELETE FROM QuanLi          WHERE ID = p_ID;

        DELETE FROM NhanVien WHERE ID = p_ID;
    COMMIT;
END$$
DELIMITER ;


-- 2.1.4 Thủ tục DELETE CuocHen
DROP PROCEDURE IF EXISTS sp_DeleteCuocHen;
DELIMITER $$

CREATE PROCEDURE sp_DeleteCuocHen(IN p_CuocHenID INT)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Lỗi hệ thống khi xóa cuộc hẹn.';
    END;

    IF NOT EXISTS (SELECT 1 FROM CuocHen WHERE ID = p_CuocHenID) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Mã cuộc hẹn không tồn tại.';
    END IF;

    IF EXISTS (SELECT 1 FROM DonKhamBenh WHERE CuocHen_ID = p_CuocHenID) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Cuộc hẹn này đã tiến hành khám và có hồ sơ bệnh án. Không thể xóa!';
    END IF;

    IF EXISTS (
        SELECT 1 
        FROM DangKyDichVu 
        WHERE CuocHen_ID = p_CuocHenID 
          AND TrangThaiThanhToan = 'Đã thanh toán'
    ) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi: Cuộc hẹn này có dịch vụ ĐÃ THANH TOÁN. Không thể xóa chứng từ tài chính!';
    END IF;

    START TRANSACTION;
        DELETE FROM DangKyDichVu WHERE CuocHen_ID = p_CuocHenID;
        DELETE FROM CuocHen WHERE ID = p_CuocHenID;
    COMMIT;
END$$
DELIMITER ;


-- ============================================
--  2.2 TRIGGER
-- ============================================

-- 2.2.1 Trigger Ràng buộc Kỹ năng KTV
-- MySQL tách ra AFTER INSERT và AFTER UPDATE

DROP TRIGGER IF EXISTS trg_Check_KyNang_KTV_AI;
DROP TRIGGER IF EXISTS trg_Check_KyNang_KTV_AU;
DELIMITER $$

CREATE TRIGGER trg_Check_KyNang_KTV_AI
AFTER INSERT ON ThucHien
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM XetNghiem xn
        JOIN LoaiXetNghiem lx ON lx.ID = xn.LoaiXetNghiem_ID
        LEFT JOIN KyThuatVien_KiNang kk 
               ON kk.NhanVien_ID = NEW.NhanVien_ID 
              AND kk.KiNang_ID = lx.KiNangYC_ID
        WHERE xn.ID = NEW.XetNghiem_ID
          AND kk.KiNang_ID IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi ràng buộc: Kỹ thuật viên không có kỹ năng phù hợp với loại xét nghiệm này.';
    END IF;
END$$

CREATE TRIGGER trg_Check_KyNang_KTV_AU
AFTER UPDATE ON ThucHien
FOR EACH ROW
BEGIN
    IF EXISTS (
        SELECT 1
        FROM XetNghiem xn
        JOIN LoaiXetNghiem lx ON lx.ID = xn.LoaiXetNghiem_ID
        LEFT JOIN KyThuatVien_KiNang kk 
               ON kk.NhanVien_ID = NEW.NhanVien_ID 
              AND kk.KiNang_ID = lx.KiNangYC_ID
        WHERE xn.ID = NEW.XetNghiem_ID
          AND kk.KiNang_ID IS NULL
    ) THEN
        SIGNAL SQLSTATE '45000' 
            SET MESSAGE_TEXT = 'Lỗi ràng buộc: Kỹ thuật viên không có kỹ năng phù hợp với loại xét nghiệm này.';
    END IF;
END$$
DELIMITER ;


-- 2.2.2 Trigger tính Tổng chi phí HoaDon
DROP TRIGGER IF EXISTS trg_Update_TongChiPhi_AI;
DROP TRIGGER IF EXISTS trg_Update_TongChiPhi_AU;
DELIMITER $$

CREATE TRIGGER trg_Update_TongChiPhi_AI
AFTER INSERT ON HoaDon
FOR EACH ROW
BEGIN
    UPDATE HoaDon hd
    SET TongChiPhi = (
        IFNULL((
            SELECT SUM(t.DonGia * dvt.SoLuong)
            FROM DonKhamBenhVaThuoc dvt
            JOIN Thuoc t ON t.ID = dvt.Thuoc_ID
            WHERE dvt.DonKhamBenh_ID = hd.DonKhamBenh_ID
        ), 0)
        +
        IFNULL((
            SELECT SUM(dv.GiaDichVu)
            FROM DonKhamBenh dk
            JOIN CuocHen ch ON ch.ID = dk.CuocHen_ID
            JOIN DangKyDichVu dd ON dd.CuocHen_ID = ch.ID
            JOIN DichVu dv ON dv.ID = dd.DichVu_ID
            WHERE dk.ID = hd.DonKhamBenh_ID
        ), 0)
    )
    WHERE hd.ID = NEW.ID;
END$$

CREATE TRIGGER trg_Update_TongChiPhi_AU
AFTER UPDATE ON HoaDon
FOR EACH ROW
BEGIN
    UPDATE HoaDon hd
    SET TongChiPhi = (
        IFNULL((
            SELECT SUM(t.DonGia * dvt.SoLuong)
            FROM DonKhamBenhVaThuoc dvt
            JOIN Thuoc t ON t.ID = dvt.Thuoc_ID
            WHERE dvt.DonKhamBenh_ID = hd.DonKhamBenh_ID
        ), 0)
        +
        IFNULL((
            SELECT SUM(dv.GiaDichVu)
            FROM DonKhamBenh dk
            JOIN CuocHen ch ON ch.ID = dk.CuocHen_ID
            JOIN DangKyDichVu dd ON dd.CuocHen_ID = ch.ID
            JOIN DichVu dv ON dv.ID = dd.DichVu_ID
            WHERE dk.ID = hd.DonKhamBenh_ID
        ), 0)
    )
    WHERE hd.ID = NEW.ID;
END$$
DELIMITER ;


-- ============================================
--  2.3 THỦ TỤC TRUY VẤN
-- ============================================

-- 2.3.1 Liệt kê cuộc hẹn của Bác sĩ 
DROP PROCEDURE IF EXISTS sp_ListAppointments;
DELIMITER $$

CREATE PROCEDURE sp_ListAppointments(
    IN p_BacSiID CHAR(7)
)
BEGIN
    SELECT DISTINCT 
        ch.ID      AS MaCuocHen,
        bn.HoTen   AS TenBenhNhan,
        ch.NgayGio,
        ch.TinhTrang
    FROM CuocHen ch
    JOIN DangKyDichVu dk ON dk.CuocHen_ID = ch.ID
    JOIN BenhNhan   bn ON bn.ID = dk.BenhNhan_ID
    WHERE ch.BacSi_ID = p_BacSiID
    ORDER BY ch.NgayGio DESC;
END$$
DELIMITER ;


-- 2.3.2 Thống kê dịch vụ theo bệnh nhân (theo năm)
DROP PROCEDURE IF EXISTS sp_DichVuTheoBenhNhan;
DELIMITER $$

CREATE PROCEDURE sp_DichVuTheoBenhNhan(
    IN p_MinSoLuong INT,
    IN p_Nam INT
)
BEGIN
    SELECT 
        bn.ID, 
        bn.HoTen, 
        COUNT(*) AS SoLanSuDung
    FROM DangKyDichVu d
    JOIN BenhNhan bn ON bn.ID = d.BenhNhan_ID
    JOIN CuocHen ch ON ch.ID = d.CuocHen_ID
    WHERE YEAR(ch.NgayGio) = p_Nam
    GROUP BY bn.ID, bn.HoTen
    HAVING COUNT(*) >= p_MinSoLuong
    ORDER BY SoLanSuDung DESC;
END$$
DELIMITER ;


-- ============================================
--  2.4 HÀM (FUNCTIONS)
-- ============================================

-- 2.4.1 Tính tổng tiền thuốc 
DROP FUNCTION IF EXISTS fn_TongTienThuoc;
DELIMITER $$

CREATE FUNCTION fn_TongTienThuoc(p_DonKham_ID INT)
RETURNS DECIMAL(18,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_Tong DECIMAL(18,2) DEFAULT 0;

    -- Nếu đơn khám không tồn tại -> trả 0
    IF NOT EXISTS (SELECT 1 FROM DonKhamBenh WHERE ID = p_DonKham_ID) THEN
        RETURN 0;
    END IF;

    SELECT IFNULL(SUM(t.DonGia * d.SoLuong), 0)
    INTO v_Tong
    FROM DonKhamBenhVaThuoc d
    JOIN Thuoc t ON t.ID = d.Thuoc_ID
    WHERE d.DonKhamBenh_ID = p_DonKham_ID;

    RETURN v_Tong;
END$$
DELIMITER ;


-- 2.4.2 Kiểm tra BHYT 
DROP FUNCTION IF EXISTS fn_BHYT_HopLe;
DELIMITER $$

CREATE FUNCTION fn_BHYT_HopLe(p_BenhNhan_ID INT)
RETURNS TINYINT(1)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_NgayHetHan DATE;

    SELECT NgayHetHanBHYT
    INTO v_NgayHetHan
    FROM BenhNhan
    WHERE ID = p_BenhNhan_ID;

    IF v_NgayHetHan IS NULL THEN
        RETURN 0;
    END IF;

    IF v_NgayHetHan >= CURDATE() THEN
        RETURN 1;
    END IF;

    RETURN 0;
END$$
DELIMITER ;
