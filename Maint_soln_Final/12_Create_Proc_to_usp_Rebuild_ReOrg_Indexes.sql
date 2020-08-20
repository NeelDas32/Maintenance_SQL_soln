--
--Create_Proc_to_Rebuild_ReOrg_Indexes
--Only REBUILD indexes more than 40% fragmentation
--
--
Use DBAdmin
GO
IF OBJECT_ID('usp_Rebuild_ReOrg_Indexes','P') IS NOT NULL
    DROP PROC usp_Rebuild_ReOrg_Indexes
GO

Create PROCEDURE [usp_Rebuild_ReOrg_Indexes] 
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
		--exec sp_executesql @sql
		Print @sql
		
		DROP Table IF EXISTS #FragmentedIndexes
		CREATE TABLE #FragmentedIndexes
		(
		DatabaseName SYSNAME
		, SchemaName SYSNAME
		, TableName SYSNAME
		, IndexName SYSNAME
		, Row_Count INT
		, [Fragmentation%] FLOAT
		)
		
		--Exec('Use '+ @database_name + ';')
		Select @sql1 =	'INSERT INTO #FragmentedIndexes
		SELECT
		DB_NAME(DB_ID()) AS DatabaseName
		, ss.name AS SchemaName
		, OBJECT_NAME (s.object_id) AS TableName
		, i.name AS IndexName
		, s.record_count as Row_Count
		, s.avg_fragmentation_in_percent AS [Fragmentation%]
		FROM sys.dm_db_index_physical_stats(db_id(),NULL, NULL, NULL, ''SAMPLED'') s
		INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id]
		AND s.index_id = i.index_id
		INNER JOIN sys.objects o ON s.object_id = o.object_id
		INNER JOIN sys.schemas ss ON ss.[schema_id] = o.[schema_id]
		WHERE s.database_id = DB_ID()
		AND i.index_id != 0
		AND s.record_count > 10000
		AND o.is_ms_shipped = 0'
		select @sql1 = @sql + @sql1
		exec sp_executesql @sql1
		--print @sql1
		--Select * from #FragmentedIndexes  order by [Fragmentation%] desc

		DECLARE @RebuildIndexesSQL NVARCHAR(MAX)
		SET @RebuildIndexesSQL = ''
		SELECT
		@RebuildIndexesSQL = @RebuildIndexesSQL +
		CASE
		WHEN [Fragmentation%] > 40
		THEN CHAR(10) + 'ALTER INDEX ' + QUOTENAME(IndexName) + ' ON '
			+ QUOTENAME(SchemaName) + '.'
			+ QUOTENAME(TableName) + ' REBUILD;'
		WHEN [Fragmentation%] > 10
			THEN CHAR(10) + 'ALTER INDEX ' + QUOTENAME(IndexName) + ' ON '
			+ QUOTENAME(SchemaName) + '.'
			+ QUOTENAME(TableName) + ' REORGANIZE;'
		END
		FROM #FragmentedIndexes
		WHERE [Fragmentation%] > 40			--Change this for Reorganize
		DECLARE @StartOffset INT
		DECLARE @Length INT
		SET @StartOffset = 0
		SET @Length = 4000
		WHILE (@StartOffset < LEN(@RebuildIndexesSQL))
		BEGIN
		PRINT SUBSTRING(@RebuildIndexesSQL, @StartOffset, @Length)
		SET @StartOffset = @StartOffset + @Length
		END
		PRINT SUBSTRING(@RebuildIndexesSQL, @StartOffset, @Length)

		select @RebuildIndexesSQL = @sql + @RebuildIndexesSQL
		Print @RebuildIndexesSQL
		EXECUTE sp_executesql @RebuildIndexesSQL

		Select * from #FragmentedIndexes  WHERE [Fragmentation%] > 40 order by [Fragmentation%] desc		--Change this for Reorganize
		
				
 FETCH next FROM database_cursor INTO @database_name
   END

   CLOSE database_cursor
   DEALLOCATE database_cursor


END 
-------------------------------------------------------------------------