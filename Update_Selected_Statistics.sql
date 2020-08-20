-- Update out-dated statistics

-- Uses index and statistic update timestamps to select
-- probable out-dated statistics and update them.

-- In common a DBA schedules a maintenance plan to update all statistics within
-- a database. Also it's possible to execute the system stored procedure sp_updatestats.
-- Both could cause full table scans on all table and therefore a may high IO workload.
--
-- This Transact-SQL statement estimate by index and statistic update timestamps the
-- probable out-dated statistics and update them with resample option.

-- Requires at least db_owner view permissions.
-- Works with Microsoft SQL Server 2005 and higher versions.

SET NOCOUNT ON;
DECLARE @minDateDiff int, @sql nvarchar(1000), @schema nvarchar(130), @table nvarchar(130), @stat nvarchar(130), @lastupd datetime;

-- Min difference between statistics and index(es) update timestamp
-- in days.
SET @minDateDiff = 7;

DECLARE StatsCursor CURSOR LOCAL FOR
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
    WHERE OBJ.type IN ('U', 'V')    -- only user tables and views
          AND DATEDIFF(d, ISNULL(STATS_DATE(STA.object_id, STA.stats_id), {d N'1900-01-01'})
                        , IUS.LastUpdate) > @minDateDiff
    ORDER BY STATS_DATE(STA.object_id, stats_id) ASC;

-- Open the cursor
OPEN StatsCursor;

FETCH NEXT FROM StatsCursor
    INTO @schema, @table, @stat, @lastupd
WHILE @@FETCH_STATUS = 0
BEGIN
    -- Infoprint.
    PRINT @schema + N'.' + @table + CHAR(9) + @stat + CHAR(9) + '-> ' + CONVERT(nvarchar(20), ISNULL(@lastupd, ''), 120);

    SET @sql = N'UPDATE STATISTICS '
               + QUOTENAME(@schema) + N'.' + QUOTENAME(@table) + N' '
               + QUOTENAME(@stat) + N' '
               + 'WITH RESAMPLE;';  -- Or WITH FULLSCAN

    EXEC sp_executesql @sql;

    FETCH NEXT FROM StatsCursor
        INTO @schema, @table, @stat, @lastupd;
END;

CLOSE StatsCursor;
DEALLOCATE StatsCursor;