# == Define: apache::site
#
# Ensures that the Apache site (specified by $name) is either enabled
# or disabled.  This defined type can optionally manage the site file
# itself by specifying the `content` or `source` parameters.
#
# === Parameters
#
# [*ensure*]
#  If this is 'enabled' or 'present' (the default) then the site is enabled.
#  Otherwise, if 'disabled' or 'absent' the site will be disabled.
#
# [*content*]
#  The content to use for the site configuration file, mutually exclusive with
#  the `source` parameter.
#
# [*source*]
#  The Puppet file source for the site configuration file, mutually exclusive
#  with the `content` parameter.
#
# [*owner*]
#  The owner of the site configuration file (if managed), defaults to 'root'.
#
# [*group*]
#  The group of the site configuration file (if managed), defaults to 'root'.
#
# [*mode*]
#  The mode for the site configuration file (if managed), defaults to '0644'.
#
# === Examples
#
# To disable the default Apache site:
#
#  apache::site { 'default':
#    ensure => disabled,
#  }
#
define apache::site(
  $ensure  = 'present',
  $content = undef,
  $source  = undef,
  $owner   = 'root',
  $group   = 'root',
  $mode    = '0644',
) {
  $ensure_values = ['enabled', 'present', 'absent', 'disabled']
  if ! ($ensure in $ensure_values) {
    fail("Invalid `apache::site` ensure value: ${ensure}.\n")
  }

  # Getting location of sites-available/sites-enabled from apache::params.
  include apache::params
  $sites_available = $apache::params::sites_available
  $sites_enabled = $apache::params::sites_enabled

  if ($content or $source) {
    $site = "${sites_available}/${name}"
    file { $site:
      ensure  => file,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      content => $content,
      source  => $source,
      require => Class['apache::config'],
    }
    $site_require = File[$site]
  } elsif ($content and $source) {
    fail("Cannot provide both file content and source for site.\n")
  } else {
    $site = false
    $site_require = Class['apache::config']
  }

  case $::osfamily {
    debian: {
      # Special handling for Debian's 'default' site as it has a
      # '000-' prefix that's different from its name.
      if $name == 'default' {
        $site_link = "${sites_enabled}/000-default"
      } else {
        $site_link = "${sites_enabled}/${name}"
      }

      case $ensure {
        'enabled', 'present': {
          exec { "a2ensite ${name}":
            path    => ['/usr/bin', '/usr/sbin', '/bin'],
            unless  => "test -h ${site_link}",
            notify  => Service['apache'],
            require => $site_require,
          }
        }
        'disabled', 'absent': {
          exec { "a2dissite ${name}":
            path    => ['/usr/bin', '/usr/sbin', '/bin'],
            unless  => "test ! -h ${site_link}",
            notify  => Service['apache'],
            require => $site_require,
          }
        }
      }
    }
    redhat: {
      case $ensure {
        'enabled', 'present': {
          file { "${sites_enabled}/${name}":
            ensure  => link,
            target  => "${sites_available}/${name}",
            notify  => Service['apache'],
            require => $site_require,
          }
        }
        'disabled', 'absent': {
          file { "${sites_enabled}/${name}":
            ensure  => absent,
            notify  => Service['apache'],
            require => $site_require,
          }
        }
      }
    }
    default: {
      fail("Cannot enable/disable Apache sites on ${::osfamily}.\n")
    }
  }
}
