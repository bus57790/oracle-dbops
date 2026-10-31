-- User & Tablespace Management Sample
CREATE TABLESPACE app_data DATAFILE '/u01/app/oracle/oradata/ORCL/app_data_01.dbf' SIZE 2G
AUTOEXTEND ON NEXT 500M MAXSIZE 10G
EXTENT MANAGEMENT LOCAL AUTOALLOCATE
SEGMENT SPACE MANAGEMENT AUTO;
CREATE USER app_admin IDENTIFIED BY "SecurePassword123#"
  DEFAULT TABLESPACE APP_DATA
  QUOTA UNLIMITED ON APP_DATA;

GRANT CONNECT, RESOURCE, DBA TO app_admin;

-- Verification query
SELECT username, account_status, default_tablespace FROM dba_users WHERE username = 'APP_ADMIN';
