# == Class: apache::service
#
# Manages the Apache service.
#
class apache::service(
  $service = $apache::params::service,
  $ensure  = 'running',
  $enable  = true,
) inherits apache::params {
  service { $service:
    ensure => $ensure,
    enable => $enable,
    alias  => 'apache',
  }
}
