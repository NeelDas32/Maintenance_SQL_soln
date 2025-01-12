Declare @DBFileName sysname
Declare @TargetFreeMB int
Declare @ShrinkIncrementMB int
Declare @count int, @i int = 1

-- Set Name of Database file to shrink
set @DBFileName =  'IDS_Claims_Daily_OLD'--<--- CHANGE HERE !!

DROP TABLE IF EXISTS #DBfilename
Create Table #DBfilename (dbfilename varchar(100))

Insert into #DBfilename
Select Name from	sysfiles  where name not like '%log%'
select * from #DBfilename
Set @Count = (select count(1) from #DBfilename)

While (@i <= @count)
BEGIN
Select Top 1 dbfilename from #DBfilename
Set @DBFileName = (Select Top 1 dbfilename from #DBfilename)
Print @DBFileName
-- Set Desired file free space in MB after shrink
set @TargetFreeMB = 5000			--<--- CHANGE HERE !!
-- Set Increment to shrink file by in MB
set @ShrinkIncrementMB = 500			--<--- CHANGE HERE !!

-- Show Size, Space Used, Unused Space, and Name of all database files
select	[FileSizeMB]    =	convert(numeric(10,2),round(a.size/128.,2)),
        [UsedSpaceMB]   =	convert(numeric(10,2),round(fileproperty( a.name,'SpaceUsed')/128.,2)) ,
        [UnusedSpaceMB] =	convert(numeric(10,2),round((a.size-fileproperty( a.name,'SpaceUsed'))/128.,2)) ,
        [DBFileName]    = a.name
from	sysfiles a

Declare @sql varchar(8000)
Declare @SizeMB int
Declare @UsedMB int

-- Get current file size in MB
select @SizeMB = size/128. from sysfiles where name = @DBFileName
-- Get current space used in MB
Select @UsedMB = fileproperty( @DBFileName,'SpaceUsed')/128.
select [StartFileSize] = @SizeMB, [StartUsedSpace] = @UsedMB, [DBFileName] = @DBFileName

-- Loop until file at desired size
while  @SizeMB > @UsedMB+@TargetFreeMB+@ShrinkIncrementMB
        begin

        set @sql =	'dbcc shrinkfile ( '+@DBFileName+', '+
        convert(varchar(20),@SizeMB-@ShrinkIncrementMB)+' ) '

        print 'Start ' + @sql
        print 'at '+convert(varchar(30),getdate(),121)

        exec ( @sql )

        print 'Done ' + @sql
        print 'at '+convert(varchar(30),getdate(),121)

        -- Get current file size in MB
        select @SizeMB = size/128. from sysfiles where name = @DBFileName
        -- Get current space used in MB
        select @UsedMB = fileproperty( @DBFileName,'SpaceUsed')/128.

        select [FileSize] = @SizeMB, [UsedSpace] = @UsedMB, [DBFileName] = @DBFileName
        end

select [EndFileSize] = @SizeMB, [EndUsedSpace] = @UsedMB, [DBFileName] = @DBFileName
Set @i = @i + 1
Delete from #DBfilename where dbfilename = @DBFileName
select * from #DBfilename
END
-- Show Size, Space Used, Unused Space, and Name of all database files
select
        [FileSizeMB]    =	convert(numeric(10,2),round(a.size/128.,2)),
        [UsedSpaceMB]   =	convert(numeric(10,2),round(fileproperty( a.name,'SpaceUsed')/128.,2)) ,
        [UnusedSpaceMB] =	convert(numeric(10,2),round((a.size-fileproperty( a.name,'SpaceUsed'))/128.,2)) ,
        [DBFileName]    = a.name
from	sysfiles a

