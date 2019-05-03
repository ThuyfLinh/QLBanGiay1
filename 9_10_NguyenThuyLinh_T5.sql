use [10_QuanLyBanGiay_T5] -- Sử dụng database [10_QuanLyBanGiay]
GO
--1. Đưa ra mã khuyễn mãi, tên chương trình, mô tả, ngày bắt đầu, ngày kêt thúc của 1 chương trình khuyến mãi
select IDKhuyenMai,TenCT,MoTa,NgayBD,NgayKT
from KHUYENMAI
Go
select * from GIAY
SELECT IDGIAY,CHIETKHAU FROM GIAY
----------------------
EXEC USP_SearchNv @search
--------------------------------------------
alter proc USP_SearchKM(@ten nvarchar(200))
as
begin
	select KHUYENMAI.IDKhuyenMai,IDGiay,CTKhuyenMai.ChietKhau
	from CTKHUYENMAI,KHUYENMAI
	where CTKHUYENMAI.IDKhuyenMai=KHUYENMAI.IDKhuyenMai
	and TenCT like N'%'+@ten+'%'
end

exec USP_SearchKM tine
--------------------------------
create proc USP_ListCTKM(@ma int)
as
begin
SELECT IDKHUYENMAI,IDGIAY,CHIETKHAU FROM CTKHUYENMAI WHERE IDKHUYENMAI = @ma
end

exec USP_ListCTKM 25
----------------------------------------
alter proc USP_SearchGiay(@ten nvarchar(200))
as
begin
	select IDGiay,TenGiay,SoLuong,DonGia
	from GIAY
	where TenGiay like N'%'+@ten+'%'
end

exec USP_SearchGiay Nike

--------------------------------
update Giay
set TenGiay = N'Nike 35'
where IDGiay=3

create proc USP_UpdateGiay(@maGiay int, @ten nvarchar(200),@soluong int, @dongia decimal(15,2))
as
begin
	update Giay
	set TenGiay = @ten, SoLuong = @soluong , DonGia= @dongia
	where IDGiay = @maGiay
end

exec USP_UpdateGiay 1,N'Nike 34',100,200000
------------------------------
create proc USP_DeleteCTKM(@maGiay int, @maKM int)
as
begin
	delete CTKHUYENMAI
	where IDGiay = @maGiay
	and IDKhuyenMai=@maKM
end
select * from CTKHUYENMAI
exec USP_DeleteCTKM 1,6
------------------------------


-----------------------------
select * from Giay
--2. Đưa ra ten CT khuyến mãi, mã hóa đơn đc khuyến mãi với mã khuyến mãi là 1
select TenCT, IDHoaDon
from KHUYENMAI,HOADONBAN
where KHUYENMAI.IDKhuyenMai=6
GO

--3. Đưa ra mã khuyến mãi, tên ct khuyễn mãi, mã giày và tên loại giày được khuyến mãi 
select KHUYENMAI.IDKhuyenMai,TenCT,GIAY.IDGiay,TenGiay
from KHUYENMAI,CTKHUYENMAI,GIAY
where KHUYENMAI.IDKhuyenMai=CTKHUYENMAI.IDKhuyenMai
and CTKHUYENMAI.IDGiay=GIAY.IDGiay
GO

-- 4. Đưa ra chương trình có nhiều loại khuyến mãi sản phẩm nhất
 -- Tạo view để đếm số chương trình khuyến mãi có khuyến mãi sản phẩm
create view SPmax
As
Select KHUYENMAI.IDKhuyenMai,TenCT,count(CTKHUYENMAI.IDKhuyenMai) as KMmax
From KHUYENMAI,CTKHUYENMAI
Where KHUYENMAI.IDKhuyenMai=CTKHUYENMAI.IDKhuyenMai
Group by KHUYENMAI.IDKhuyenMai,TenCT
GO
 -- Đưa ra danh sách chương trình có số khuyến mãi sản phẩm nhiều nhất
Select *
From SPmax
Where KMmax =(
	Select max(KMmax)
	From SPmax
)
GO
-- 5. Đưa ra chương trình khuyến mãi có chiết khấu nhiều nhất theo từng đợt khuyến mãi
 -- tạo view đưa ra chương trình khuyến mãi có chiết khấu nhiều nhất theo từng đợt khuyến mãi
