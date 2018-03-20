mkdir -p /mnt/gf_500G/datasets
sudo gluster volume create datasets replica 2 node1:/mnt/gf_500G/datasets node2:/mnt/gf_500G/datasets
sudo gluster volume start datasets
sudo gluster volume info datasets
sudo gluster volume state datasets
sudo mount -t glusterfs node1:/datasets /mnt/gf_mnt/datasets

