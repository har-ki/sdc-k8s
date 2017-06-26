#!/bin/bash
set -e

USERNAME=$(cat /var/lib/sdc-resources/dpmuser)
PASSWORD=$(cat /var/lib/sdc-resources/dpmpassword)
SDC_ID=$(cat /data/sdc.id)

# login to security app
curl -X POST -d "{\"userName\":\"${USERNAME}\", \"password\": \"${PASSWORD}\"}" ${URL}/security/public-rest/v1/authentication/login --header "Content-Type:application/json" --header "X-Requested-By:SDC" -c /tmp/cookie.txt
# generate auth token from security app
sessionToken=`sed -n '/SS-SSO-LOGIN/p' /tmp/cookie.txt | perl -lane 'print $F[$#F]'`

# Call DPM rest APIs to de-register sdc from DPM
curl -X POST -d "[ \"${SDC_ID}\" ]" ${URL}/security/rest/v1/organization/${ORG}/components/deactivate --header "Content-Type:application/json" --header "X-Requested-By:SDC" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:$sessionToken"
curl -X POST -d "[ \"${SDC_ID}\" ]" ${URL}/security/rest/v1/organization/${ORG}/components/delete --header "Content-Type:application/json" --header "X-Requested-By:SDC" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:$sessionToken"
curl -X DELETE ${URL}/jobrunner/rest/v1/sdc/${SDC_ID} --header "Content-Type:application/json" --header "X-Requested-By:SDC" --header "X-SS-REST-CALL:true" --header "X-SS-User-Auth-Token:$sessionToken"
