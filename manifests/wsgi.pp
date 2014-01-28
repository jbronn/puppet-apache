# == Class: apache::wsgi
#
# Installs the Apache module mod_wsgi, for Python Web applications.
#
# === Parameters
#
# For more information on the configuration parameters in this module consult:
# http://code.google.com/p/modwsgi/wiki/ConfigurationDirectives
#
# [*package*]
#  The package to install mod_wsgi from, the default is platform dependent.
#  Set to false to build from source.
#
# [*base_url*]
#  The base URL when building from source, must end in a trailing slash.
#  Defaults to: 'http://modwsgi.googlecode.com/files/'.
#
# [*source_version*]
#  When installing from source, the version to use.  Defaults to '3.4'.
#
# [*template*]
#  The template used to generate the Apache module configuration file
#  for mod_wsgi.  Defaults to 'apache/wsgi/wsgi.conf.erb'.
#
# [*accept_mutex*]
#  Undefined by default.
#
# [*case_sensitivity*]
#  Undefined by default.
#
# [*import_script*]
#  Undefined by default.
#
# [*lazy_initialization*]
#  Undefined by default.
#
# [*python_eggs*]
#  Undefined by default.
#
# [*python_executable*]
#  Undefined by default.
#
# [*python_home*]
#  Undefined by default.
#
# [*python_path*]
#  Undefined by default.
#
# [*python_optimize*]
#  Undefined by default.
#
# [*restrict_embedded*]
#  Undefined by default.
#
# [*restrict_signal*]
#  Undefined by default.
#
# [*restrict_stdin*]
#  Undefined by default.
#
# [*restrict_stdout*]
#  Undefined by default.
#
# [*socket_prefix*]
#  Undefined by default.
#
# === Examples
#
# Place this in your manifest to install mod_wsgi:
#
#   include apache::wsgi
#
class apache::wsgi(
  $package             = $apache::params::wsgi,
  $base_url            = 'http://modwsgi.googlecode.com/files/',
  $source_version      = '3.4',
  $template            = 'apache/wsgi/wsgi.conf.erb',
  $accept_mutex        = undef,
  $case_sensitivity    = undef,
  $daemon_process      = undef,
  $import_script       = undef,
  $lazy_initialization = undef,
  $python_eggs         = undef,
  $python_executable   = undef,
  $python_home         = undef,
  $python_path         = undef,
  $python_optimize     = undef,
  $restrict_embedded   = undef,
  $restrict_signal     = undef,
  $restrict_stdin      = undef,
  $restrict_stdout     = undef,
  $socket_prefix       = undef,
) inherits apache::params {
  include apache
  include python
  if $package {
    if $::osfamily == RedHat {
      # `mod_wsgi` package only on EPEL.
      include sys::redhat::epel
      $wsgi_require = Class['apache', 'python', 'sys::redhat::epel']
    } else {
      $wsgi_require = Class['apache', 'python']
    }

    # If the OS has a packaged version, use it.
    package { $package:
      ensure   => installed,
      alias    => 'mod_wsgi',
      provider => $provider,
      require  => $wsgi_require
    }

    $mod_require = Package[$wsgi]
  } else {
    # Otherwise, we try and install from source.
    include apache::devel
    include python::devel

    $wsgi_name    = "mod_wsgi-${source_version}"
    $wsgi_dir     = "/root/${wsgi_name}"
    $tarball      = "${wsgi_name}.tar.gz"
    $download_url = "${base_url}${tarball}"
    $build_path   = ['/usr/sbin', '/usr/bin', '/sbin', '/bin', '/usr/local/bin']

    sys::fetch { 'download-mod_wsgi':
      destination => "/root/${tarball}",
      source      => $download_url,
    }

    exec { 'extract-mod_wsgi':
      command => "tar xzf ${tarball}",
      cwd     => '/root',
      path    => $build_path,
      creates => $wsgi_dir,
      require => Sys::Fetch['download-mod_wsgi'],
    }

    exec { 'install-mod_wsgi':
      command => "${wsgi_dir}/configure && make && make install",
      cwd     => $wsgi_dir,
      path    => $build_path,
      creates => "${modules}/mod_wsgi.so",
      require => [Exec['extract-mod_wsgi'],
                  Class['apache::devel', 'python::devel']],
    }

    $mod_require = Exec['install-mod_wsgi']
  }

  # Ensure WSGI module configuration files are present, with any
  # customizations requested by the user.
  apache::mod { 'wsgi':
    content => template($template),
    require => $mod_require,
  }

  # Ensure mod_wsgi is enabled.
  apache::module { 'wsgi':
    ensure  => enabled,
    require => Apache::Mod['wsgi'],
  }
}
