# == Define: apache::mod
#
# Creates Apache configuration files for the given module name.
#
define apache::mod($source=undef, $content=undef){
  include apache::params
  $module_load = "${apache::params::mods_available}/${name}.load"
  $module_conf = "${apache::params::mods_available}/${name}.conf"

  file { $module_load:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "LoadModule ${name}_module ${apache::params::modules}/mod_${name}.so\n",
    require => File['apache-mods-available'],
  }

  file { $module_conf:
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content,
    source  => $source,
    require => File['apache-mods-available'],
  }
}
