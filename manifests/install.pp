# == Class: apache::install
#
# Installs the Apache 2 web server.
#
# === Parameters
#
# [*package*]
#  The package for Apache2, default is platform-dependent.  This should be
#  customized in select occassions, e.g., you want 'apache2-mpm-prefork' on
#  Debian platforms.
#
class apache::install(
  $package     = $apache::params::package,
  $ssl_package = $apache::params::ssl_package,
  $provider    = $apache::params::provider,
) inherits apache::params {

  package { $package:
    ensure   => installed,
    alias    => 'apache',
    provider => $provider,
  }

  if $ssl_package {
    # Install mod_ssl if not included with Apache package.
    package { $ssl_package:
      ensure   => installed,
      alias    => 'apache-ssl',
      provider => $provider,
    }
  }
}
