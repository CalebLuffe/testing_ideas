/*
script lists for all databases the last backup timestamp separatly for all backup types, 
like full, log, differential backups to give a quick overview.

Requires SELECT permissions on system database "msdb".

*/

-- Backup Status
SELECT DB.name AS DatabaseName
      ,MAX(DB.recovery_model_desc) AS RecModel
      ,MAX(BS.backup_start_date) AS LastBackup
      ,MAX(CASE WHEN BS.type = 'D'
                THEN BS.backup_start_date END)
       AS LastFull
      ,SUM(CASE WHEN BS.type = 'D'
                THEN 1 END)
       AS CountFull
      ,MAX(CASE WHEN BS.type = 'L'
                THEN BS.backup_start_date END)
       AS LastLog
      ,SUM(CASE WHEN BS.type = 'L'
                THEN 1 END)
       AS CountLog
      ,MAX(CASE WHEN BS.type = 'I'
                THEN BS.backup_start_date END)
       AS LastDiff
      ,SUM(CASE WHEN BS.type = 'I'
                THEN 1 END)
       AS CountDiff
      ,MAX(CASE WHEN BS.type = 'F'
                THEN BS.backup_start_date END)
       AS LastFile
      ,SUM(CASE WHEN BS.type = 'F'
                THEN 1 END)
       AS CountFile
      ,MAX(CASE WHEN BS.type = 'G'
                THEN BS.backup_start_date END)
       AS LastFileDiff
      ,SUM(CASE WHEN BS.type = 'G'
                THEN 1 END)
       AS CountFileDiff
      ,MAX(CASE WHEN BS.type = 'P'
                THEN BS.backup_start_date END)
       AS LastPart
      ,SUM(CASE WHEN BS.type = 'P'
                THEN 1 END)
       AS CountPart
      ,MAX(CASE WHEN BS.type = 'Q'
                THEN BS.backup_start_date END)
       AS LastPartDiff
      ,SUM(CASE WHEN BS.type = 'Q'
                THEN 1 END)
       AS CountPartDiff
FROM sys.databases AS DB
     LEFT JOIN
     msdb.dbo.backupset AS BS
         ON BS.database_name = DB.name
WHERE ISNULL(BS.is_damaged, 0) = 0 -- exclude damaged backups         
GROUP BY DB.name
ORDER BY DB.name;