create view KMmax
as
select KHUYENMAI.IDKhuyenMai,TenCT,max(CTKHUYENMAI.ChietKhau) as CKmax
from KHUYENMAI,CTKHUYENMAI
where KHUYENMAI.IDKhuyenMai=CTKHUYENMAI.IDKhuyenMai
group by KHUYENMAI.IDKhuyenMai,TenCT
GO
 -- đưa ra danh sách chương trình khuyến mãi có chiết khấu nhiều nhất theo từng đợt
select *
from KMmax 
GO

-- 6. Tạo trigger xóa 1 chương trình khuyên mãi
alter trigger XoaKM on KHUYENMAI 
instead of delete
as
declare @ma int
begin
	select @ma = IDKhuyenMai from deleted
	-- xóa mã khuyến mãi ở bảng chi tiết khuyến mãi
	delete CTKHUYENMAI
	where IDKhuyenMai=@ma
	-- update mã khuyến mãi ở bảng hóa đơn bán 
	Update HOADONBAN
	set IDkhuyenMai=null
	where IDkhuyenMai=@ma
	-- xóa mã khuyến mãi ở bảng khuyến mãi
	delete KHUYENMAI
	where IDKhuyenMai=@ma
	
end
GO
  -- xóa mã khuyến mãi 12
delete KHUYENMAI
where IDKhuyenMai=12
GO

-- 7.Tạo trigger khi sửa 1 chi tiết khuyến mãi
create trigger XoaCTKM on CTKhUYENMAI
for update
as
declare @IDKM int
begin
	-- đưa ra ma xkhuyeens mãi muốn cập nhật
	select @IDKM=IDKhuyenMai from deleted
	print N'Cập nhật mã khuyến mãi : '+ convert(char(10),@IDKM)
	-- đưa ra mã khuyến mãi sau khi cập nhật
	select @IDKM=IDKhuyenMai from inserted
	print N'Thành : '+ convert(char(10),@IDKM)
end
GO
 -- update mã khuyến mãi từ 8 thành 6
update CTKHUYENMAI
set IDKhuyenMai=6
where IDKhuyenMai=8
GO

--8. Tạo thủ tục thống kê các loại giày được chiết khấu với mã khuyến mãi là 4
 -- Tạo thủ tục thống kê laoij giày được chiết khấu theo sản phẩm với mã khuyến mãi muốn có
create proc ThongKeKM(@IDKM int)
as
begin
	select IDGiay,TenGiay,DonGia
	from GIAY
	where IDGiay in(
		select IDGiay
		from CTKHUYENMAI
		where IDKhuyenMai in(
			select IDKhuyenMai
			from KHUYENMAI
			where IDKhuyenMai=@IDKM
		)
	)
end
GO
-- dưa ra danh sách giày với mã khuyến mãi là 4
exec ThongKeKM 16
GO
------------------------------------
 -- Tạo thủ tục thống kê laoij giày được chiết khấu theo sản phẩm với mã khuyến mãi muốn có
alter proc ThongKeKMSP(@IDKM int)
as
begin
select * from
(select KHUYENMAI.IDKhuyenMai,TenCT,MoTa,NgayBD,NgayKT,ck,TenGiay,ChietKhau from
	(select IDKhuyenMai,GIAY.IDGiay,TenGiay,CTKHUYENMAI.ChietKhau as ck
	from GIAY,CTKHUYENMAI
	where GIAY.IDGiay=CTKHUYENMAI.IDGiay 
	)as a right join KHUYENMAI on KHUYENMAI.IDKhuyenMai=a.IDKhuyenMai) as b where b.IDKhuyenMai=@IDKM
end
GO

exec ThongKeKMSP 18
Go
-------------------------------------
-- 9. Tạo thủ tục đưa ra các hóa đơn bán và chi tiết hóa đơn bán được khuyến mãi theo tổng tiền với mã khuyến mãi là 12
 -- Tạo thủ tục đưa ra hóa đơn bán và chi tiết hóa đơn bán được khuyến mãi theo tổng tiền với mã khuyến mãi muốn có
create proc TK (@IDKM int)
as
begin
	select HOADONBAN.IDHoaDon,IDGiay,SoLuong,DonGiaBan,Ngay,ChietKhau
	from CTHOADONBAN,HOADONBAN
	where CTHOADONBAN.IDHoaDon=HOADONBAN.IDHoaDon
	and HOADONBAN.IDkhuyenMai in(
		select IDkhuyenMai
		from KHUYENMAI
		where IDkhuyenMai= @IDKM
	)
end
GO
-- đưa ra danh sách hóa đơn bán và bảng chi tiết hóa đơn bán vơi smax khuyến mãi là 12
exec TK 12
GO

