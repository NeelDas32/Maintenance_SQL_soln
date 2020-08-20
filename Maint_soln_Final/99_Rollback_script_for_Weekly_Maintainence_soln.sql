--
--Rollback script
--
--
USE [DBAdmin]
GO
--Drop table
DROP Table [dbo].[DBCC_History]
GO
DROP Table [dbo].[Maintenance_Job_Run_time]
GO
DROP Table [dbo].[DBMail_Send_Param]
GO


--Drop Procedure
DROP PROCEDURE [dbo].[usp_CheckDBIntegrity]
GO
DROP PROCEDURE [dbo].[usp_Rebuild_ReOrg_Indexes]
GO
DROP PROCEDURE [dbo].[usp_ReOrganise_Rebuild_Indexes]
GO
DROP PROCEDURE [dbo].[usp_Update_Statistics]
GO
DROP PROCEDURE [dbo].[usp_Maintenance_Job_Run_time]
GO
DROP PROCEDURE [dbo].[usp_Send_Weekly_Main_Task_Email]
GO
DROP PROCEDURE [dbo].[usp_Shrink_Database_and_DBFiles]
GO


--Drop SQL agent jobs
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA_WM_DB_Integrity_check.Exec')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA_WM_DB_Integrity_check.Exec' , @delete_unused_schedule=1
Go
--
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA_WM_Shrink_Database.Exec')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA_WM_Shrink_Database.Exec' , @delete_unused_schedule=1
Go
--
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA_WM_RebuildIndexes.Exec')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA_WM_RebuildIndexes.Exec' , @delete_unused_schedule=1
Go
--
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA_WM_ReorganizeIndexes.Exec')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA_WM_ReorganizeIndexes.Exec' , @delete_unused_schedule=1
Go
--
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA_WM_UpdateStatistics.Exec')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA_WM_UpdateStatistics.Exec' , @delete_unused_schedule=1
Go
--
IF EXISTS (SELECT job_id FROM msdb.dbo.sysjobs_view WHERE name = N'DBA_WM_Maintenance_CleanUp.Exec')
EXEC msdb.dbo.sp_delete_job @job_name=N'DBA_WM_Maintenance_CleanUp.Exec' , @delete_unused_schedule=1
Go
--
-----------------------------------------------------------------------