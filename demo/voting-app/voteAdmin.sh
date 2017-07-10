#!/bin/bash

ok() {
  echo "[OK]"
}

warn() {
  message=$1
  echo ${message}
}

fail() {
  ret=$?
  message=${1-"[Failed (${ret})]"}
  echo ${message}
  exit ${ret}
}

doSleep() {
  length=${1-1}
  echo -n "."
  sleep ${length};
}

requireArgument() {
  test -z ${!1} && fail "Missing Argument '${1}'"
}


createNetwork() {
  network=$1
  requireArgument 'network'
  echo -n "Creating network ${network}... "
  output=$(docker network create -d overlay ${network}) \
    && ok || fail
}

deleteNetwork() {
    network=$1
    requireArgument 'network'
    echo -n "Deleting network ${network}... "
    output=$(docker network rm ${network}) \
        && ok || fail
}

deleteService() {
    service=$1
    requireArgument 'service'
    echo -n "Deleting service ${service}... "
    output=$(docker service rm ${service}) \
        && ok || fail
}

delete() {
    echo "Deleting application..."
    deleteService "vote"
    deleteService "redis"
    deleteService "db"
    deleteService "result"
    deleteService "worker"

    deleteNetwork "vote-net"
    echo "Application deleted"
}

create() {
    version=${1-'latest'}
    echo "Creating application with version ${version}..."
    createNetwork "vote-net"

    echo "Application created"

}

scale() {
  service=$1
  requireArgument 'service'
  read -p "Enter the number of replicas:" replicas
  if [ -z $replicas ]; then
    fail "[Error] Invalid Input"
  fi
  
  if [ $replicas -eq $replicas 2> /dev/null ]; then
    
  echo -n "Scaling service ${service}... "
    output=$(docker service scale ${service}=${replicas}) \
        && ok || fail
  else
    fail "[Error] Invalid Input"
  fi
}





case "${1}" in *)
        function="${1}"
        shift
        ${function} "${@}"
        ;;
esac


