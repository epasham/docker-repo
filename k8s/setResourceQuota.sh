#!/bin/bash
# ####################################################################################
# Program: Define Resource Quota
# Developer: ekambaram pasham
# Email: ekambaram_pasham@infosys.com
# Date: 20-08-2019
# ####################################################################################
# Change Log: 'Revision 1.0  20-08-2019 overview is included'
# Change Log: 
# ####################################################################################

usage() { 
  echo "Usage: $0 <namespace>"
  exit 1
}


if [ "$#" -ne 1 ]; then
  echo "[ ERROR ] Invalid number of arguments"
  usage
else
  NAMESPACE=$1
fi


  cat <<EOF
********************************************** INFO ***************************************
When several users or teams share a cluster with a fixed number of nodes, there is a 
concern that one team could use more than its fair share of resources. Resource Quota 
is used to limit resource usage per namespace so team can get fair share of the resouorces.
********************************************** INFO ***************************************
EOF
echo ""

unset mnMemory
unset mxMemory
unset mnCpu
unset mxCpu
unset mxStorage


# Define memory request
while [[ -z "$mnMemory" ]] ; do
  read -p "[ Namespace: ${NAMESPACE} ] Enter min Memory to be allocated (Ex.2048Mi): " mnMemory && echo ""
done

# Define memory limit
while [[ -z "$mxMemory" ]] ; do
  read -p "[ Namespace: ${NAMESPACE} ] Enter max Memory to be allocated (Ex.4096Mi): " mxMemory && echo ""
done


# Define cpu request
while [[ -z "$mnCpu" ]] ; do
  read -p "[ Namespace: ${NAMESPACE} ] Enter min cpu to be allocated (Ex.800m): " mnCpu && echo ""
done

# Define cpu limit
while [[ -z "$mxCpu" ]] ; do
  read -p "[ Namespace: ${NAMESPACE} ] Enter max cpu to be allocated (Ex.2500m): " mxCpu && echo ""
done


# Define Storage limit
while [[ -z "$mxStorage" ]] ; do
  read -p "[ Namespace: ${NAMESPACE} ] Enter Storage to be allocated (Ex.100Gi): " mxStorage && echo ""
done

echo
echo "You have entered below inputs"
echo "============================="
echo "Namespace: $NAMESPACE"
echo "minimun Memory to be allocated: $mnMemory"
echo "maximum Memory to be allocated: $mxMemory"
echo "minimun CPU to be allocated: $mnCpu"
echo "maximum CPU to be allocated: $mxCpu"
echo "Storage to be allocated: $mxStorage"
echo ""

fileName=resourceQuota_${NAMESPACE}.yaml
echo "[ INFO ] Generate Resource Quota YAML"
read -p "Continue (y/n)? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo
else
    echo "[ ERROR ] Script is interrupted"
    exit -1
fi

cat << EOF > $fileName
apiVersion: v1
kind: ResourceQuota
metadata:
  name: compute-quota
  namespace: ${NAMESPACE}
spec:
  hard:
    requests.cpu: ${mnCpu}
    requests.memory: ${mnMemory}
    limits.cpu: ${mxCpu}
    limits.memory: ${mxMemory}
    requests.storage: ${mxStorage}
EOF

echo "[ INFO ] Display Resource Quota YAML"
cat $fileName

echo "[ INFO ] $0 Script is complete"
