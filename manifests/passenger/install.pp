# == Class: apache::passenger::install
#
# Installs Phusion Passenger, and compiles its Apache module.
#
class apache::passenger::install {
  include apache
  include apache::devel
  include ruby::passenger
  include apache::passenger::build
  include sys

  exec { 'install-passenger-module':
    command     => 'passenger-install-apache2-module -a',
    creates     => $ruby::passenger::apache_module,
    path        => ['/usr/bin', '/bin', '/usr/local/bin'],
    user        => 'root',
    environment => ["HOME=${sys::root_home}"],
    subscribe   => Package['passenger'],
    require     => [Class['apache::passenger::build'],
                    Class['apache::install'],
                    Class['apache::devel'],
                    Package['passenger']],
  }
}
