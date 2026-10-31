-- Create Tablespace with absolute path
CREATE TABLESPACE APP_DATA DATAFILE '/u01/app/oracle/oradata/ORCL/app_data01.dbf' SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE 1G;

-- Create User pointing to the tablespace
CREATE USER app_admin IDENTIFIED BY "SecurePassword123#"
  DEFAULT TABLESPACE APP_DATA
  QUOTA UNLIMITED ON APP_DATA;

-- Grant Permissions
GRANT CONNECT, RESOURCE, DBA TO app_admin;

-- Verification query
SELECT username, account_status, default_tablespace 
FROM dba_users 
WHERE username = 'APP_ADMIN';
