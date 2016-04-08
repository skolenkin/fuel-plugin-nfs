notice('MODULAR: nfs-server.pp')

$nfs_plugin_data = hiera('fuel-plugin-nfs', {})
$nfs_endpoint = $nfs_plugin_data['nfs_endpoint']
$nfs_net_mask = $nfs_plugin_data['nfs_net_mask']

if $::osfamily == 'Debian' {
  $required_pkgs = [ 'rpcbind', 'nfs-kernel-server' ]
  $services_name = 'nfs-kernel-server'

  package { $required_pkgs:
    ensure => present,
  }
  
  file { $nfs_endpoint:
    ensure => 'directory',
    mode   => '0777',
  }
  
  firewall { '150 allow tcp access to nfs service':
    port   => [111, 2049],
    proto  => ['tcp', 'udp'],
    action => accept,
  }

  service { $services_name:
    ensure => running,
    enable => true,
  }

  file { '/etc/exports':
    content => "${nfs_endpoint} ${::network_br_storage}/${nfs_net_mask}(rw,sync,no_subtree_check)",
    notify  => Service[$services_name]
  }
  
}
else {
  fail("Unsuported osfamily ${::osfamily}, currently Debian are the only supported platforms")
}

