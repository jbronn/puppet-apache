# == Class: apache::service
#
# Manages the Apache service.
#
class apache::service {
  include apache::params
  service { $apache::params::service:
    ensure     => running,
    alias      => 'apache',
    enable     => true,
    hasstatus  => true,
    hasrestart => $apache::params::restart,
    require    => Class['apache::install'],
  }
}