--10. Tạo thủ tục đưa ra chương trình khuyến mãi của 1 mã khuyến mãi
create proc Thongke(@IDKM int)
as
begin
	if (select ChietKhau from KHUYENMAI where IDKhuyenMai=@IDKM) is not null
		select KHUYENMAI.IDKhuyenMai,TenCT,MoTa,NgayBD,NgayKT,ChietKhau
		from KHUYENMAI
		where KHUYENMAI.IDKhuyenMai=@IDKM
	else
		select KHUYENMAI.IDKhuyenMai,TenCT,MoTa,NgayBD,NgayKT,IDGiay,CTKHUYENMAI.ChietKhau
		from KHUYENMAI,CTKHUYENMAI
		where KHUYENMAI.IDKhuyenMai=CTKHUYENMAI.IDkhuyenMai
		and KHUYENMAI.IDKhuyenMai=@IDKM
end
GO
 -- đưa ra chương trình khuyến mãi của mã khuyến mãi là 11
exec Thongke 5
GO
--------------------------------------------------------------------------------
alter proc pro_PhieuXuatTheoMa(@IDKM int)
as
begin
	declare @stt int, @TenCT nvarchar(200), @MoTa nvarchar(200),@NgayBD date, @NgayKT date, @ChietKhau float,@IDGiay int
	set @stt = 1
	if (select ChietKhau from KHUYENMAI where IDKhuyenMai=@IDKM) is not null
			select @TenCT = TenCT from KHUYENMAI
			select @MoTa = MoTa from KHUYENMAI
			select @NgayBD=NgayBD from KHUYENMAI
			select @NgayKT=NgayKT from KHUYENMAI
			select @ChietKhau=ChietKhau from KHUYENMAI
			print N'               CHƯƠNG TRÌNH KHUYẾN MẠI '
			print N''
			print N'Tên chương trình: '+@TenCT
			print N''
			print N'Mô tả: '+@MoTa 
			print N''
			print N'Ngày bắt đầu: '+cast(@NgayBD as nchar(20))
			print N''
			print N'Ngày kết thúc: '+cast(@NgayKT as nchar(20))
			print N''
			print N'Chiết khấu' +cast(@ChietKhau as nchar(20))
		
	  if (select ChietKhau from KHUYENMAI where IDKhuyenMai=@IDKM) is null
			select @TenCT = TenCT from KHUYENMAI
			select @MoTa = MoTa from KHUYENMAI
			select @NgayBD=NgayBD from KHUYENMAI
			select @NgayKT=NgayKT from KHUYENMAI
			select @ChietKhau=ChietKhau from CTKHUYENMAI
			select @IDGiay=IDGiay from CTKHUYENMAI
			print N'               CHƯƠNG TRÌNH KHUYẾN MẠI '
			print N''
			print N'Tên chương trình: '+@TenCT
			print N''
			print N'Mô tả: '+@MoTa 
			print N''
			print N'Ngày bắt đầu: '+cast(@NgayBD as nchar(20))
			print N''
			print N'Ngày kết thúc: '+cast(@NgayKT as nchar(20))
			print N''
			print N'STT    Mã giày     Chiết khấu'
	declare ConTro cursor forward_only for
		select IDGiay,ChietKhau
		from CTKHUYENMAI
		where CTKHUYENMAI.IDKhuyenMai=@IDKM
		open ConTro
			while @@FETCH_STATUS = 0 -- khi vẫn còn lấy đc tiếp 
			begin
				FETCH next FROM ConTro -- lấy tương ứng với câu select của con trỏ
				into @IDgiay,@ChietKhau -- đổ dữ liệu các biến
				if @@FETCH_STATUS <> 0 -- nếu như k đỏ đc nữa thì sẽ in ra thông tin .
				break
				print +cast(@stt as nchar(10)) + cast(@IDGiay as nchar(11)) + cast(@ChietKhau as nchar(11))
				set @stt = @stt + 1
			end
		close ConTro
		deallocate ConTro
end
go
pro_PhieuXuatTheoMa 28
go

