--
--Create_Table_DBMail_Send_Param
--
--https://docs.microsoft.com/en-us/sql/relational-databases/system-stored-procedures/sp-send-dbmail-transact-sql?view=sql-server-ver15
--
USE DBAdmin
Go
Create Table DBMail_Send_Param
(	
	 [SNO] [int] IDENTITY(1,1) NOT NULL
	,[Entry_Description] [varchar](max) NULL
	,[Modified_Date] DateTime NOT NULL					--Default record entry time stamp.
	,[Modified_By] SYSNAME NOT NULL						--Default record entry username.
	,[profile_name] [varchar](500) NULL					--Default to 'IDS_DB_Mail_profile' if not supplied.
    ,[recipients] [varchar](max) NULL
    ,[copy_recipients] [varchar](max) NULL				--Default to 'EDM_Operations@amp.com.au' if not supplied.
    ,[blind_copy_recipients] [varchar](max) NULL
    ,[from_address] [varchar](max) NULL
    ,[reply_to] [varchar](max) NULL				
    ,[subject] [varchar](max) NULL						--If no subject is specified, the default is 'SQL Server Message'.
    ,[body] [varchar](max) NULL							--Default of NULL.
    ,[body_format] [varchar](max) NULL					--Accepts only 'TEXT' or 'HTML'  
    ,[importance] [varchar](max) NULL					--Accepts 'Low','Normal','High'. Defaults to Normal.
    ,[sensitivity] [varchar](max) NULL   				--Accepts 'Normal', 'Personal', 'Private', 'Confidential'. Defaults to Normal.
    ,[file_attachments] [varchar](max) NULL  			--Database Mail limits file attachments increased to 5 MB per file.
    ,[query] [varchar](max) NULL   
    ,[execute_query_database] SYSNAME NULL
    ,[attach_query_result_as_file] BIT NULL 
    ,[query_attachment_filename] [varchar](max) NULL 
    ,[query_result_header] BIT NULL 
    ,[query_result_width] INT NULL  
    ,[query_result_separator] [varchar](1) NULL  		--Defaults to ' ' (space).
    ,[exclude_query_output] BIT NULL 
    ,[append_query_error] BIT NULL 
    ,[query_no_truncate] [varchar](max) NULL 
    ,[query_result_no_padding] BIT NULL  
    ,[mailitem_id] INT NULL
)
ALTER TABLE [dbo].[DBMail_Send_Param] ADD  CONSTRAINT [DF_DBMail_Send_Param_Modified_Date]  DEFAULT (getdate()) FOR [Modified_Date]
GO
ALTER TABLE [dbo].[DBMail_Send_Param] ADD  CONSTRAINT [DF_DBMail_Send_Param_Modified_By]  DEFAULT (coalesce(suser_sname(),'?')) FOR [Modified_By]
GO
--
ALTER TABLE [dbo].[DBMail_Send_Param] ADD  CONSTRAINT [DF_DBMail_Send_Param_profile_name]  DEFAULT ('IDS_DB_Mail_profile') FOR [profile_name]
GO
ALTER TABLE [dbo].[DBMail_Send_Param] ADD  CONSTRAINT [DF_DBMail_Send_Param_copy_recipients]  DEFAULT ('EDM_Operations@amp.com.au') FOR [copy_recipients]
GO
ALTER TABLE [dbo].[DBMail_Send_Param] ADD  CONSTRAINT [DF_DBMail_Send_Param_subject]  DEFAULT ('Query Result') FOR [subject]
GO
ALTER TABLE [dbo].[DBMail_Send_Param] ADD  CONSTRAINT [DF_DBMail_Send_Param_body_format]  DEFAULT ('Text') FOR [body_format]
GO
ALTER TABLE [dbo].[DBMail_Send_Param] ADD  CONSTRAINT [DF_DBMail_Send_Param_sensitivity]  DEFAULT ('Confidential') FOR [sensitivity]
GO
-------------------------------------------------