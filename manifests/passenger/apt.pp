# == Class: apache::passenger::apt
#
# Installs Phusion Passenger via apt-get.
#
class apache::passenger::apt(
  $ensure  = 'installed',
  $package = $apache::params::passenger,
) inherits apache::params {
  include apache
  package { $package:
    ensure  => $ensure,
    require => Class['apache::install'],
  }
}
