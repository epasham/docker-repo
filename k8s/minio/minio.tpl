apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  # This name uniquely identifies the PVC. Will be used in deployment below.
  name: minio-pvc
  namespace: NAMESPACE
  labels:
    app: minio-pvc
spec:
  # Read more about access modes here: https://kubernetes.io/docs/user-guide/persistent-volumes/#access-modes
  accessModes:
    - ReadWriteOnce
  resources:
    # This is the request for storage. Should be available in the cluster.
    requests:
      storage: 1Gi
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: minio-deployment
  namespace: NAMESPACE
spec:
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: minio
    spec:
      volumes:
      - name: storage
        persistentVolumeClaim:
          claimName: minio-pvc
      containers:
      - name: minio
        image: docker.io/minio/minio:latest
        args: 
        - server
        - /storage
        env:
        # Minio access key and secret key
        - name: MINIO_ACCESS_KEY
          valueFrom:
            secretKeyRef:
              name: minio-secret
              key: username
        - name: MINIO_SECRET_KEY
          valueFrom:
            secretKeyRef:
              name: minio-secret
              key: password
        ports:
        - containerPort: 9000
        # Mount the volume into the pod
        volumeMounts:
        - name: storage # must match the volume name, above
          mountPath: "/storage"
---
apiVersion: v1
kind: Service
metadata:
  name: minio-service
  namespace: NAMESPACE
spec:
  type: ClusterIP
  ports:
    - port: 9000
      targetPort: 9000
      protocol: TCP
  selector:
    app: minio    
---

apiVersion: v1
kind: Secret
metadata:
  name: minio-secret
  namespace: NAMESPACE
type: Opaque
data:
  username: base64convertedaccesskey
  password: base64convertedSecretAccesskey
