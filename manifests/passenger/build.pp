# == Class: apache::passenger::build
#
# Installs necessary C/C++ development tools and headers to compile
# Phusion Passenger, which depend on the OS.
#
class apache::passenger::build {
  include sys::gcc
  include ruby::devel
  case $::osfamily {
    debian: {
      $dev_packages = ['libcurl4-openssl-dev', 'libssl-dev', 'zlib1g-dev']
    }
    redhat: {
      $dev_packages = ['libcurl-devel', 'openssl-devel', 'zlib-devel']
    }
    default: {
      fail("Don't know how to install Phusion Passenger on: ${::osfamily}.\n")
    }
  }

  # Libraries necessary to compile Passenger.
  package { $dev_packages:
    ensure  => installed,
    require => [ Class['sys::gcc'], Class['ruby::devel'] ],
  }
}
