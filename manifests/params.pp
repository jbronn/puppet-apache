# == Class: apache::params
#
# This class holds platform-dependent parameters for Apache 2.
#
class apache::params {
  case $::osfamily {
    solaris: {
      include sys::solaris
      $apachectl     = '/usr/apache2/2.2/bin/apachectl'
      $package       = 'web/server/apache-22'
      $config_root   = '/etc/apache2/2.2'
      $server_root   = '/usr/apache2/2.2'
      $config        = "${config_root}/httpd.conf"
      $config_dir    = "${config_root}/conf.d"
      $modules       = '/usr/apache2/2.2/libexec'
      $provider      = 'pkg'
      $user          = 'webservd'
      $restart       = true
      $service       = 'svc:/network/http:apache22'
      $pid           = '/var/run/apache2/2.2/httpd.pid'
      $document_root = '/var/apache2/2.2/htdocs'
      $logs          = '/var/apache2/2.2/logs'
    }
    debian: {
      $apachectl     = '/usr/sbin/apache2ctl'
      $package       = 'apache2-mpm-prefork'
      $config_root   = '/etc/apache2'
      $server_root   = $config_root
      $config        = "${config_root}/apache2.conf"
      $config_dir    = "${config_root}/conf.d"
      $modules       = '/usr/lib/apache2/modules'
      $devel         = 'apache2-prefork-dev'
      $user          = 'www-data'
      $restart       = false
      $service       = 'apache2'
      $pid           = '/var/run/apache2.pid'
      $document_root = '/var/www'
      $logs          = '/var/log/apache2'
      $auth_kerb     = 'libapache2-mod-auth-kerb'
      $wsgi          = 'libapache2-mod-wsgi'
    }
    redhat: {
      $apachectl     = '/usr/sbin/apachectl'
      $package       = 'httpd'
      $config_root   = '/etc/httpd'
      $server_root   = $config_root
      $config        = "${config_root}/conf/httpd.conf"
      $config_dir    = "${config_root}/conf.d"
      $modules       = "${server_root}/modules"
      $devel         = 'httpd-devel'
      $ssl_package   = 'mod_ssl'
      $user          = 'apache'
      $restart       = true
      $service       = 'httpd'
      $pid           = '/var/run/httpd/httpd.pid'
      $document_root = '/var/www/html'
      $logs          = '/var/log/httpd'
      $auth_kerb     = 'mod_auth_kerb' # from EPEL
      $wsgi          = 'mod_wsgi' # from EPEL
    }
    default: {
      fail("Do not know how to install Apache on ${::osfamily}.\n")
    }
  }

  # Directories for the available and enabled modules and virtual hosts.
  # I've adopted an "Ubuntu" theme for other operating systems as well,
  # as it lends itself to better management with puppet (e.g., only
  # need to have presence of a file rather than modify a large monolithic
  # `httpd.conf`).
  $mods_available  = "${config_root}/mods-available"
  $mods_enabled    = "${config_root}/mods-enabled"
  $sites_available = "${config_root}/sites-available"
  $sites_enabled   = "${config_root}/sites-enabled"
}
