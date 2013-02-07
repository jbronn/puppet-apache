# == Class: apache::passenger::install
#
# Installs Phusion Passenger, and compiles its Apache module.
#
class apache::passenger::install {
  include apache
  include apache::devel
  include ruby::passenger
  include apache::passenger::build

  exec { 'install-passenger-module':
    path      => ['/usr/bin', '/bin'],
    command   => 'passenger-install-apache2-module -a',
    unless    => "test -f ${ruby::passenger::root}/ext/apache2/mod_passenger.so",
    subscribe => Package['passenger'],
    require   => [Class['apache::passenger::build'],
                  Class['apache::install'],
                  Class['apache::devel'],
                  Package['passenger']],
  }
}
