#!/bin/bash

TOKEN=$(curl -s -H "Metadata: true" \
  "http://169.254.169.254/metadata/identity/oauth2/token?api-version=2021-01-01&resource=https://ossrdbms-aad.database.windows.net" \
  | jq -r .access_token)

echo $TOKEN