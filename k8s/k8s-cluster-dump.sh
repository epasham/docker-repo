#!/bin/bash

mkdir ./cluster-dump

kubectl get --export -o=json ns | \
jq '.items[] |
    select(.metadata.name!="kube-system") |
    select(.metadata.name!="default") |
    del(.status,
        .metadata.uid,
        .metadata.selfLink,
        .metadata.resourceVersion,
        .metadata.creationTimestamp,
        .metadata.generation
    )' > ./cluster-dump/ns.json

for ns in $(jq -r '.metadata.name' < ./cluster-dump/ns.json);do
    echo "Namespace: $ns"
    kubectl --namespace="${ns}" get --export -o=json svc,deployment,configmap,horizontalpodautoscaler,job,limitrange,resourcequota,secrets,ds | \
    jq '.items[] |
        select(.type!="kubernetes.io/service-account-token") |
        del(
            .spec.clusterIP,
            .metadata.uid,
            .metadata.selfLink,
            .metadata.resourceVersion,
            .metadata.creationTimestamp,
            .metadata.generation,
            .status,
            .spec.template.spec.securityContext,
            .spec.template.spec.dnsPolicy,
            .spec.template.spec.terminationGracePeriodSeconds,
            .spec.template.spec.restartPolicy
        )' >> "./cluster-dump/cluster-dump.json"
done
