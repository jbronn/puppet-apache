# == Class: apache::passenger
#
# Installs the Phusion Passenger module for Apache 2.
#
# === Parameters
#
# See the Phusion Passenger configuration documentation for more information
# on these tunable parameters.
#
# [*install_type*]
#  How to install Phusion Passenger, defaults to 'gem'.  May be set to 'apt'
#  for Debian platforms (which eliminates need to compile passenger's apache
#  module from source.
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
  $install_type       = 'gem',
  $max_pool_size      = '6',
  $max_requests       = undef,
  $pool_idle_time     = undef,
  $stat_throttle_rate = undef,
  $template           = 'apache/passenger/passenger.conf.erb',
) inherits apache::params {
  case $install_type {
    'apt': {
      include apache::passenger::apt
      $module_path = "${modules}/mod_passenger.so"
      $passenger_root = '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini'
      Class['apache::passenger::apt'] -> Apache::Mod['passenger']
    }
    'gem': {
      include apache::passenger::gem
      $module_path = $ruby::passenger::apache_module
      $passenger_root = $ruby::passenger::root
      Class['apache::passenger::gem'] -> Apache::Mod['passenger']
    }
    default: {
      fail("Invalid installation type.\n")
    }
  }

  # Create Apache Passenger module loading and configuration files.
  apache::mod { 'passenger':
    content => template($template),
    path    => $module_path,
  }

  # Enable Apache passenger module.
  apache::module { 'passenger':
    ensure  => present,
    require => Apache::Mod['passenger'],
  }
}
