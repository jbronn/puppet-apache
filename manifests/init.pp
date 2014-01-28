# == Class: apache
#
# Module for installing the Apache 2 webserver.
#
# === Examples
#
#  include apache
#
# === Authors
#
# Justin Bronn <justin@counsyl.com>
#
class apache {
  include apache::install
  include apache::config
  include apache::service

  # Use anchors to ensure proper class dependency order.
  anchor { 'apache::start': } ->
  Class['apache::install']    ->
  Class['apache::config']     ->
  Class['apache::service']    ->
  anchor { 'apache::end': }
}
