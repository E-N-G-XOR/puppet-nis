class nis::params {

  $ypdomain   = undef
  $ypserv     = undef
  $ypmaster   = undef
  $client     = false
  $server     = false
  $master     = false
  $groups     = undef
  $nicknames  = undef
  $securenets = undef
  $hostallow  = undef
  $pwdir      = false
  $client_service_enable = true
  $client_service_ensure = true
  $client_service_hasrestart = true
  $client_package_ensure = 'latest'
  $server_service_enable = true
  $server_service_ensure = true
  $server_service_hasrestart = true
  $server_package_ensure = 'latest'
  $exec_path = [ '/bin', '/usr/bin', '/usr/lib64/yp', '/usr/lib/yp', '/usr/sbin' ]


  case $::osfamily {
    'Debian': {
      $client_package = 'nis'
      $client_service = 'nis'
      $server_package = ['nis']
      $server_service = 'nis'
      $nis_pattern         = '/usr/sbin/ypbind'
      $securenets_file     = '/etc/ypserv.securenets'
      $yp_config_command = "domainname $ypdomain && ypinit -s $ypmaster"
    }
    'RedHat': {
      $client_package = 'ypbind'
      $client_service = 'ypbind'
      $server_package = ['ypserv','ypbind','yp-tools']
      $server_service = 'ypserv'
      $nis_pattern = 'ypbind'
      $securenets_file = '/var/yp/securenets'
      $yp_config_command = "domainname $ypdomain && ypinit -s $ypmaster && authconfig --enablenis --enablekrb5 --kickstart"
    }
    default: {fail("NIS class does not work on osfamily: ${::osfamily}")}
  }
}
