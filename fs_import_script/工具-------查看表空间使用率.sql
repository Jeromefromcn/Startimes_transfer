select *
  from (SELECT a.tablespace_name tableSpaceName,
               NVL(a.BYTES / 1024 / 1024,0) totalSize,
               NVL(b.largest / 1024 / 1024,0) freeSize,
               NVL((a.BYTES - b.BYTES) / 1024 / 1024,0) usedSize,
               round(NVL((a.BYTES - b.BYTES) / a.BYTES * 100, 0), 2) usedPercent
          from (SELECT tablespace_name, sum(BYTES) bytes
                  FROM dba_data_files
                 GROUP BY tablespace_name) a,
               (SELECT tablespace_name, sum(BYTES) bytes, max(BYTES) largest
                  FROM dba_free_space
                 GROUP BY tablespace_name) b
         WHERE a.tablespace_name = b.tablespace_name
         ORDER BY a.tablespace_name)
