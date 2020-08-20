--
--Create_Log_Directory
--
USE Master;
GO
SET NOCOUNT ON

-- 1 - Variable declaration
DECLARE @DataPath nvarchar(500)
DECLARE @DirTree TABLE (subdirectory nvarchar(255), depth INT)

-- 2 - Initialize variables
SET @DataPath = 'D:\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Log'					-- Enter data file folder path

-- 3 - @DataPath values
INSERT INTO @DirTree(subdirectory, depth)
EXEC master.sys.xp_dirtree @DataPath
select @DataPath
-- 4 - Create the @DataPath directory
IF NOT EXISTS (SELECT 1 FROM @DirTree )
EXEC master.dbo.xp_create_subdir @DataPath
--
-----------------------------------------------