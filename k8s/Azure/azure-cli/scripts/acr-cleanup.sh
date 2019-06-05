#!/bin/bash
# usavge ./acr-cleanup.sh acr1 acr2


if [[ $# -lt 1 ]]; then
 echo "[ ERROR ] You need to pass Azure registry server name(s) as input."
 exit 1
fi

# Number of newest images in repository that will not be deleted
COUNT=5

for ACR in $*; do
  REPOSITORIES=$(az acr repository list -n $ACR -otsv)
  for REPO in $REPOSITORIES; do
    OLD_IMAGES=$(az acr repository show-manifests --name $ACR --repository $REPO --orderby time_asc -o tsv | head -n -$COUNT)
    for OLD_IMAGE in $OLD_IMAGES; do
       az acr repository delete --name $ACR --image $REPO@$OLD_IMAGE --yes
    done
  done
done
