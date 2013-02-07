# == Class: apache::devel
#
# This class installs Apache development libraries
#
class apache::devel {
  include apache::params
  if $apache::params::devel {
    package { $apache::params::devel:
      ensure   => installed,
      alias    => 'apache-devel',
      provider => $apache::params::provider,
    }
  }
}
