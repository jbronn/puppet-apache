# == Class: apache::auth_kerb
#
# Installs the Kerberos Module for Apache (`mod_auth_kerb`).
#
# === Parameters
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
class apache::auth_kerb($version='installed') {
  include apache
  include apache::params
  if $apache::params::auth_kerb {
    if $::osfamily == RedHat {
      $auth_kerb_require = [Class['apache::install'], Class['redhat::epel']]
    } else {
      $auth_kerb_require = Class['apache::install']
    }

    # Install the Apache `auth_kerb` module.
    package { $apache::params::auth_kerb:
      ensure  => $version,
      require => $auth_kerb_require,
    }

    # Ensure `auth_kerb` module load and configuration files
    # are present and enabled.
    apache::mod { 'auth_kerb': }
    apache::module { 'auth_kerb':
      ensure  => enabled,
      require => Apache::Mod['auth_kerb'],
    }
  }
}
