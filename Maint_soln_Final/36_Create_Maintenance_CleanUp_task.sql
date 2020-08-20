-----------------------------------------------------------------
-----------------------------------------------------------------
--Create_Maintenance_CleanUp_task
-----------------------------------------------------------------
-----------------------------------------------------------------
USE [msdb]
GO

/****** Object:  Job [DBA_WM_Maintenance_CleanUp.Exec]    Script Date: 14/08/2020 12:42:54 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 14/08/2020 12:42:54 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_WM_Maintenance_CleanUp.Exec', 
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
/****** Object:  Step [Exec]    Script Date: 14/08/2020 12:42:55 AM ******/
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
		@command=N'declare @datevalue datetime, @path varchar(200)
Set @datevalue = (Select DATEADD(week, -9, getdate()))		--9 weeks old files
Print @datevalue

--Maintenance Plan cleanup of TXT file older than 9 weeks
EXECUTE master.dbo.xp_delete_file 1,N''D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log'',N''txt'', @datevalue


--Maintenance Plan cleanup of History older than 9 weeks
EXECUTE msdb..sp_maintplan_delete_log null,null,@datevalue
', 
		@database_name=N'master', 
		@output_file_name=N'D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\Maintenance_CleanUp.txt', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Trigger_usp_Maintenance_Job_Run_time]    Script Date: 14/08/2020 12:42:55 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Trigger_usp_Maintenance_Job_Run_time', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Use DBAdmin
GO
Exec usp_Maintenance_Job_Run_time

', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Trigger_usp_Send_Weekly_Main_Task_Email]    Script Date: 14/08/2020 12:42:55 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Trigger_usp_Send_Weekly_Main_Task_Email', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Use DBAdmin
GO
Exec usp_Send_Weekly_Main_Task_Email', 
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
-----------------------------------------------------------------
-----------------------------------------------------------------