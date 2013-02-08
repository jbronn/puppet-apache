# == Class: apache::wsgi::install
#
# Installs mod_wsgi for Apache.
#
class apache::wsgi::install {
  include apache
  include python
  if $apache::params::wsgi {
    if $::osfamily == RedHat {
      # `mod_wsgi` package only on EPEL.
      include sys::redhat::epel
      $wsgi_require = [ Class['apache::install'],
                        Class['python'],
                        Class['sys::redhat::epel']  ]

    } else {
      $wsgi_require = [ Class['apache::install'],
                        Class['python'] ]
    }

    # If the OS has a packaged version, use it.
    package { $apache::params::wsgi:
      ensure   => installed,
      alias    => 'mod_wsgi',
      provider => $apache::params::provider,
      require  => $wsgi_require
    }
  } else {
    # Otherwise, we try and install from source.
    include sys::wget
    include apache::devel
    include python::devel

    Exec {
      cwd  => '/root',
      path => ['/usr/sbin', '/usr/bin', '/sbin', '/bin'],
    }

    $version      = '3.4'
    $wsgi_name    = "mod_wsgi-${version}"
    $wsgi_dir     = "/root/${wsgi_name}"
    $tarball      = "${wsgi_name}.tar.gz"
    $download_url = "http://modwsgi.googlecode.com/files/${tarball}"

    exec { 'download-mod_wsgi':
      command => "wget ${download_url}",
      creates => "/root/${tarball}",
      require => Class['sys::wget'],
    }

    exec { 'extract-mod_wsgi':
      command => "tar xzf ${tarball}",
      creates => $wsgi_dir,
      require => Exec['download-mod_wsgi'],
    }

    exec { 'install-mod_wsgi':
      cwd     => $wsgi_dir,
      command => "${wsgi_dir}/configure && make && make install",
      creates => "${apache::params::modules}/mod_wsgi.so",
      require => [Exec['download-mod_wsgi'],
                  Class['apache::devel'],
                  Class['python::devel']],
    }
  }
}
