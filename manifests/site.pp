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

  if $apache::params::conf_suffix {
    $site_name = "${name}.conf"
  } else {
    $site_name = $name
  }

  if ($content and $source) {
    fail("Cannot provide both file content and source for site.\n")
  } elsif ($content or $source) {
    $site = "${sites_available}/${site_name}"
    file { $site:
      ensure  => file,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      content => $content,
      source  => $source,
      notify  => Service[$apache::params::service],
      require => Class['apache::config'],
    }
    $site_require = File[$site]
  } else {
    $site = false
    $site_require = Class['apache::config']
  }

  case $::osfamily {
    debian: {
      # Special handling for Debian's 'default' site as it has a '000-' prefix
      # that's different from it's name.  In addition, older versions of the
      # a2ensite/a2dissite scripts would map 'default' to this, while newer
      # versions require the name with a prefix.
      if $name == 'default' {
        if $apache::params::conf_suffix {
          $exec_name = '000-default'
          $site_link = "${sites_enabled}/000-default.conf"
        } else {
          $exec_name = 'default'
          $site_link = "${sites_enabled}/000-default"
        }
      } else {
        $exec_name = $name
        $site_link = "${sites_enabled}/${site_name}"
      }

      case $ensure {
        'enabled', 'present': {
          exec { "a2ensite ${exec_name}":
            path    => ['/usr/bin', '/usr/sbin', '/bin'],
            unless  => "test -h ${site_link}",
            notify  => Service[$apache::params::service],
            require => $site_require,
          }
        }
        'disabled', 'absent': {
          exec { "a2dissite ${exec_name}":
            path    => ['/usr/bin', '/usr/sbin', '/bin'],
            unless  => "test ! -h ${site_link}",
            notify  => Service[$apache::params::service],
            require => $site_require,
          }
        }
      }
    }
    redhat: {
      case $ensure {
        'enabled', 'present': {
          file { "${sites_enabled}/${site_name}":
            ensure  => link,
            target  => "${sites_available}/${site_name}",
            notify  => Service[$apache::params::service],
            require => $site_require,
          }
        }
        'disabled', 'absent': {
          file { "${sites_enabled}/${site_name}":
            ensure  => absent,
            notify  => Service[$apache::params::service],
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
