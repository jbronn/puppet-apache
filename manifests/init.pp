# == Class: apache
#
# Module for installing the Apache 2 webserver.
#
# === Examples
#
#  class { 'apache': }
#
# === Authors
#
# Justin Bronn <justin@counsyl.com>
#
class apache {
  include apache::params
  include apache::install
  include apache::service
  include apache::config
}
