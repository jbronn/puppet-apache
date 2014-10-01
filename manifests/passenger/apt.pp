# == Class: apache::passenger::apt
#
# Installs Phusion Passenger via apt-get.
#
class apache::passenger::apt(
  $ensure  = 'installed',
  $package = 'libapache2-mod-passenger',
) {
  include apache
  package { $package:
    ensure  => $ensure,
    require => Class['apache::install'],
  }
}
