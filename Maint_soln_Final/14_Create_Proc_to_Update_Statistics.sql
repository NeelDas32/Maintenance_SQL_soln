--
--Create_Proc_to_Update_Statistics
--Statistics which is older than 07 days
--
--
Use DBAdmin
GO
IF OBJECT_ID('usp_Update_Statistics','P') IS NOT NULL
    DROP PROC usp_Update_Statistics
GO

Create PROCEDURE [usp_Update_Statistics] 
AS
Begin		



Declare @database_name SYSNAME = NULL
DECLARE database_cursor CURSOR FOR
   SELECT name 
   FROM sys.databases db
   WHERE name NOT IN ('master','model','msdb','tempdb','SSISDB','ReportServer','ReportServerTempDB') 
   AND db.state_desc = 'ONLINE'
   AND source_database_id IS NULL -- REAL DBS ONLY (Not Snapshots)
   AND is_read_only = 0

   OPEN database_cursor
   FETCH next FROM database_cursor INTO @database_name
   WHILE @@FETCH_STATUS=0
   BEGIN
     
		declare @sql nvarchar(max), @sql1 nvarchar(max)
		select @sql = 'use '
		select @sql = @sql + @database_name + ' '
		exec sp_executesql @sql
		Print @sql
				
		
		SET NOCOUNT ON;
		DECLARE @minDateDiff int, @schema nvarchar(130), @table nvarchar(130), @stat nvarchar(130), @lastupd datetime;
		
		-- Min difference between statistics and index(es) update timestamp
		-- in days.
		SET @minDateDiff = 7;
		
		DROP Table IF EXISTS #StatsCheckTable
		CREATE TABLE #StatsCheckTable
	(	SchemaName	SYSNAME, ObjectName varchar(200),	StatName varchar(200),	StatUpdateStamp datetime )

		Select @sql1 = 'Insert Into #StatsCheckTable
		SELECT SCH.name AS SchemaName
				,OBJ.name AS ObjectName
				,STA.name AS StatName
				,STATS_DATE(STA.object_id, STA.stats_id) AS StatUpdateStamp
			FROM sys.stats AS STA
				INNER JOIN sys.objects AS OBJ
					ON STA.object_id = OBJ.object_id
				INNER JOIN sys.schemas AS SCH
					ON OBJ.schema_id = SCH.schema_id
				LEFT JOIN
				(SELECT IUS.object_id
						,MIN(ISNULL(IUS.last_user_update, IUS.last_system_update)) AS LastUpdate
				FROM sys.dm_db_index_usage_stats AS IUS
				WHERE database_id = DB_ID()
						AND NOT ISNULL(IUS.last_user_update, IUS.last_system_update) IS NULL
				GROUP BY IUS.object_id
				) AS IUS
					ON IUS.object_id = STA.object_id
			WHERE OBJ.type IN (''U'', ''V'')    -- only user tables and views
				AND DATEDIFF(d, ISNULL(STATS_DATE(STA.object_id, STA.stats_id), {d N''1900-01-01''})
								, IUS.LastUpdate) > 7
			ORDER BY STATS_DATE(STA.object_id, stats_id) ASC;'
	select @sql1 = @sql + ' ' + @sql1
	--Print @sql1
		exec sp_executesql @sql1
		Select * from #StatsCheckTable
		DECLARE StatsCursor CURSOR LOCAL FOR
			Select * from #StatsCheckTable
		
		-- Open the cursor
		OPEN StatsCursor;
		
		FETCH NEXT FROM StatsCursor	INTO @schema, @table, @stat, @lastupd
		WHILE @@FETCH_STATUS = 0
		BEGIN
			-- Infoprint.
			--EXEC sp_executesql @sql
			--PRINT @schema + N'.' + @table + CHAR(9) + @stat + CHAR(9) + '-> ' + CONVERT(nvarchar(20), ISNULL(@lastupd, ''), 120);
		
			SET @sql1 = N'UPDATE STATISTICS '
					+ QUOTENAME(@schema) + N'.' + QUOTENAME(@table) + N' '
					+ QUOTENAME(@stat) + N' '
					+ 'WITH RESAMPLE;';  -- Or WITH FULLSCAN
		
			
			select @sql1 = @sql + @sql1
			Print @sql1
			EXEC sp_executesql @sql1;
		
			FETCH NEXT FROM StatsCursor
				INTO @schema, @table, @stat, @lastupd;
		END;
		
		CLOSE StatsCursor;
		DEALLOCATE StatsCursor;
						
 FETCH next FROM database_cursor INTO @database_name
   END

   CLOSE database_cursor
   DEALLOCATE database_cursor


END 
-------------------------------------------------------------------------