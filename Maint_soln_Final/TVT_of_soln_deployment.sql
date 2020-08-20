Use DBAdmin
Select * from [dbo].[DBCC_History]
GO
Select * from [dbo].[Maintenance_Job_Run_time]
GO
Select * from [dbo].[DBMail_Send_Param]


Use DBAdmin
Select * from sys.objects 
where name in (  'usp_CheckDBIntegrity'
				,'usp_Rebuild_ReOrg_Indexes'
				,'usp_ReOrganise_Rebuild_Indexes'
				,'usp_Update_Statistics'
				,'usp_Maintenance_Job_Run_time'
				,'usp_Send_Weekly_Main_Task_Email'
				,'usp_Shrink_Database_and_DBFiles'		
				)
GO

select @@SERVERNAME as ServerName,enabled,start_step_id,SUSER_NAME(owner_sid) as Job_Owner,date_created,date_modified 
from msdb..sysjobs 
where name like 'DBA_WM%'