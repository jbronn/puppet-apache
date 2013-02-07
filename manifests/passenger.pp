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
  $max_pool_size='6',
  $max_requests=undef,
  $pool_idle_time=undef,
  $stat_throttle_rate=undef,
  $template='apache/passenger/passenger.conf.erb',
) {
  include apache::passenger::install

  # Create Apache Passenger module loading and configuration files.
  $load = "${apache::params::mods_available}/passenger.load"
  file { $load:
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template('apache/passenger/passenger.load.erb'),
    require => Class['apache::passenger::install'],
    notify  => Service['apache'],
  }

  $conf = "${apache::params::mods_available}/passenger.conf"
  file { $conf:
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => template($template),
    require => Class['apache::passenger::install'],
    notify  => Service['apache'],
  }

  # Enable Apache passenger module.
  apache::module { 'passenger':
    ensure  => present,
    require => [ File[$load], File[$conf] ],
  }
}
