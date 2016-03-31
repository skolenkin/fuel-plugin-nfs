NFS Server Plugin for Cinder
============

NFS plugin is a Cinder extension (configuring cinder volume service to use NFS storage).

Compatible versions:
- Mirantis Fuel 7.0

Abilities:
- Setup NFS Server Service on separate bare metal
- NFS as unified storage backend for Openstack Cinder.

Building the plugin:
- git clone https://github.com/skolenkin/fuel-plugin-nfs.git
- fpb --build ./fuel-plugin-nfs
- fuel plugins --install fuel-plugin-cinder-nfs-1.0-0.0.0-1.noarch.rpm


TO DO:
- create param.pp for centralized global parameters storage

