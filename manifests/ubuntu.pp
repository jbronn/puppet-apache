# == Class: apache::ubuntu
#
# Performs Ubuntu-specific configuration for Apache.
#
class apache::ubuntu {
  include apache::params
  # We use our own `security.conf`, so remove Ubuntu's.
  file { "${apache::params::config_dir}/security":
    ensure  => absent,
    require => Class['apache::install'],
    notify  => Service['apache'],
  }
}
