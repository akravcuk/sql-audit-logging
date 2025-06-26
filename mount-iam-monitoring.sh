sshfs \
    -o allow_other,default_permissions,umask=000 \
    azureuser@iam-monitoring.westeurope.cloudapp.azure.com:/opt ./x

sshfs \
    -o allow_other,default_permissions,umask=000 \
    azureuser@iam-monitoring.westeurope.cloudapp.azure.com:/media/monitoring/grafana-provisioning ./iam-grafana-provisioning