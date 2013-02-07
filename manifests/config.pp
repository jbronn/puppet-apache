# == Class: apache::config
#
# Sets up directories and files related to Apache's configuration.
#
class apache::config {
  include apache::params

  # Resource default for the Apache configuration files.
  if $::operatingsystem == Solaris {
    $group = 'bin'
  } else {
    $group = 'root'
  }

  File {
    owner   => 'root',
    group   => $group,
    mode    => '0644',
    require => Class['apache::install'],
  }

  file { 'apache-security':
    ensure => file,
    path   => "${apache::params::config_dir}/security.conf",
    source => 'puppet:///modules/apache/security.conf',
    notify => Service['apache'],
  }

  # These directories are included by default on Ubuntu; we
  # want to ensure they exist on other platforms as well.
  file { 'apache-sites-available':
    ensure => directory,
    path   => $apache::params::sites_available,
  }

  file { 'apache-sites-enabled':
    ensure => directory,
    path   => $apache::params::sites_enabled,
  }

  file { 'apache-mods-available':
    ensure => directory,
    path   => $apache::params::mods_available,
  }

  file { 'apache-mods-enabled':
    ensure => directory,
    path   => $apache::params::mods_enabled,
  }

  # Customize the configuration file layout, depending on
  # the operating system.
  case $::osfamily {
    debian: {
      include apache::ubuntu
    }
    redhat: {
      include apache::redhat
    }
  }
}
