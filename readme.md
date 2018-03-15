# glusterfs on k8s

### setup glusterfs

http://docs.gluster.org/en/latest/Quick-Start-Guide/Quickstart/

#### Set up a GlusterFS volume

On both node1 and node2:
`sudo mkdir -p /mnt/data/glusterfs/datasets`

create volume from any single server:
`sudo gluster volume create datasets replica 2 node1:/mnt/data/glusterfs/datasets node2:/mnt/data/glusterfs/datasets`

start gfs volume

`sudo gluster volume start datasets`

Confirm that the volume shows "Started":
`sudo gluster volume info datasets`

 Testing the GlusterFS volume(on node1):
`sudo mount -t glusterfs node1:/datasets /mnt/datasets`


### Creating the Gluster Endpoints and Gluster Service for Persistence

Save the endpoints definition to a file, for example `gluster-endpoints.yaml`.

- The endpoints name. If using a service, then the endpoints name must match the service name.
- An array of IP addresses for each node in the Gluster pool. Currently, host names are not supported.
- The port numbers are ignored, but must be legal port numbers. The value 1 is commonly used.

then create the endpoints object:
`kubectl create -f gluster-endpoints.yaml`

Verify that the endpoints were created:

`kubectl get endpoints`


```
apiVersion: v1
kind: Endpoints
metadata:
  name: glusterfs-cluster
subsets:
- addresses:
  - ip: 192.168.2.177
  ports:
  - port: 1990
    protocol: TCP
- addresses:
  - ip: 192.168.2.46
  ports:
  - port: 1990
    protocol: TCP
```

varify the endpoints:

```
$ kubectl get ep glusterfs-cluster
NAME                ENDPOINTS                              AGE
glusterfs-cluster   192.168.2.177:1990,192.168.2.46:1990   9d
```

Create a server to persist the gluster endpoints.

`kubectl create -f glusterfs_svc.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: glusterfs-cluster
spec:
  ports:
  - port: 1
```

- Endpoints are name-spaced. Each project accessing the Gluster volume needs its own endpoints.
- the endpoints name must match the service name.The port should match the same port used in the endpoints.

Verify that the service was created:
```
$ kubectl get service glusterfs-cluster
NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
glusterfs-cluster   ClusterIP   10.233.24.222   <none>        1990/TCP   15s
```

### Creating the Persistent Volume

create a persistent volume object definition using GlusterFS

`kubectl create -f glusterfs_pv.yaml`

delete:
`kubectl delete -f glusterfs_pv.yaml`

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: gfs-datasets
spec:
  capacity:
    storage: 128Gi
  accessModes:
  - ReadWriteMany
  glusterfs:
    endpoints: glusterfs-cluster
    path: '/gv-test'
    readOnly: false
  persistentVolumeReclaimPolicy: Retain
```

Verify that the persistent volume was created:
```
$ kubectl get pv gfs-datasets
NAME           CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
gfs-datasets   128Gi      RWX            Retain           Available
```

https://kubernetes.io/docs/concepts/storage/persistent-volumes/#access-modes

- ReadWriteOnce – the volume can be mounted as read-write by a single node
- ReadOnlyMany – the volume can be mounted read-only by many nodes
- ReadWriteMany – the volume can be mounted as read-write by many nodes

https://kubernetes.io/docs/concepts/storage/persistent-volumes/#recycle
The `Recycle` reclaim policy is deprecated. Instead, the recommended approach is to use dynamic provisioning.

- The name of the PV, which is referenced in pod definitions or displayed in various oc volume commands.
- The amount of storage allocated to this volume.
- accessModes are used as labels to match a PV and a PVC. They currently do not define any form of access control.
- This defines the volume type being used. In this case, the glusterfs plug-in is defined.
- This references the endpoints named above.
- This is the Gluster volume name, preceded by /.
- The volume reclaim policy Retain indicates that the volume will be preserved after the pods accessing it terminates. For GlusterFS, the accepted values include Retain, and Delete.

### Creating the Persistent Volume Claim

create: `kubectl create -f glusterfs_pvc.yaml`
delete: `kubectl delete -f glusterfs_pvc.yaml`

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: gfs-dataset-claim
spec:
  accessModes:
  - ReadWriteMany
  resources:
     requests:
       storage: 128Gi
```


Verify that the persistent volume was created:
```
$ kubectl get pvc gfs-dataset-claim
NAME                STATUS    VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS   AGE
gfs-dataset-claim   Bound     gfs-datasets   128Gi      RWX                           49s
```


- The claim name is referenced by the pod under its volumes section.
- As mentioned above for PVs, the accessModes do not enforce access rights, but rather act as labels to match a PV to a PVC.
- This claim will look for PVs offering 1Gi or greater capacity.

### test gfs-dataset-claim with a pod

create: `kubectl create -f mxnet-cpu.yaml`
delete: `kubectl delete -f mxnet-cpu.yaml`

Verify that the persistent volume was created:
`kubectl get pod mxnet-cpu`

for more pod infos:
`kubectl describe pod mxnet-cpu`

### backup

sudo gluster volume info
sudo gluster volume state
sudo mount -t glusterfs 192.168.2.177:/gv-test /mnt/dfs

references
----------

https://docs.openshift.org/latest/install_config/storage_examples/gluster_example.html
