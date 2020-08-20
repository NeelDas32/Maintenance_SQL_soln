--
--Create_Procedure_Shrink_Database_and_DBFiles
--
Use DBAdmin
GO
IF OBJECT_ID('usp_Shrink_Database_and_DBFiles','P') IS NOT NULL
    DROP PROC [dbo].[usp_Shrink_Database_and_DBFiles]
GO

CREATE PROC [dbo].[usp_Shrink_Database_and_DBFiles]
AS
BEGIN

Declare @dbname table (sno int identity(1,1), name varchar(100))
Declare @dB_name varchar(100), @i int = (Select count(1) from sys.databases d where d.state = 0 and d.name not in ('master','model','msdb','ReportServer','ReportServerTempDB','SSISDB','tempdb') )
Declare @SQL nvarchar(max);
insert into @dbname (name)
Select name from sys.databases d where d.state = 0 and d.name not in ('master','model','msdb','ReportServer','ReportServerTempDB','SSISDB','tempdb') order by d.name desc
--Select * from @dbname

While (@@ROWCOUNT > 0 and @i > 0)
Begin
Select @db_name = name from @dbname where sno = @i
	select @SQL = '	USE ' + @db_name + '

Declare @DBFileName sysname
Declare @TargetFreeMB int
Declare @ShrinkIncrementMB int
Declare @count int, @i int = 1

SET NOCOUNT ON
-- Set Name of Database file to shrink
set @DBFileName =  '' + @db_name + ''	--<--- CHANGE HERE !!

DROP TABLE IF EXISTS #DBfilename
Create Table #DBfilename (dbfilename varchar(100))

Insert into #DBfilename
Select Name from	sysfiles  where name not like ''%log%''
--select * from #DBfilename
Set @Count = (select count(1) from #DBfilename)

While (@i <= @count)
BEGIN
--Select Top 1 dbfilename from #DBfilename
Set @DBFileName = (Select Top 1 dbfilename from #DBfilename)
select char(13) + char(10)
Print ''Starting with Database: '' + @DBFileName
select char(10)
-- Set Desired file free space in MB after shrink
set @TargetFreeMB = 5000			--<--- CHANGE HERE !!
-- Set Increment to shrink file by in MB
set @ShrinkIncrementMB = 500			--<--- CHANGE HERE !!

-- Show Size, Space Used, Unused Space, and Name of all database files
select	[FileSizeMB]    =	convert(numeric(10,2),round(a.size/128.,2)),
        [UsedSpaceMB]   =	convert(numeric(10,2),round(fileproperty( a.name,''SpaceUsed'')/128.,2)) ,
        [UnusedSpaceMB] =	convert(numeric(10,2),round((a.size-fileproperty( a.name,''SpaceUsed''))/128.,2)) ,
        [DBFileName]    = a.name
from	sysfiles a where convert(numeric(10,2),round((a.size-fileproperty( a.name,''SpaceUsed''))/128.,2)) > 5500

Declare @sql varchar(8000)
Declare @SizeMB int
Declare @UsedMB int

-- Get current file size in MB
select @SizeMB = size/128. from sysfiles where name = @DBFileName
-- Get current space used in MB
Select @UsedMB = fileproperty( @DBFileName,''SpaceUsed'')/128.
select [StartFileSize] = @SizeMB, [StartUsedSpace] = @UsedMB, [DBFileName] = @DBFileName

-- Loop until file at desired size
while  @SizeMB > @UsedMB+@TargetFreeMB+@ShrinkIncrementMB
        begin

        set @sql =	''dbcc shrinkfile ( ''+@DBFileName+'', ''+
        convert(varchar(20),@SizeMB-@ShrinkIncrementMB)+'' ) ''

        print ''Start '' + @sql
        print ''at ''+convert(varchar(30),getdate(),121)

        exec ( @sql )

        print ''Done '' + @sql
        print ''at ''+convert(varchar(30),getdate(),121)

        -- Get current file size in MB
        select @SizeMB = size/128. from sysfiles where name = @DBFileName
        -- Get current space used in MB
        select @UsedMB = fileproperty( @DBFileName,''SpaceUsed'')/128.

        select [FileSize] = @SizeMB, [UsedSpace] = @UsedMB, [DBFileName] = @DBFileName
        end

select [EndFileSize] = @SizeMB, [EndUsedSpace] = @UsedMB, [DBFileName] = @DBFileName
Set @i = @i + 1
Delete from #DBfilename where dbfilename = @DBFileName
--select * from #DBfilename
END
-- Show Size, Space Used, Unused Space, and Name of all database files
select
        [FileSizeMB]    =	convert(numeric(10,2),round(a.size/128.,2)),
        [UsedSpaceMB]   =	convert(numeric(10,2),round(fileproperty( a.name,''SpaceUsed'')/128.,2)) ,
        [UnusedSpaceMB] =	convert(numeric(10,2),round((a.size-fileproperty( a.name,''SpaceUsed''))/128.,2)) ,
        [DBFileName]    = a.name
from	sysfiles a
'
		Print @db_name
		--Print @SQL
	EXEC (@SQL);
Set @i = @i - 1
END
END
-----------------------------------------------------------------------
-----------------------------------------------------------------------