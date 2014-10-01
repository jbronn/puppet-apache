# == Class: apache::passenger::apt
#
# Installs Phusion Passenger for Apache via Ruby Gems by compiling it
# from source.
#
class apache::passenger::gem {
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
}
