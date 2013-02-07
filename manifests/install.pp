# == Class: apache::install
#
# Installs the Apache 2 web server.
#
class apache::install {
  include apache::params

  package { $apache::params::package:
    ensure   => installed,
    alias    => 'apache',
    provider => $apache::params::provider,
  }

  if $apache::params::ssl {
    # Install mod_ssl if not included with Apache package.
    package { $apache::params::ssl_package:
      ensure   => installed,
      alias    => 'apache-ssl',
      provider => $apache::params::provider,
    }
  }
}
