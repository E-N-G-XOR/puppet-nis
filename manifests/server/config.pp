define add_nis_host_allow($hn = $title, $process) {
    augeas { "nis-hosts-allow-${process}-${hn}":
       context => "/files/etc/hosts.allow",
       changes => [
           "set 01/process ${process}",
           "set 01/client[.='${hn}'] ${hn}",
       ],
       onlyif => "match *[process='${process}'] size == 0"
    }
    augeas { "nis-hosts-allow-${process}-${hn}-client":
       context => "/files/etc/hosts.allow",
       changes => "set *[process='${process}']/client[.='${hn}'] ${hn}",
       require => Augeas["nis-hosts-allow-${process}-${hn}"],
    }
}

class nis::server::config inherits nis {

   if ($nis::master) { $server_mode = 'master' } else { $server_mode = 'slave' }

    case $::osfamily {
      'Debian': {
          augeas{ 'default nis master':
            context => '/files/etc/default/nis',
            changes => [
              'set NISSERVER $server_mode',
            ],
            require => Package[$nis::server_package],
          }
      }
      'RedHat': {
        if ($nis::hostallow) {
          add_nis_host_allow{$nis::hostallow: process => "portmap"}
        }

        augeas{ "ypserv service" :
          context => "/files/services",
          changes => [
              "ins service-name after service-name[last()]",
              "set service-name[last()] ypserv",
              "set service-name[.='ypserv']/port 834",
              "set service-name[.='ypserv']/protocol tcp",
              "ins service-name after service-name[last()]",
              "set service-name[last()] ypserv",
              "set service-name[.='ypserv'][2]/port 834",
              "set service-name[.='ypserv'][2]/protocol udp",
          ],
          onlyif => "match service-name[port='834'] size == 0",
          require => Package[$nis::server_package],
        }

        augeas{ "ypxfrd service" :
          context => "/files/services",
          changes => [
              "ins service-name after service-name[last()]",
              "set service-name[last()] ypxfrd",
              "set service-name[.='ypxfrd']/port 835",
              "set service-name[.='ypxfrd']/protocol tcp",
              "ins service-name after /files/etc/services/service-name[last()]",
              "set service-name[last()] ypxfrd",
              "set service-name[.='ypxfrd'][2]/port 835",
              "set service-name[.='ypxfrd'][2]/protocol udp",
          ],
          onlyif => "match service-name[port='835'] size == 0",
          require => Package[$nis::server_package],
        }

        augeas{ "nis server network" :
          context => "/files/etc/sysconfig/network",
          changes => [
              "set YPSERV_ARGS '\"-p 834\"'",
              "set YPXFRD_ARGS '\"-p 835\"'",
          ],
          require => Package[$nis::server_package],
          notify  => Service[$nis::server_service],
        }
      }
    }

  if ($nis::pwdir) {
    augeas {"Makefile":
      context => "/files/var/yp/Makefile",
      changes => "set PWDIR '=$pwdir'"
    }
  }

  if ($nis::nicknames) {
    file { "/var/yp/nicknames":
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => $nis::nicknames,
      require => Package[$nis::server_package],
      notify  => Service[$nis::server_service],
    }

  }

  if ($nis::securenets) {
    file { "/var/yp/securenets":
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      source  => $nis::securenets,
      require => Package[$nis::server_package],
      notify  => Service[$nis::server_service],
    }
  }

  augeas{ "nis server nicknames" :
    context => "/files/var/yp/nicknames",
    changes => [
      "set passwd/map passwd.byname",
      "set group/map group.byname",
      "set hosts/map hosts.byname",
      "set netgroup/map netgroup",
    ],
    require => Package[$nis::params::nis_srv_package],
    notify  => Service[$nis::params::nis_srv_service],
  }

  exec {'yp-config':
    command => $nis::yp_config_command,
    path    => $exec_path,
    unless  => "test -d /var/yp/$nis::ypdomain",
    require => Package["$nis::server_package"],
    notify  => Service["$nis::server_service"],
  }

}
