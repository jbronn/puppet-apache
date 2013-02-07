class apache::redhat::default_modules {
  # Initialize the available and enabled modules on RedHat.
  apache::mod {
    ['actions', 'alias', 'asis', 'auth_basic', 'auth_digest', 'authn_alias',
     'authn_anon', 'authn_dbd', 'authn_dbm', 'authn_default', 'authn_file',
     'authnz_ldap', 'authz_dbm', 'authz_default', 'authz_groupfile', 'authz_host',
     'authz_owner', 'authz_user', 'autoindex', 'cache', 'cern_meta', 'cgi', 'cgid',
     'dav', 'dav_fs', 'dbd', 'deflate', 'dir', 'disk_cache', 'dumpio', 'env',
     'expires', 'ext_filter', 'filter', 'headers', 'ident', 'include', 'info',
     'ldap', 'log_config', 'log_forensic', 'logio', 'mime', 'mime_magic',
     'negotiation', 'pfoxy_ajp', 'proxy', 'proxy_balancer', 'proxy_connect',
     'proxy_ftp', 'proxy_http', 'rewrite', 'setenvif', 'speling', 'status',
     'substitute', 'suexec', 'unique_id', 'userdir', 'usertrack', 'version',
     'vhost_alias']:
  }

  # Don't use `ssl.conf` provided by yum.
  file { "${apache::params::config_dir}/ssl.conf":
    ensure => absent,
  }
  apache::mod { 'ssl':
    source => "puppet:///modules/apache/redhat/ssl.conf",
  }
}

class apache::redhat::config {
  include apache::params
  include apache::service
  include apache::redhat::default_modules

  File {
    owner => 'root',
    group => 'root',
    mode  => '0644',
  }

  file { 'apache-config':
    ensure  => file,
    path    => $apache::params::config,
    content => template('apache/redhat/httpd.conf.erb'),
    require => Class['apache::config'],
    notify  => Service['apache'],
  }

  file { "${apache::params::server_root}/conf/ports.conf":
    ensure  => file,
    source  => "puppet:///modules/apache/redhat/ports.conf",
    require => Class['apache::install'],
  }

  $redhat_enabled = "alias auth_basic authn_file authz_default authz_groupfile authz_host authz_user autoindex log_config cgid deflate dir env mime negotiation setenvif status"
  exec { 'apache-mods-enabled-init':
    path    => ['/bin', '/usr/bin'],
    command => "bash -c 'for mod in ${redhat_enabled}; do ln -s ${apache::params::mods_available}/\${mod}.{load,conf} ${apache::params::mods_enabled}; done' && touch ${apache::params::mods_enabled}/.defaults",
    creates => "${apache::params::mods_enabled}/.defaults",
    require => Class['apache::redhat::default_modules'],
    notify  => Service['apache'],
  }
}

class apache::redhat::firewall {
  $table_http  = "iptables -A INPUT -p tcp --dport 80 -j ACCEPT"
  $table_https = "iptables -A INPUT -p tcp --dport 443 -j ACCEPT"
  exec { "persist-firewall":
    path    => ['/sbin', '/bin'],
    command => "${table_http} && ${table_https} && iptables-save > /etc/sysconfig/iptables && touch /root/.apache_firewall",
    creates => "/root/.apache_firewall",
    require => Class['apache::install'],
    notify  => Service['apache'],
  }
}


class apache::redhat {
  include apache::redhat::config
  #include apache::redhat::firewall
}
