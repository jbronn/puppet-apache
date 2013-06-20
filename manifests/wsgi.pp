# == Class: apache::wsgi
#
# Installs the Apache module mod_wsgi, for Python Web applications.
#
# === Parameters
#
# For more information on the configuration parameters in this module consult:
# http://code.google.com/p/modwsgi/wiki/ConfigurationDirectives
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
) {
  include apache::params
  include apache::wsgi::install

  # Ensure WSGI module configuration files are present, with any
  # customizations requested by the user.
  apache::mod { 'wsgi':
    require => Class['apache::wsgi::install'],
    content => template($template),
    notify  => Service[$apache::params::service],
  }

  # Ensure mod_wsgi is enabled.
  apache::module { 'wsgi':
    ensure  => enabled,
    require => Apache::Mod['wsgi'],
  }
}
