# == Define: apache::mod
#
# Creates Apache configuration files to support a module of the given name.
# Specifically, creates a "${name}.load" and a "${name}.conf" files in the
# Apache server's `mods-available` directory.  It does *not* enable the
# module (use `apache::module` for that).
#
# === Parameters
#
# [*content*]
#  The content of the module's configuration file, mutually exclusive
#  with the `source` parameter.
#
# [*source*]
#  The source of the module's configuration file, mutually exclusive
#  with the `content` parameter.
#
# [*path*]
#  The path to the module's configuration file, defaults to:
#  "${apache::params::mods_available}/mod_${name}.so".
#
define apache::mod(
  $content = undef,
  $source  = undef,
  $path    = undef,
){
  # This defined type requires a content *or* a source parameter.
  if ($content and $source) {
    fail("Cannot provide both file content and source for module config.\n")
  } elsif (! $content and ! $source) {
    fail("Must provide either content or a source for the module config.\n")
  }

  include apache::params
  include sys

  # Convenience variables for the module's load and configuration files.
  $module_load = "${apache::params::mods_available}/${name}.load"
  $module_conf = "${apache::params::mods_available}/${name}.conf"

  if $path {
    $module_path = $path
  } else {
    $module_path = "${apache::params::modules}/mod_${name}.so"
  }

  file { $module_load:
    ensure  => file,
    owner   => 'root',
    group   => $sys::root_group,
    mode    => '0644',
    content => "LoadModule ${name}_module ${module_path}\n",
    require => Class['apache::config'],
  }

  file { $module_conf:
    ensure  => file,
    owner   => 'root',
    group   => $sys::root_group,
    mode    => '0644',
    content => $content,
    source  => $source,
    require => File[$module_load],
  }
}
