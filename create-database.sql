--Create DB
IF NOT EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DBA')
BEGIN
    CREATE DATABASE [DBA];
    ALTER DATABASE  [DBA] ADD FILEGROUP [DATA];
    --Need to use dynamic SQL to ensure we put this data file in the right spot dynamically
    DECLARE @sql nvarchar(max);
    SELECT @sql = N'ALTER DATABASE  [DBA] ADD FILE (NAME=''DBA_data'', FILENAME=''' 
                    + LEFT(physical_name,LEN(physical_name)-CHARINDEX('\',REVERSE(physical_name))+1) 
                    + N'DBA_data.ndf' + N''') TO FILEGROUP [DATA];'
    FROM sys.master_files 
    WHERE database_id = db_id('DBA')
    AND file_id = 1;
    EXEC sp_executesql @statement = @sql;
    --And now finish up creating it
    ALTER DATABASE  [DBA] MODIFY FILEGROUP [DATA] DEFAULT;
    ALTER DATABASE  [DBA] SET READ_COMMITTED_SNAPSHOT ON;
    --set sa as owner
    ALTER AUTHORIZATION ON database::DBA TO sa;
    --set to simple recovery on creation
    --if you change this after creation, we won't change it back.
    ALTER DATABASE DBA SET RECOVERY SIMPLE;
END
GO
