mkdir -p /mnt/gf_500G/models
sudo gluster volume create models replica 2 node1:/mnt/gf_500G/models node2:/mnt/gf_500G/models
sudo gluster volume start models
sudo gluster volume info models
sudo gluster volume state models
mkdir -p /mnt/gf_mnt/models && sudo mount -t glusterfs node1:/models /mnt/gf_mnt/models

