mkdir -p /mnt/gf_500G/jobs
sudo gluster volume create jobs replica 2 node1:/mnt/gf_500G/jobs node2:/mnt/gf_500G/jobs
sudo gluster volume start jobs
sudo gluster volume info jobs
sudo gluster volume state jobs
sudo mount -t glusterfs node1:/jobs /mnt/gf_mnt/jobs
