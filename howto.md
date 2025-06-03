# Steps to configure audit logs for Azure Database for MySQL Flexible Server

1. Deploy Log Analytics workspace

2. Deploy storage account if audit requires
2.1 Security + Networking 
2.2 Configure firewall rules for the storage account
2.2.1 Exceptions: Allow Azure services on the trusted services list to access this storage account.

3. Diagnostic settings
3.1 Enable audit logs into defined Log Analytics workspace
3.2 Set retention period for audit logs in Log Analytics workspace for the specific Table
3.3 Cnfigure alert rules for critical events in Log Analytics workspace

4. Database server parameters
4.1 audit_log_enabled : ON
4.2 audit_log_events: [CONNECTION, CONNECTION_V2, DCL, DDL, DML_NONSELECT, TABLE_ACCESS]
4.3 audit_log_include_users: must be empty
4.4 audit_log_exclude_users: azure_superuser


# Security Baseline
https://learn.microsoft.com/en-us/security/benchmark/azure/baselines/azure-database-for-mysql-flexible-server-security-baseline?wt.mc_id=knowledgesearch_inproduct_copilot-in-azure#lt-4-enable-logging-for-security-investigation


# Technical References
https://learn.microsoft.com/en-us/azure/mysql/flexible-server/tutorial-configure-audit#set-up-diagnostics
https://learn.microsoft.com/en-us/azure/mysql/flexible-server/concepts-monitor-mysql
