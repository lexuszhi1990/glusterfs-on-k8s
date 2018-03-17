sudo mkdir -p /mnt/data/glusterfs/models
sudo gluster volume create models replica 2 node1:/mnt/data/glusterfs/models node2:/mnt/data/glusterfs/models
sudo gluster volume start models
sudo gluster volume info models
sudo gluster volume state models
sudo mount -t glusterfs node1:/models /mnt/models

