--Create Tables
:r K:\DBAdmin\01_DB_Components\01_DDLs\01_Create_Log_Directory.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\02_Create_Table_DBCC_History.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\03_Create_Table_Maintenance_Job_Run_time.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\04_Create_Table_DBMail_Send_Param.sql

--Insert Into table
:r K:\DBAdmin\01_DB_Components\03_DMLs\05_INSERT_Into_Table_DBMail_Send_Param.sql

--Create Procedures
:r K:\DBAdmin\01_DB_Components\01_DDLs\11_Create_Proc_usp_CheckDBIntegrity.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\12_Create_Proc_to_usp_Rebuild_ReOrg_Indexes.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\13_Create_Proc_to_usp_ReOrganise_Rebuild_Indexes.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\14_Create_Proc_to_Update_Statistics.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\15_Create_Proc_Maintenance_Job_Run_time.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\16_Create_Proc_Send_Weekly_Main_Task_Email.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\17_Create_Proc_Shrink_Database_and_DBFiles.sql

--Create Maintenance agent jobs
:r K:\DBAdmin\01_DB_Components\01_DDLs\31_Create_DB_Integrity_Check_Maintenance_task.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\32_Create_Shrink_Database_Maintenance_task.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\33_Create_Rebuild_Indexes_Maintenance_task.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\34_Create_Reorganise_Indexes_Maintenance_task.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\35_Create_Update_Statistics_Maintenance_task.sql
:r K:\DBAdmin\01_DB_Components\01_DDLs\36_Create_Maintenance_CleanUp_task.sql


--
--Rollback script
K:\DBAdmin\01_DB_Components\01_DDLs\99_Rollback_script_for_Weekly_Maintainence_soln.sql

