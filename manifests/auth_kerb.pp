# == Class: apache::auth_kerb
#
# Installs the Kerberos Module for Apache (`mod_auth_kerb`).
#
# === Parameters
#
# [*package*]
#  The package for `mod_auth_kerb`, default is platform-dependent.
#
# [*version*]
#   Sets the ensure parameter for the package resource used
#   to install `mod_auth_kerb`.  Defaults to 'installed'.
#
# === Example
#
# Here's how you would install the `mod_auth_kerb` in your
# manifest:
#
#   include apache::auth_kerb
#
class apache::auth_kerb(
  $package = $apache::params::auth_kerb,
  $version = 'installed'
) inherits apache::params {
  include apache
  if $package {
    if $::osfamily == RedHat {
      $auth_kerb_require = [Class['apache::install'], Class['redhat::epel']]
    } else {
      $auth_kerb_require = Class['apache::install']
    }

    # Install the Apache `auth_kerb` module.
    package { $package:
      ensure  => $version,
      require => $auth_kerb_require,
    }

    # Ensure `auth_kerb` module load and configuration files
    # are present and enabled.
    apache::mod { 'auth_kerb':
      content => "\n", # Leave mod_auth_kerb configuration to sites.
    }
    apache::module { 'auth_kerb':
      ensure  => enabled,
      require => Apache::Mod['auth_kerb'],
    }
  }
}
