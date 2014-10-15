# == Class: apache::config
#
# Sets up directories and files related to Apache's configuration.
#
class apache::config inherits apache::params {
  include sys

  $apache_security = "${config_dir}/security.conf"
  file { $apache_security:
    ensure  => file,
    owner   => 'root',
    group   => $sys::root_group,
    mode    => '0644',
    content => template('apache/security.conf.erb'),
    notify  => Service[$service],
  }

  # These directories are included by default on Ubuntu; we
  # want to ensure they exist on other platforms as well.
  file { $sites_available:
    ensure => directory,
    owner  => 'root',
    group  => $sys::root_group,
    mode   => '0644',
  }

  file { $sites_enabled:
    ensure => directory,
    owner  => 'root',
    group  => $sys::root_group,
    mode   => '0644',
  }

  file {  $mods_available:
    ensure => directory,
    owner  => 'root',
    group  => $sys::root_group,
    mode   => '0644',
  }

  file { $mods_enabled:
    ensure => directory,
    owner  => 'root',
    group  => $sys::root_group,
    mode   => '0644',
  }

  # Customize the configuration file layout, depending on
  # the operating system.
  case $::osfamily {
    debian: {
      if $conf_suffix {
        file { "${conf_enabled}/security.conf":
          ensure => link,
          target => $apache_security,
        }
      } else {
        # We use our own `security.conf`, so remove Ubuntu's.
        file { "${config_dir}/security":
          ensure => absent,
          notify => Service[$service],
        }
      }
    }
    redhat: {
      include apache::redhat
    }
  }
}
