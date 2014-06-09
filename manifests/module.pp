# == Define: apache::module
#
# This define ensures that the given module is enabled, either with
# `a2enmod/a2dismod` on Debian/Ubuntu platforms, or by ensuring the
# correct files/links are present on other platforms.
#
# === Parameters:
#
# [*ensure*]
#  Ensure value for this site, defaults to 'present'.  Valid values are:
#  'enabled', 'present', 'absent', or 'disabled'.
#
define apache::module(
  $ensure = 'present'
) {
  $ensure_values = ['enabled', 'present', 'absent', 'disabled']
  if ! ($ensure in $ensure_values) {
    fail("Invalid `apache::module` ensure value.\n")
  }

  # Shortcut to the module directories.
  include apache::params
  $mods_available = $apache::params::mods_available
  $mods_enabled = $apache::params::mods_enabled

  case $::osfamily {
    debian: {
      case $ensure {
        'enabled', 'present': {
          exec { "a2enmod ${name}":
            path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
            unless  => "test -h ${mods_enabled}/${name}.load",
            notify  => Service[$apache::params::service],
            require => Class['apache::config'],
          }
        }
        'disabled', 'absent': {
          exec { "a2dismod ${name}":
            path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
            unless  => "test ! -h ${mods_enabled}/${name}.load",
            notify  => Service[$apache::params::service],
            require => Class['apache::config'],
          }
        }
      }
    }
    redhat: {
      # XXX: Find a way to this without files.
      case $ensure {
        'enabled', 'present': {
          file { "${mods_enabled}/${name}.load":
            ensure  => link,
            target  => "${mods_available}/${name}.load",
            notify  => Service[$apache::params::service],
            require => Class['apache::config'],
          }
          file { "${mods_enabled}/${name}.conf":
            ensure  => link,
            target  => "${mods_available}/${name}.conf",
            notify  => Service[$apache::params::service],
            require => Class['apache::config'],
          }
        }
        'disabled', 'absent': {
          file { ["${mods_enabled}/${name}.load",
                  "${mods_enabled}/${name}.conf"]:
            ensure  => absent,
            notify  => Service[$apache::params::service],
            require => Class['apache::config'],
          }
        }
      }
    }
    default: {
      fail("Cannot enable/disable Apache modules on ${::osfamily}.\n")
    }
  }
}
