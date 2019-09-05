#!/bin/sh

# ----------------------------------------
# Install Istio certs and secrets
# ----------------------------------------

kubectl get secret cacerts -n istio-system >/dev/null 2>&1
if [ $? != 0 ]; then
  echo '[ INFO ] Generate cacerts secret in istio-system namespace'
  kubectl create secret generic -n istio-system cacerts \
    --from-file=certs/ca-cert.pem \
    --from-file=certs/ca-key.pem \
    --from-file=certs/root-cert.pem \
    --from-file=certs/cert-chain.pem
else
  echo '[ INFO ] cacerts secret is present in istio-system namespace'
fi

# Create secret for grafana access
_grafanaUserName=grafana
_grafanaPassword=grafana123
GRAFANA_USERNAME=$(echo -n ${_grafanaUserName} | base64)
GRAFANA_PASSPHRASE=$(echo -n ${_grafanaPassword} | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: grafana
  namespace: istio-system
  labels:
    app: grafana
type: Opaque
data:
  username: $GRAFANA_USERNAME
  passphrase: $GRAFANA_PASSPHRASE
EOF

# Create secret for kiali access
_kialiUserName=kiali
_kialiPassword=kiali123
#export KIALI_USERNAME=`openssl rand -hex 4 | base64`
#export KIALI_PASSPHRASE=`openssl rand -hex 16 | base64`
KIALI_USERNAME=$(echo -n ${_kialiUserName} | base64)
KIALI_PASSPHRASE=$(echo ${_kialiPassword} | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  username: $KIALI_USERNAME
  passphrase: $KIALI_PASSPHRASE
EOF
