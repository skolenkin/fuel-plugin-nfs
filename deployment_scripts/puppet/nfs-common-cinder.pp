notice('MODULAR: nfs-common-cinder.pp')

$nodes = hiera('nodes', {})
$nfs_plugin_data = hiera('fuel-plugin-nfs', {})
$cinder_nfs_share = '/etc/cinder/nfs_shares.txt'

# set path to folder where nfs will be mouned on cinder server
$nfs_mount_point = $nfs_plugin_data['nfs_mount_point']

# set path to nfs folder on nfs server
$nfs_endpoint = $nfs_plugin_data['nfs_endpoint']

# set nfs mount options
$nfs_mount_options = $nfs_plugin_data['nfs_mount_options']

# set flag sparsed_volumes or not
$nfs_sparsed_volumes = $nfs_plugin_data['nfs_sparsed_volumes']

# get storage IP of NFS Servers, mount storaget on Compute node
define nfs_server_ip {
  if $name['role'] == 'nfs-server' {
    file_line { "nfs_line${name['uid']}":
      line => "${name['storage_address']}:${nfs_endpoint}",
      path => $cinder_nfs_share,
    }
  }
}

if $::osfamily == 'Debian' {
  $required_pkgs = [ 'cinder-volume' ]
  $service_name = 'cinder-volume'

  package { $required_pkgs:
    ensure => present,
  }

  service { $service_name:
    ensure => running,
  }

  file { $cinder_nfs_share:
    ensure => present,
    owner  => 'cinder',
    group  => 'cinder',
    notify => Service[$service_name]
  }

  file { $nfs_mount_point:
    ensure => 'directory',
    mode   => '0755',
    owner  => 'cinder',
    group  => 'cinder',
  }

  # cinder config changes here 
  # puppetlab openstack/cinder module installation required
  cinder_config {
    'DEFAULT/volume_driver' :
      value => 'cinder.volume.drivers.nfs.NfsDriver';
    'DEFAULT/nfs_shares_config' :
      value => $cinder_nfs_share;
    'DEFAULT/nfs_sparsed_volumes' :
      value => 'True';
    'DEFAULT/nfs_oversub_ratio' :
      value => '1.0';
    'DEFAULT/nfs_used_ratio' :
      value => '0.95';
    'DEFAULT/nfs_mount_attempts' :
      value => '3';
    'DEFAULT/nfs_mount_point_base' :
      value => $nfs_mount_point;
    'DEFAULT/nfs_mount_options' :
      value => '';
  }
  
  nfs_server_ip { $nodes: }

}
else {
  fail("Unsuported osfamily ${::osfamily}, currently Debian are the only supported platforms")
}
