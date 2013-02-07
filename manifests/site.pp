# == Define: apache::site
#
# Ensures that the Apache site (specified by $name) is either enabled
# or disabled.
#
# === Parameters
#
# [*ensure*]
#  If this is 'enabled' or 'present' (the default) then the site is enabled.
#  Otherwise, if 'disabled' or 'absent' the site will be disabled.
#
# === Examples
#
# To disable the default Apache site:
#
#  apache::site { 'default':
#    ensure => disabled,
#  }
#
define apache::site($ensure='present') {

  $ensure_values = ['enabled', 'present', 'absent', 'disabled']
  if ! ($ensure in $ensure_values) {
    fail("Invalid `apache::site` ensure value: ${ensure}.\n")
  }

  $sites_enabled   = $apache::params::sites_enabled

  case $::osfamily {
    debian: {
      if $name == 'default' {
        $link_name = '000-default'
      } else {
        $link_name = $name
      }
      case $ensure {
        enabled, present: {
          exec { "a2ensite ${name}":
            path    => ['/usr/bin', '/usr/sbin', '/bin'],
            unless  => "test -h ${sites_enabled}/${link_name}",
            notify  => Service['apache'],
            require => Class['apache::install'],
          }
        }
        disabled, absent: {
          exec { "a2dissite ${name}":
            path    => ['/usr/bin', '/usr/sbin', '/bin'],
            unless  => "test ! -h ${sites_enabled}/${link_name}",
            notify  => Service['apache'],
            require => Class['apache::install'],
          }
        }
      }
    }
    redhat: {
      case $ensure {
        enabled, present: {
          file { "${sites_enabled}/${name}":
            ensure  => link,
            target  => "${apache::params::sites_available}/${name}",
            require => File[$sites_enabled],
            notify  => Service['apache'],
          }
        }
        disabled, absent: {
          file { "${sites_enabled}/${name}":
            ensure => absent,
            notify => Service['apache'],
          }
        }
      }
    }
    default: {
      fail("Cannot enable/disable Apache sites on ${::osfamily}.\n")
    }
  }
}