alter proc CTKM(@IDKM int)
as
begin
	declare @stt int, @TenCT nvarchar(200), @MoTa nvarchar(200),@NgayBD date, @NgayKT date, @ChietKhau float,@IDGiay int
	set @stt = 1
	if (select ChietKhau from KHUYENMAI where IDKhuyenMai=@IDKM) is not null
			select @TenCT = TenCT from KHUYENMAI
			select @MoTa = MoTa from KHUYENMAI
			select @NgayBD=NgayBD from KHUYENMAI
			select @NgayKT=NgayKT from KHUYENMAI
			select @ChietKhau=ChietKhau from KHUYENMAI
			print N'               CHƯƠNG TRÌNH KHUYẾN MẠI '
			print N''
			print N'Tên chương trình: '+@TenCT
			print N''
			print N'Mô tả: '+@MoTa 
			print N''
			print N'Ngày bắt đầu: '+cast(@NgayBD as nchar(20))
			print N''
			print N'Ngày kết thúc: '+cast(@NgayKT as nchar(20))
			print N''
			print N'Chiết khấu' +cast(@ChietKhau as nchar(20))
		
	  if (select ChietKhau from KHUYENMAI where IDKhuyenMai=@IDKM) is null
			select @TenCT = TenCT from KHUYENMAI
			select @MoTa = MoTa from KHUYENMAI
			select @NgayBD=NgayBD from KHUYENMAI
			select @NgayKT=NgayKT from KHUYENMAI
			select @ChietKhau=ChietKhau from CTKHUYENMAI
			select @IDGiay=IDGiay from CTKHUYENMAI
			print N'               CHƯƠNG TRÌNH KHUYẾN MẠI '
			print N''
			print N'Tên chương trình: '+@TenCT
			print N''
			print N'Mô tả: '+@MoTa 
			print N''
			print N'Ngày bắt đầu: '+cast(@NgayBD as nchar(20))
			print N''
			print N'Ngày kết thúc: '+cast(@NgayKT as nchar(20))
			print N''
			print N'STT    Mã giày     Chiết khấu'
	declare ConTro cursor forward_only for
		select IDGiay,ChietKhau
		from CTKHUYENMAI
		where CTKHUYENMAI.IDKhuyenMai=@IDKM
		open ConTro
			while @@FETCH_STATUS = 0 -- khi vẫn còn lấy đc tiếp 
			begin
				FETCH next FROM ConTro -- lấy tương ứng với câu select của con trỏ
				into @IDgiay,@ChietKhau -- đổ dữ liệu các biến
				if @@FETCH_STATUS <> 0 -- nếu như k đỏ đc nữa thì sẽ in ra thông tin .
				break
				print cast(@stt as nchar(10)) + cast(@IDGiay as nchar(11)) + cast(@ChietKhau as nchar(11))
				set @stt = @stt + 1
			end
		close ConTro
		deallocate ConTro
end
go
CTKM 28
go

------------------------------------------------------------


alter proc pro_PhieuXuatTheo(@IDKM int)
as
begin
	declare @stt int, @TenCT nvarchar(200), @MoTa nvarchar(200),@NgayBD date, @NgayKT date, @ChietKhau float,@IDGiay int
	set @stt = 1
	select @TenCT = TenCT from KHUYENMAI
	select @MoTa = MoTa from KHUYENMAI
	select @NgayBD=NgayBD from KHUYENMAI
	select @NgayKT=NgayKT from KHUYENMAI
	select @ChietKhau=ChietKhau from KHUYENMAI
	select ChietKhau from KHUYENMAI
	select @IDGiay=IDGiay from CTKHUYENMAI
	print N'               CHƯƠNG TRÌNH KHUYẾN MẠI '
	print N''
	print N'Tên chương trình: '+@TenCT
	print N''
	print N'Mô tả: '+@MoTa 
	print N''
	print N'Ngày bắt đầu: '+cast(@NgayBD as nchar(20))
	print N''
	print N'Ngày kết thúc: '+cast(@NgayKT as nchar(20))
	print N''
	print N'Chiết khấu' +cast(@ChietKhau as nchar(20))
	print N''
	print N'STT    Mã giày     Chiết khấu'
declare ConTro cursor forward_only for
		select IDGiay,ChietKhau
		from CTKHUYENMAI
		where CTKHUYENMAI.IDKhuyenMai=@IDKM
	open ConTro
		while @@FETCH_STATUS = 0 -- khi vẫn còn lấy đc tiếp 
		begin
			FETCH next FROM ConTro -- lấy tương ứng với câu select của con trỏ
			into @IDgiay,@ChietKhau -- đổ dữ liệu các biến
			if @@FETCH_STATUS <> 0 -- nếu như k đỏ đc nữa thì sẽ in ra thông tin .
			break
			print +cast(@stt as nchar(10)) + + cast(@IDGiay as nchar(20)) + cast(@ChietKhau as nchar(20))
			set @stt = @stt + 1
		end
		
		close ConTro
		deallocate ConTro
end
go

pro_PhieuXuatTheo 20
go