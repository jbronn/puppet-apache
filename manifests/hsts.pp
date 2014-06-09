# == Class: apache::hsts
#
# Enables HTTP Strict Transport Security for Apache
#
# === Parameters
#
# [*max_age*]
#   The maximum header age, in seconds, to use with HSTS.  Defaults to
#  '15768000' (6 months).
#
class apache::hsts(
  $max_age = '15768000',
) inherits apache::params {
  include apache
  include sys
  if $::osfamily == Solaris {
    # This allows us to use HSTS without using `apache::module`
    # (which does not yet work on Solaris).
    $hsts_require = Class['apache::install']
  } else {
    include apache::headers
    $hsts_require = Class['apache::headers']
  }

  $hsts_conf = "${config_dir}/hsts.conf"
  file { $hsts_conf:
    owner   => 'root',
    group   => $sys::root_group,
    mode    => '0644',
    content => "# Enables HTTP Strict Transport Security (HSTS).
Header always set Strict-Transport-Security \"max-age=${max_age}; includeSubDomains\"\n",
    notify  => Service[$service],
    require => $hsts_require,
  }

  if $conf_suffix {
    file { "${conf_enabled}/hsts.conf":
      ensure => link,
      target => $hsts_conf,
    }
  }
}
