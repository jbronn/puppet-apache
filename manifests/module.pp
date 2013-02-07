# == Define: apache::module
#
# This define ensures that the given module is enabled, either with
# `a2enmod/a2dismod` on Debian/Ubuntu platforms, or by ensuring the
# correct files/links are present on other platforms.
#
define apache::module($ensure='present') {

  $ensure_values = ['enabled', 'present', 'absent', 'disabled']
  if ! ($ensure in $ensure_values) {
    fail("Invalid `apache::module` ensure value: ${ensure}.\n")
  }

  $mods_available = $apache::params::mods_available
  $mods_enabled = $apache::params::mods_enabled

  case $::osfamily {
    debian: {
      case $ensure {
        enabled, present: {
          exec { "a2enmod ${name}":
            path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
            unless  => "test -h ${mods_enabled}/${name}.load",
            require => Class['apache::install'],
            notify  => Service['apache'],
          }
        }
        disabled, absent: {
          exec { "a2dismod ${name}":
            path    => ['/usr/bin', '/usr/sbin', '/bin', '/sbin'],
            unless  => "test ! -h ${mods_enabled}/${name}.load",
            require => Class['apache::install'],
            notify  => Service['apache'],
          }
        }
      }
    }
    redhat: {
      # XXX: Find a way to this without files.
      case $ensure {
        enabled, present: {
          file { "${mods_enabled}/${name}.load":
            ensure  => link,
            target  => "${mods_available}/${name}.load",
            require => File[$mods_enabled],
            notify  => Service['apache'],
          }
          file { "${mods_enabled}/${name}.conf":
            ensure  => link,
            target  => "${mods_available}/${name}.conf",
            require => File[$mods_available],
            notify  => Service['apache'],
          }
        }
        disabled, absent: {
          file { "${mods_enabled}/${name}.load":
            ensure => absent,
            notify => Service['apache'],
          }
          file { "${mods_enabled}/${name}.conf":
            ensure => absent,
            notify => Service['apache'],
          }
        }
      }
    }
    default: {
      fail("Cannot enable/disable Apache modules on ${::osfamily}.\n")
    }
  }
}
