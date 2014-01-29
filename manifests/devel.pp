# == Class: apache::devel
#
# This class installs Apache development libraries
#
class apache::devel(
  $package  = $apache::params::devel,
  $provider = $apache::params::provider,
) inherits apache::params {
  if $package {
    package { $package:
      ensure   => installed,
      alias    => 'apache-devel',
      provider => $provider,
    }
  }
}
