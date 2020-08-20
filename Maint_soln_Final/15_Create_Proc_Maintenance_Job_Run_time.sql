--
--Create_Procedure_Maintenance_Job_Run_time
--
Use DBAdmin
GO
IF OBJECT_ID('usp_Maintenance_Job_Run_time','P') IS NOT NULL
    DROP PROC [dbo].[usp_Maintenance_Job_Run_time]
GO

CREATE PROC [dbo].[usp_Maintenance_Job_Run_time]
AS
BEGIN
TRUNCATE TABLE [dbo].[Maintenance_Job_Run_time]


Insert Into [DBAdmin].[dbo].[Maintenance_Job_Run_time]
SELECT @@Servername as ServerName,
    j.name,
    h.run_status,
    durationHHMMSS = STUFF(STUFF(REPLACE(STR(h.run_duration,7,0),
        ' ','0'),4,0,':'),7,0,':'),
    [start_date] = CONVERT(DATETIME, RTRIM(run_date) + ' '
        + STUFF(STUFF(REPLACE(STR(RTRIM(h.run_time),6,0),
        ' ','0'),3,0,':'),6,0,':'))
FROM
    msdb.dbo.sysjobs AS j
INNER JOIN
    (
        SELECT job_id, instance_id = MAX(instance_id)
            FROM msdb.dbo.sysjobhistory
            GROUP BY job_id
    ) AS l
    ON j.job_id = l.job_id
INNER JOIN
    msdb.dbo.sysjobhistory AS h
    ON h.job_id = l.job_id
    AND h.instance_id = l.instance_id
WHERE j.name like '%DBA_WM_%'
ORDER BY
    CONVERT(INT, h.run_duration) DESC,
    [start_date] DESC;
--
select * from [DBAdmin].[dbo].[Maintenance_Job_Run_time]
END
-----------------------------------------------------------------------
-----------------------------------------------------------------------