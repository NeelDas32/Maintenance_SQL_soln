--
--Create_Table_Maintenance_Job_Run_time
--
Use DBAdmin
GO
IF OBJECT_ID('Maintenance_Job_Run_time','U') IS NOT NULL
    DROP Table Maintenance_Job_Run_time
GO
CREATE TABLE [DBAdmin].[dbo].[Maintenance_Job_Run_time]
(	ServerName varchar(100),
	Agent_Job_name varchar(500),
	Run_status int,
	Duration_in_HHMMSS varchar(50),
	Execution_Time datetime			
	)
-------------------------------------------------