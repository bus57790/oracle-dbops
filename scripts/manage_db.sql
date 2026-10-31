-- User & Tablespace Management Sample
CREATE TABLESPACE APP_DATA DATAFILE SIZE 100M AUTOEXTEND ON NEXT 10M MAXSIZE 1G;

CREATE USER app_admin IDENTIFIED BY "SecurePassword123#"
  DEFAULT TABLESPACE APP_DATA
  QUOTA UNLIMITED ON APP_DATA;

GRANT CONNECT, RESOURCE, DBA TO app_admin;

-- Verification query
SELECT username, account_status, default_tablespace FROM dba_users WHERE username = 'APP_ADMIN';
