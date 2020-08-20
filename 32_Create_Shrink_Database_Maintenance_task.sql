--
---------------------------------------------------------------------
--Create_Shrink_Database_Maintenance_task
---------------------------------------------------------------------
--
USE [msdb]
GO

/****** Object:  Job [DBA_WM_Shrink_Database.Exec]    Script Date: 13/08/2020 12:28:20 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 13/08/2020 12:28:20 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_WM_Shrink_Database.Exec', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Exec]    Script Date: 13/08/2020 12:28:20 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Exec', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'

Declare @dbname table (sno int identity(1,1), name varchar(100))
Declare @dB_name varchar(100), @i int = (Select count(1) from sys.databases where state = 0 )
Declare @SQL nvarchar(max);
insert into @dbname (name)
Select name from sys.databases where state = 0 order by name desc
--Select * from @dbname

While (@@ROWCOUNT > 0 and @i > 0)
Begin
Select @db_name = name from @dbname where sno = @i
	select @SQL = ''	USE '' + @db_name + ''

Declare @DBFileName sysname
Declare @TargetFreeMB int
Declare @ShrinkIncrementMB int

-- Set Name of Database file to shrink
set @DBFileName = '''''' + @db_name + ''''''  --<--- CHANGE HERE !!
-- Set Desired file free space in MB after shrink
set @TargetFreeMB = 5000			--<--- CHANGE HERE !!
-- Set Increment to shrink file by in MB
set @ShrinkIncrementMB = 500			--<--- CHANGE HERE !!

-- Show Size, Space Used, Unused Space, and Name of all database files
select	[FileSizeMB]    =	convert(numeric(10,2),round(a.size/128.,2)),
        [UsedSpaceMB]   =	convert(numeric(10,2),round(fileproperty( a.name,''''SpaceUsed'''')/128.,2)) ,
        [UnusedSpaceMB] =	convert(numeric(10,2),round((a.size-fileproperty( a.name,''''SpaceUsed''''))/128.,2)) ,
        [DBFileName]    = a.name
from	sysfiles a

Declare @sql varchar(8000)
Declare @SizeMB int
Declare @UsedMB int

-- Get current file size in MB
select @SizeMB = size/128. from sysfiles where name = @DBFileName
-- Get current space used in MB
Select @UsedMB = fileproperty( @DBFileName,''''SpaceUsed'''')/128.
select [StartFileSize] = @SizeMB, [StartUsedSpace] = @UsedMB, [DBFileName] = @DBFileName

-- Loop until file at desired size
while  @SizeMB > @UsedMB+@TargetFreeMB+@ShrinkIncrementMB
        begin

        set @sql =	''''dbcc shrinkfile ( '''' + @DBFileName + '''', '''' +
        convert(varchar(20),@SizeMB-@ShrinkIncrementMB)+'''' ) ''''

        print ''''Start '''' + @sql
        print ''''at ''''+convert(varchar(30),getdate(),121)

        exec ( @sql )

        print ''''Done  '''' + @sql
        print ''''at ''''+convert(varchar(30),getdate(),121)

        -- Get current file size in MB
        select @SizeMB = size/128. from sysfiles where name = @DBFileName
        -- Get current space used in MB
        select @UsedMB = fileproperty( @DBFileName,''''SpaceUsed'''')/128.

        select [FileSize] = @SizeMB, [UsedSpace] = @UsedMB, [DBFileName] = @DBFileName
        end

select [EndFileSize] = @SizeMB, [EndUsedSpace] = @UsedMB, [DBFileName] = @DBFileName

-- Show Size, Space Used, Unused Space, and Name of all database files
select
        [FileSizeMB]    =	convert(numeric(10,2),round(a.size/128.,2)),
        [UsedSpaceMB]   =	convert(numeric(10,2),round(fileproperty( a.name,''''SpaceUsed'''')/128.,2)) ,
        [UnusedSpaceMB] =	convert(numeric(10,2),round((a.size-fileproperty( a.name,''''SpaceUsed''''))/128.,2)) ,
        [DBFileName]    = a.name
from	sysfiles a
''
		Print @db_name
		--Print @SQL
	EXEC (@SQL);
Set @i = @i - 1
END', 
		@database_name=N'master', 
		@output_file_name=N'D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\Database_Shrink.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Trigger_DBA_WM_RebuildIndexes]    Script Date: 13/08/2020 12:28:21 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Trigger_DBA_WM_RebuildIndexes', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE msdb ;  
GO  
  
EXEC dbo.sp_start_job N''DBA_WM_RebuildIndexes.Exec'' ;  
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO



--
---------------------------------------------------------------------