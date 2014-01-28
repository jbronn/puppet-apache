# == Class: apache::config
#
# Sets up directories and files related to Apache's configuration.
#
class apache::config inherits apache::params {
  include sys

  file { 'apache-security':
    ensure => file,
    path   => "${config_dir}/security.conf",
    owner  => 'root',
    group  => $sys::root_group,
    mode   => '0644',
    source => 'puppet:///modules/apache/security.conf',
    notify => Service['apache'],
  }

  # These directories are included by default on Ubuntu; we
  # want to ensure they exist on other platforms as well.
  file { 'apache-sites-available':
    ensure => directory,
    path   => $sites_available,
    owner  => 'root',
    group  => $sys::root_group,
    mode   => '0644',
  }

  file { 'apache-sites-enabled':
    ensure => directory,
    path   => $sites_enabled,
    owner  => 'root',
    group  => $sys::root_group,
    mode   => '0644',
  }

  file { 'apache-mods-available':
    ensure => directory,
    path   => $mods_available,
    owner  => 'root',
    group  => $sys::root_group,
    mode   => '0644',
  }

  file { 'apache-mods-enabled':
    ensure => directory,
    path   => $mods_enabled,
    owner  => 'root',
    group  => $sys::root_group,
    mode   => '0644',
  }

  # Customize the configuration file layout, depending on
  # the operating system.
  case $::osfamily {
    debian: {
      # We use our own `security.conf`, so remove Ubuntu's.
      file { "${config_dir}/security":
        ensure => absent,
        notify => Service['apache'],
      }
    }
    redhat: {
      include apache::redhat
    }
  }
}
