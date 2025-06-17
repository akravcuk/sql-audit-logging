# keycloak-spi-azurekeyvault

## Purpose
Provide a way to securely store secrets into an Azure Key Vault of choice, rather than rely on the database.

This will allow easy secret rotation, allow limiting the visibility of these secrets to specific people/applications, and all the other benefits of using a vault.

## Architecture
- Java module plugs in to /providers with dockerfile or with kc.sh build

- When starting, KC is registering this SPI provider "vault-azure-key-vault"

- KC calls the secres with Azure SDK

- Environment variables need to be set like:
```
AZURE_TENANT_ID, AZURE_CLIENT_ID, AZURE_CLIENT_SECRET
```

## Need attention
- Internal SPI API that depends on the particular KC version
- Fork freeze, no official support, no security.md, no updates, no critical fixes
- Azure internal network dependence (zavislost od sieti)

## Mitigation
- Need to be maintained with KC together
- No access to internet from VMs in any case (remove PIP or setup firewall rules on NSG), OWASP application source code scan
- If we can tolerate 
