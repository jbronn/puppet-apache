# == Class: apache::headers
#
# Enables the headers module.
#
class apache::headers(
  $ensure = 'present',
) {
  apache::module { 'headers':
    ensure => $ensure,
  }
}
