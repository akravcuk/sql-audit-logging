# How to Control Access to the Database

https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-monitor-mysql

https://learn.microsoft.com/en-us/azure/mysql/flexible-server/tutorial-configure-audit

https://docs.azure.cn/en-us/mysql/flexible-server/concepts-monitor-mysql#track-database-activity-with-audit-logs

1. Set Audit logging 
Settings \ Server parameters
```
audit_log_enabled = true
audit_log_events = CONNECTION, CONNECTION_V2, DCL, DDL, DML_NONSELECT, TABLE_ACCESS
Exclude non-necessary users:

// find them
AzureDiagnostics | where Category contains "MySqlAuditLogs" | summarize count() by user_s 

audit_log_exclude_users

```

2. Enable the audit log
Monitoring \ Diagnostic settings
Logs: audit
Destination details
    Send Logs to Log Analytics Workspace

### Logs storage time retention must be higher then periodic audits
### Logs at the storage account cannot be deleted w/o evidence
    Archive to a storage account

3. Setup storage account
Monitoring \ Diagnostic settings
3.1 Set storage account blob data life-cycle management


4. Enable access with EntraID
Security \ Authentication
    Assign access to: Mysql and Microsoft Entra authentication
    User assigned managed identity: <name of the identity>
    Microsoft Entra administrators: <add security principals here>