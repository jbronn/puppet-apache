# == Class: apache::passenger
#
# Installs the Phusion Passenger module for Apache 2.
#
# === Parameters
#
# See the Phusion Passenger configuration documentation for more information
# on these tunable parameters.
#
# [*max_pool_size*]
#  Defaults to 6.
#
# [*max_requests*]
#  Undefined by default.
#
# [*pool_idle_time*]
#  Undefined by default.
#
# [*stat_throttle_rate*]
#  Undefined by default.
#
# [*template*]
#  Template used to generate the Apache module configuration file for
#  Passenger.  Defaults to 'apache/passenger/passenger.conf.erb'.
#
class apache::passenger(
  $max_pool_size      = '6',
  $max_requests       = undef,
  $pool_idle_time     = undef,
  $stat_throttle_rate = undef,
  $template           = 'apache/passenger/passenger.conf.erb',
) inherits apache::params {
  include apache
  include apache::devel
  include ruby::passenger
  include ruby::devel
  include sys
  include sys::gcc

  case $::osfamily {
    debian: {
      $dev_packages = ['libcurl4-openssl-dev', 'libssl-dev', 'zlib1g-dev']
    }
    redhat: {
      $dev_packages = ['libcurl-devel', 'openssl-devel', 'zlib-devel']
    }
    default: {
      fail("Don't know how to install Phusion Passenger for Apache on: ${::osfamily}.\n")
    }
  }

  # Libraries necessary to compile Passenger.
  package { $dev_packages:
    ensure  => installed,
    require => Class['sys::gcc', 'ruby::devel'],
  }

  # Compile and install passenger for Apache.
  exec { 'install-passenger-module':
    command     => 'passenger-install-apache2-module -a',
    creates     => $ruby::passenger::apache_module,
    path        => ['/usr/bin', '/bin', '/usr/local/bin'],
    user        => 'root',
    environment => ["HOME=${sys::root_home}"],
    subscribe   => Class['ruby::passenger'],
    require     => [Class['apache::config', 'apache::devel'],
                    Package[$dev_packages]],
  }

  # Create Apache Passenger module loading and configuration files.
  apache::mod { 'passenger':
    content => template($template),
    path    => $ruby::passenger::apache_module,
    require => Exec['install-passenger-module'],
  }

  # Enable Apache passenger module.
  apache::module { 'passenger':
    ensure  => present,
    require => Apache::Mod['passenger'],
  }
}
