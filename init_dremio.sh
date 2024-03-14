#!/bin/bash
# Make sure jq is installed before running this script

# Create the first user in dremio and initialize a nessie catalog. This reduces the number of manual steps that need to be performed
set -e

GREEN='\033[0;32m'
RESET='\033[0m' # Reset color to default
NESSIE_CATALOG_NAME="Nessie"

# curl dremio to create the first user with admin privileges
echo "${GREEN}\n\nCreating first user in dremio\n${RESET}"
curl -s 'http://localhost:9053/apiv2/bootstrap/firstuser' -X PUT -H 'Authorization: _dremionull' -H 'Content-Type: application/json' --data-binary '{"userName":"admin","firstName":"Admin","lastName":"Admin","email":"training@example.com","createdAt":1526186430755,"password":"bad4admins"}'
echo "${GREEN}\n\nFirst user in dremio with admin privileges created\n${RESET}"

# curl dremio to get an auth token, parse the JSON object and strip the quotes
AUTHTOKEN=$(curl -s -X POST 'http://localhost:9053/apiv2/login' \
--header 'Content-Type: application/json' \
--data-raw '{"userName": "admin","password": "bad4admins"}' | jq .token | tr -d '"')
echo "${GREEN}\nAUTHTOKEN retrieved\n${RESET}"

echo "${GREEN}\n\nCreating Nessie catalog\n${RESET}"
curl -s 'http://localhost:9053/apiv2/source/'$NESSIE_CATALOG_NAME \
  -X 'PUT' \
  -H 'Authorization: _dremio'$AUTHTOKEN \
  -H 'Content-Type: application/json' \
  --data-raw '{"name":"'$NESSIE_CATALOG_NAME'","config":{"nessieEndpoint":"http://nessie:19120/api/v2","nessieAuthType":"NONE","awsRootPath":"warehouse","credentialType":"ACCESS_KEY","awsAccessKey":"minioadmin","awsAccessSecret":"minioadmin","azureAuthenticationType":"ACCESS_KEY","propertyList":[{"name":"fs.s3a.path.style.access","value":"true"},{"name":"fs.s3a.endpoint","value":"minio:9000"},{"name":"dremio.s3.compat","value":"true"}],"secure":false,"asyncEnabled":true,"isCachingEnabled":true,"maxCacheSpacePct":100},"accelerationRefreshPeriod":3600000,"accelerationGracePeriod":10800000,"type":"NESSIE","accessControlList":{"userControls":[],"roleControls":[]}}' \
  --compressed
echo "${GREEN}\n\nNessie catalog created\n${RESET}"

echo -----------------------------------------------
echo "${GREEN}Dremio first time lab initialization complete${RESET}"
echo -----------------------------------------------
