--
--INSERT_into_Table_DBMail_Send_Param
--
--
USE DBAdmin
Go
Insert Into DBMail_Send_Param
(	
	 [Entry_Description] 
	,[recipients] 
	,[subject] 
	,[body_format] 
	,[file_attachments] 	
)
Values 
(		
		'DB Weekly Maintenance Jobs Email',	
		'Cameron.Dunn@amplife.com.au; Chinh.Nguyen@amplife.com.au; George.Mikhiel@amplife.com.au; Indraneel.Das@amplife.com.au; Nimesh.Shah@amplife.com.au; Rajesh.Prabhu@amplife.com.au',
		'Execution Report from DB Weekly Maintenance Jobs',
		'HTML',	
		'D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\DB_Intergrity_Check.txt;D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\Database_Shrink.txt;D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\Rebuild_indexes.txt;D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\ReOrganise_Indexes.txt;D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\Update_statistics.txt;D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log\Maintenance_CleanUp.txt'
)
-------------------------------------------------