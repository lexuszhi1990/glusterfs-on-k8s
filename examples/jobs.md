sudo mkdir -p /mnt/data/glusterfs/jobs
sudo gluster volume create jobs replica 2 node1:/mnt/data/glusterfs/jobs node2:/mnt/data/glusterfs/jobs
sudo gluster volume start jobs
sudo gluster volume info jobs
sudo gluster volume state jobs
sudo mount -t glusterfs node1:/jobs /mnt/jobs

