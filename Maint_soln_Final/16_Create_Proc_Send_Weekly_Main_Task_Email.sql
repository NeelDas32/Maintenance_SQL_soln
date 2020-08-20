--
--Create_Procedure_Send_Weekly_Main_Task_Email
--
Use DBAdmin
GO
IF OBJECT_ID('usp_Send_Weekly_Main_Task_Email','P') IS NOT NULL
    DROP PROC [dbo].[usp_Send_Weekly_Main_Task_Email]
GO

CREATE PROC [dbo].[usp_Send_Weekly_Main_Task_Email]
AS
BEGIN
DECLARE @Body NVARCHAR(MAX), @Body1 NVARCHAR(MAX), @Body2 NVARCHAR(MAX),
		@TableHead VARCHAR(1000), @TableHead1 VARCHAR(1000), @TableHead2 VARCHAR(1000),
		@Blank varchar(1000),
		@TableTail VARCHAR(1000), @Footer Varchar(1000)
Declare @profile_name varchar(max)			--To pick DBMail param value.
Declare @recipients varchar(max)			--To pick DBMail param value.
Declare @copy_recipients varchar(max)		--To pick DBMail param value.
Declare @subject varchar(max)				--To pick DBMail param value.
Declare @body_format varchar(max)			--To pick DBMail param value.
Declare @filename1 varchar(max)				--To pick DBMail param value.
Declare @SNO int							--Set to pick the DBMail profile parameters from table DBAdmin..DBMail_Send_Param

Set @SNO = 1		--Set to pick the DBMail profile parameters from table DBAdmin..DBMail_Send_Param

SET @TableTail = '</table></body></html>' ;
SET @Footer = '<html>' + '<head>'  + '<H3>' + 'For further details contact EDM_Operations@AMPLife.com.au' + '</H3>' + '</head>';

SET @TableHead = '<html>' + '<head>'  + '<H2>' + 'Execution Report for week ending: ' + CONVERT(VARCHAR(50), GETDATE()-1, 106) + '</H2>' + '</head>'
			+ '<body>' + 'Report generated on : ' + CONVERT(VARCHAR(50), GETDATE(), 100)
			+ '<body>' + '<b>This Report is from ServerName: </b>' 
			

Set @Blank = '<html>' + '<body>' + '<br>' + '</body>' + '<html>'

SET @TableHead1 = '<html><head>' + '<style>'
   + 'td {border: solid black;border-width: 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font: 11px arial} '
      + '</style>' + '</head>' 
	  + '<body>' + 'Jobs execution runtime ' + 
	  + ' <table cellpadding=0 cellspacing=0 border=0>' 
      + '<td bgcolor=#E6E6FA><b>ServerName</b></td>'
	  + '<td bgcolor=#E6E6FA><b>Agent_Job_name</b></td>'
	  + '<td bgcolor=#E6E6FA><b>Run_status</b></td>'
	  + '<td bgcolor=#E6E6FA><b>Duration_in_HHMMSS</b></td>'
	  + '<td bgcolor=#E6E6FA><b>Execution_Time</b></td>';

SET @TableHead2 = '<html><head>' + '<style>'
    + 'td {border: solid black;border-width: 1px;padding-left:5px;padding-right:5px;padding-top:1px;padding-bottom:1px;font: 11px arial} '
    + '</style>' + '</head>' + '<body>' + 'Database Integrity Check Error Report' 
    + ' <table cellpadding=0 cellspacing=0 border=0>' 
    + '<tr> <td bgcolor=#E6E6FA><b>Error</b></td>'
    + '<td bgcolor=#E6E6FA><b>LEVEL</b></td>'
    + '<td bgcolor=#E6E6FA><b>Database_Name</b></td>'
    + '<td bgcolor=#E6E6FA><b>Messagetext</b></td>'
    + '<td bgcolor=#E6E6FA><b>Execution_Time</b></td>'	


SET @Body = ( SELECT Top 1   td = @@servername, ''
                    
		--FROM      [DBAdmin].[dbo].[Maintenance_Job_Run_time]  
           FOR   XML RAW('tr'),
              ELEMENTS
        );

SET @Body1 = ( SELECT    td = ServerName, '',
                     td = Agent_Job_name, '',
                     td = Run_status, '',
                     td = Duration_in_HHMMSS, '',
                     td = Execution_Time,''

			FROM      [DBAdmin].[dbo].[Maintenance_Job_Run_time]  
			ORDER by Execution_Time
         FOR   XML RAW('tr'),
               ELEMENTS
         );

SET @Body2 = ( SELECT    td = Error, '',
                        td = LEVEL, '',
                        td = DB_NAME(dbid), '',
                        td = Messagetext, '',
                        td = TimeStamp,''
                        --td = Delete_Status,'',
						--td = Delete_Execution_Time,'',
						--td = Insert_Status,'',
						--td = Insert_Execution_Time,''

              FROM      [DBAdmin].[dbo].dbcc_history   
              WHERE Error = 8989 and DB_NAME(dbid) IS NOT NULL
            FOR   XML RAW('tr'),
                  ELEMENTS
            );

SELECT  @Body  = @TableHead  + ISNULL(@Body, '')  + @TableTail
SELECT  @Body1 = @TableHead1 + ISNULL(@Body1, '') + @TableTail
SELECT  @Body2 = @TableHead2 + ISNULL(@Body2, '') + @TableTail

--Body of email
SELECT  @Body = @Body + @Blank + @Body1 + @Blank + @Body2 + @Footer


--Pulling the DB_Mail parameters from table
Set @profile_name = (Select profile_name from DBAdmin..DBMail_Send_Param where SNO = @SNO)
Set	@recipients = (Select recipients from DBAdmin..DBMail_Send_Param where SNO = @SNO)
Set	@copy_recipients = (Select copy_recipients from DBAdmin..DBMail_Send_Param where SNO = @SNO)
Set	@subject = (Select subject from DBAdmin..DBMail_Send_Param where SNO = @SNO)
Set	@body_format = (Select body_format from DBAdmin..DBMail_Send_Param where SNO = @SNO)
Set	@filename1 = (Select file_attachments from DBAdmin..DBMail_Send_Param where SNO = @SNO)


--Executing send_dbmail procedure
EXEC msdb..sp_send_dbmail 
  @profile_name = @profile_name,
  @recipients = @recipients,
    @copy_recipients = @copy_recipients,
  @subject = @subject,
  @body=@Body,
  @body_format = @body_format,
  @file_attachments = @filename1;

  END