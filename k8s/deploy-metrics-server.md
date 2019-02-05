Follow the below steps
------------------------
Check k8s version    
# kubectl version --short    
Client Version: v1.11.3      
Server Version: v1.11.3    

# Check metrics server is running
kubectl top po    
Error from server (NotFound): the server could not find the requested resource (get services http:heapster:)

# git clone https://github.com/kubernetes-incubator/metrics-server.git
# cd metrics-server/deploy

You should see below directories  
drwxr-xr-x 2 root root 4096 Feb  5 12:37 1.7    
drwxr-xr-x 2 root root 4096 Feb  5 12:37 1.8+    
drwxr-xr-x 2 root root 4096 Feb  5 12:37 docker    

# create metric-server for k8s version 1.8 and above
# cd 1.8+
# vi metrics-server-deployment.yaml  
include the command and parameters as shown below  
      containers:  
      - name: metrics-server  
        image: k8s.gcr.io/metrics-server-amd64:v0.3.1  
        imagePullPolicy: Always  
        command:  
        - /metrics-server  
        - --metric-resolution=30s  
        - --kubelet-insecure-tls  
        - --kubelet-preferred-address-types=InternalIP  
        volumeMounts:  
        - name: tmp-dir  
          mountPath: /tmp  
# cd ..
# kubectl apply -f 1.8+
clusterrole.rbac.authorization.k8s.io/system:aggregated-metrics-reader created
clusterrolebinding.rbac.authorization.k8s.io/metrics-server:system:auth-delegator created
rolebinding.rbac.authorization.k8s.io/metrics-server-auth-reader created
apiservice.apiregistration.k8s.io/v1beta1.metrics.k8s.io created
serviceaccount/metrics-server created
deployment.extensions/metrics-server created
service/metrics-server created
clusterrole.rbac.authorization.k8s.io/system:metrics-server created
clusterrolebinding.rbac.authorization.k8s.io/system:metrics-server created

# Verify that metrics server is deployed and is running
# kubectl get po -n kube-system |grep metrics
metrics-server-85cc795fbf-vhs7n   1/1       Running   0          6m

# Check that metrics are being displayed  
# kubectl top po -n kube-system
NAME                              CPU(cores)   MEMORY(bytes)    
coredns-78fcdf6894-7zx4v          4m           10Mi    
coredns-78fcdf6894-fnk5g          7m           9Mi    
etcd-master                       79m          72Mi    
kube-apiserver-master             110m         410Mi    
kube-controller-manager-master    53m          61Mi    
kube-proxy-wld29                  4m           16Mi    
kube-proxy-xzsc5                  2m           17Mi    
kube-scheduler-master             17m          15Mi    
metrics-server-7dfcc96bd9-tvx4g   1m           13Mi    
weave-net-4vgtj                   1m           53Mi    
weave-net-ll5tw                   1m           53Mi    
