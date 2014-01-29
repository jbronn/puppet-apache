# == Class: apache::hsts
#
# Enables HTTP Strict Transport Security for Apache
#
# === Parameters
#
# [*max_age*]
#   The maximum header age, in seconds, to use with HSTS.  Defaults to '600'.
#
class apache::hsts(
  $max_age = '600',
) inherits apache::params {
  include apache
  include sys
  if $::osfamily == Solaris {
    # This allows us to use HSTS without using `apache::module`
    # (which does not yet work on Solaris).
    $hsts_require = Class['apache::install']
  } else {
    # HSTS requires `mod_headers`.
    apache::module { 'headers':
      ensure => present,
    }
    $hsts_require = Apache::Module['headers']
  }

  file { "${config_dir}/hsts.conf":
    owner   => 'root',
    group   => $sys::root_group,
    mode    => '0644',
    content => "# Enables HTTP Strict Transport Security (HSTS).
Header always set Strict-Transport-Security \"max-age=${max_age}; includeSubDomains\"\n",
    notify  => Service['apache'],
    require => $hsts_require,
  }
}
