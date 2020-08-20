--
---------------------------------------------------------------------
--Create_DB_Integrity_Check_Maintenance_task
---------------------------------------------------------------------
--
USE [msdb]
GO

/****** Object:  Job [DBA_WM_DB_Integrity_check.Exec]    Script Date: 16/08/2020 12:12:49 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 16/08/2020 12:12:49 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_WM_DB_Integrity_check.Exec', 
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
/****** Object:  Step [TRUNCATE_Table_DBCC_History]    Script Date: 16/08/2020 12:12:50 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'TRUNCATE_Table_DBCC_History', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE DBAdmin 
GO  
TRUNCATE TABLE [dbo].[DBCC_History];  
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Exec]    Script Date: 16/08/2020 12:12:49 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Exec', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Declare @dbname table (sno int identity(1,1), name varchar(100))
Declare @dB_name varchar(100), @i int = (Select count(1) from sys.databases where state = 0 )
Declare @SQL nvarchar(max);
insert into @dbname (name)
Select name from sys.databases where state = 0 order by name desc
--Select * from @dbname

While (@@ROWCOUNT > 0 and @i > 0)
Begin
Select @db_name = name from @dbname where sno = @i
	select @SQL = ''EXEC DBAdmin..usp_CheckDBIntegrity '''''' + @db_name + '''''' ;''
		--Print @db_name
		Print @SQL
	EXEC (@SQL);
Set @i = @i - 1
END', 
		@database_name=N'master', 
		@output_file_name=N'D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\DB_Intergrity_Check.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Trigger_DBA_WM_Shrink_DB]    Script Date: 16/08/2020 12:12:50 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Trigger_DBA_WM_Shrink_DB', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE msdb 
GO  
  
EXEC dbo.sp_start_job N''DBA_WM_Shrink_Database.Exec'';  
GO', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'DBA_WM_DB_Integrity_check', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20200811, 
		@active_end_date=99991231, 
		@active_start_time=220000, 
		@active_end_time=235959 
		--@schedule_uid=N'736cd8b1-fae0-4d9d-a0a6-339d6cd4ed69'
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