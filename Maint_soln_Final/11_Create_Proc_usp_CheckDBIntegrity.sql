--
--Create Proc to execute DBCC CHECKDB for all databases.
--
Use DBAdmin
GO
IF OBJECT_ID('usp_CheckDBIntegrity','P') IS NOT NULL
    DROP PROC usp_CheckDBIntegrity
GO

CREATE PROC [dbo].[usp_CheckDBIntegrity]
@database_name SYSNAME=NULL
AS
IF @database_name IS NULL -- Run against all databases
BEGIN
   DECLARE database_cursor CURSOR FOR
   SELECT name 
   FROM sys.databases db
   WHERE name NOT IN ('master','model','msdb','tempdb') 
   AND db.state_desc = 'ONLINE'
   AND source_database_id IS NULL -- REAL DBS ONLY (Not Snapshots)
   AND is_read_only = 0

   OPEN database_cursor
   FETCH next FROM database_cursor INTO @database_name
   WHILE @@FETCH_STATUS=0
   BEGIN

      INSERT INTO DBCC_History ([Error], [Level], [State], MessageText, RepairLevel, [Status], 
      [DbId], DbFragId, ObjectId, IndexId, PartitionId, AllocUnitId, RidDbId, RidPruId, [File], Page, Slot, 
      RefDbId, RefPruId, RefFile, RefPage, RefSlot,Allocation)
      EXEC ('dbcc checkdb(''' + @database_name + ''') with tableresults')

      FETCH next FROM database_cursor INTO @database_name
   END

   CLOSE database_cursor
   DEALLOCATE database_cursor
END 

ELSE -- run against a specified database (ie: usp_CheckDBIntegrity 'DB Name Here'

   INSERT INTO DBCC_History ([Error], [Level], [State], MessageText, RepairLevel, [Status], 
   [DbId], DbFragId, ObjectId, IndexId, PartitionId, AllocUnitId, RidDbId, RidPruId, [File], Page, Slot, 
   RefDbId, RefPruId, RefFile, RefPage, RefSlot,Allocation)
   EXEC ('dbcc checkdb(''' + @database_name + ''') with tableresults')
GO 
--
-----------------------------------------------------------------------
-----------------------------------------------------------------------