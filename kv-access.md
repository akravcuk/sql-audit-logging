# Keyvault access

1. Set "Purge protection to 14 days"
	Settings \ Properties:
    Enable purge protection (enforce a mandatory retention period for deleted vaults and vault objects)
2. Private endpoint
3. RBAC: `Example`

|Service principal|Keys|Secrets|Certificates|
|-|-|-|-|
|IAM-admins|x|r|x|
|T2R-admins|x|r|r|

4. Diagnostics \ Audit logs

5. Set a KQL alert or just this rule for weekly reports
```kusto
AzureDiagnostics
| where Category == "AuditEvent"
| where OperationName == "SecretDelete"
```

5.a Optionally: extended audit 
```kusto
AzureDiagnostics
| where Category == "AuditEvent"
// | where OperationName == "SecretDelete"
| where ResultType == "Success"
| project TimeGenerated, Resource, OperationName, ResultType, ResultDescription, ResultSignature, identity_claim_unique_name_s
```




