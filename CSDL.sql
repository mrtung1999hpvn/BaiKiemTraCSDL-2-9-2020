CREATE DATABASE BaiKiemTra
GO
USE BaiKiemTra
GO
CREATE TABLE TinhThanh
(
	MaTT NVARCHAR(10) PRIMARY KEY,
	TenTT NVARCHAR(100),
)
GO
CREATE TABLE CongTy
(
	MaCT NVARCHAR(10) PRIMARY KEY,
	TenCT NVARCHAR(200),
	DiaChi NVARCHAR(500),
	MST NVARCHAR(10),
	NgayThanhLap DATE,
	SoVon BIGINT,
	MaTT NVARCHAR(10),
	FOREIGN KEY (MaTT) REFERENCES TinhThanh(MaTT),
)	
GO
CREATE TABLE LoaiLinhVuc
(
	MaLV NVARCHAR(10) PRIMARY KEY,
	TenLV NVARCHAR(100),
)
GO
CREATE TABLE LinhVucKinhDoanh
(
	MaLV NVARCHAR(10),
	FOREIGN KEY (MaLV) REFERENCES LoaiLinhVuc(MaLV),
	MaCT NVARCHAR(10),
	FOREIGN KEY (MaCT) REFERENCES CongTy(MaCT),
	NgayDangKy DATE,
)
GO

-- 1 , Thêm vào bảng Tỉnh Thành thành phố Hải Phòng có mã là HP ; 
-- thêm một công ty cho thành phố Hải Phòng
INSERT INTO TinhThanh(MaTT,TenTT)
VALUES (N'HP',N'Hải Phòng')
INSERT INTO TinhThanh(MaTT,TenTT)
VALUES (N'HN',N'Hà Nội')
INSERT INTO CongTy(MaCT,MaTT,TenCT,DiaChi,MST,NgayThanhLap,SoVon)
VALUES (N'CT0001',N'HP',N'Công ty phần mềm A',N'Đường Lạch Tray',N'MST0001',N'2010-08-08',1000000000000)
INSERT INTO CongTy(MaCT,MaTT,TenCT,DiaChi,MST,NgayThanhLap,SoVon)
VALUES (N'CT0002',N'HN',N'Công ty phần mềm N',N'Đường Lạch Tray',N'MST0001',N'2016-08-08',1000000000000)
-- 2 , Sửa Lĩnh Vực có mã CNTy về CNTT (lưu ý cần sửa cả ở bảng Lĩnh Vực Kinh Doanh)
--
GO
INSERT INTO LoaiLinhVuc(MaLV,TenLV)
VALUES(N'CNTy',N'Công Nghệ Thông Tin')
INSERT INTO LinhVucKinhDoanh(MaLV,MaCT,NgayDangKy)
VALUES(N'CNTy',N'CT0001',N'2010-07-08')
INSERT INTO LinhVucKinhDoanh(MaLV,MaCT,NgayDangKy)
VALUES(N'CNTy',N'CT0001',N'2010-07-08')
INSERT INTO LinhVucKinhDoanh(MaLV,MaCT,NgayDangKy)
VALUES(N'CNTy',N'CT0001',N'2010-07-08')

-- 3 , Đưa ra các công ty của thành phố Hà Nội thành lập trong năm 2016
SELECT * FROM CongTy WHERE YEAR(NgayThanhLap)=2016 AND MaTT = N'HN'
-- 4 , Đưa ra các công ty đăng ký trên 03 lĩnh vực kinh doanh
GO
CREATE VIEW Cau4 AS
SELECT B.TenCT,COUNT(a.MaLV)[TongLinhVuc] FROM LinhVucKinhDoanh AS A , CongTy AS B
WHERE A.MaCT = B.MaCT
GROUP BY B.TenCT
GO
SELECT * FROM Cau4 WHERE [TongLinhVuc] > 3

-- 5 , Đưa ra tổng số vốn của các công ty thành lập trong năm 2016 tại từng tỉnh thành

SELECT TinhThanh.TenTT,SUM(CongTy.SoVon) FROM CongTy , TinhThanh
WHERE CongTy.MaTT = TinhThanh.MaTT AND YEAR(CongTy.NgayThanhLap) = 2016
GROUP BY TinhThanh.TenTT

-- 6 , Đưa ra mỗi lĩnh vực kinh doanh có bao nhiêu công ty

SELECT LoaiLinhVuc.MaLV,LoaiLinhVuc.TenLV,COUNT(CongTy.MaCT)'Tổng số công ty' FROM LinhVucKinhDoanh , CongTy , LoaiLinhVuc
WHERE LinhVucKinhDoanh.MaCT = CongTy.MaCT AND LoaiLinhVuc.MaLV = LinhVucKinhDoanh.MaLV
GROUP BY LoaiLinhVuc.MaLV,LoaiLinhVuc.TenLV

-- 7 , Đưa ra Tên , MST các công ty đăng ký lĩnh vực kinh doanh có tên là "Du lịch"
UPDATE LoaiLinhVuc SET TenLV =N'Du lịch' WHERE MaLV = N'CNTy'

SELECT CongTy.TenCT,CongTy.MST FROM LinhVucKinhDoanh , CongTy , LoaiLinhVuc
WHERE LinhVucKinhDoanh.MaCT = CongTy.MaCT
AND LinhVucKinhDoanh.MaLV = LoaiLinhVuc.MaLV
AND LoaiLinhVuc.TenLV = N'Du lịch'


-- 8 Đưa ra mỗi năm có bao nhiêu công ty thành lập
GO
CREATE FUNCTION Cau8(@Nam INT)
RETURNS TABLE
AS
	RETURN SELECT * FROM CongTy WHERE YEAR(CongTy.NgayThanhLap) = @Nam

GO
CREATE PROC PROC_Cau8 AS
DECLARE @NAM INT = (SELECT MIN(YEAR(NgayThanhLap)) FROM CongTy);
WHILE @NAM <= (SELECT MAX(YEAR(NgayThanhLap)) FROM CongTy)
BEGIN
	print('Các công ty thành lập năm : ' + CAST(@NAM AS NVARCHAR))
	SELECT * FROM Cau8(@NAM)
	SET @NAM = @NAM + 1;
END;
GO
GO
EXEC PROC_Cau8
