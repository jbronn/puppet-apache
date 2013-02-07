# == Class: apache::hsts
#
# Enables HTTP Strict Transport Security for Apache
#
# === Parameters
#
# [*max_age*]
#   The maximum header age, in seconds, to use with HSTS.  Defaults to '600'.
#
class apache::hsts($max_age='600') {
  include apache
  if $::osfamily == Solaris {
    # This allows us to use HSTS without using `apache::module`
    # (which does not yet work on Solaris).
    $group = 'bin'
    $hsts_require = Class['apache::install']
  } else {
    # HSTS requires `mod_headers`.
    apache::module { 'headers':
      ensure => present,
    }
    $group = 'root'
    $hsts_require = Apache::Module['headers']
  }

  file { "${apache::params::config_dir}/hsts.conf":
    owner   => 'root',
    group   => $group,
    mode    => '0644',
    content => "# Enables HTTP Strict Transport Security (HSTS).
Header always set Strict-Transport-Security \"max-age=${max_age}; includeSubDomains\"\n",
    require => $hsts_require,
    notify  => Service['apache'],
  }
}
