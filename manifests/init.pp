# == Class: nis
#
# A simple class to manage NIS servers and clients
#
# === Parameters
#
# [*ypdomain*]
#   The NIS domain name
#
# [*ypserv*]
#   A single NIS server or an array of NIS servers
#
# [*ypmaster*]
#   The NIS master
#
# [*client*]
#   Enable the client configuration
#
# [*server*]
#   Enable the server configuration
#
# [*master*]
#   Enable the a master server if true or a slave one if false
#
# [*groups*]
#   Enable group login via NIS. Default is none.
#
# [*securenets*]
#   Securenets file to be used.
#
# [*hostallow*]
#   Hosts to allow for portmap/rpcbind.
#
# [*pwdir*]
#   Change the default location of PWDIR in the NIS Makefile
#
# === Examples
#
#  class { nis:
#    client   => true,
#    ypdomain => "example",
#    ypserv   => "nis.example.com",
#  }
#
# === Authors
#
# Alessandro De Salvo <Alessandro.DeSalvo@roma1.infn.it>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class nis (
   $ypdomain              = $nis::params::ypdomain,
   $ypserv                = $nis::params::ypserv,
   $ypmaster              = $nis::params::ypmaster,
   $client                = $nis::params::client,
   $server                = $nis::params::server,
   $master                = $nis::params::master,
   $groups                = $nis::params::groups,
   $nicknames             = $nis::params::nicknames,
   $securenets            = $nis::params::securenets,
   $hostallow             = $nis::params::hostallow,
   $pwdir                 = $nis::params::pwdir,
   $client_package        = $nis::params::client_package,
   $client_service        = $nis::params::client_service,
   $server_package        = $nis::params::server_package,
   $server_service        = $nis::params::server_service,
   $client_service_enable = $nis::params::client_service_enable,
   $server_service_enable = $nis::params::server_service_enable,
   $client_service_ensure = $nis::params::client_service_ensure,
   $server_service_ensure = $nis::params::server_service_ensure,
   $client_service_hasrestart = $nis::params::client_service_hasrestart,
   $server_service_hasrestart = $nis::params::server_service_hasrestart,
   $server_package_ensure = $nis::params::server_package_ensure,
   $client_package_ensure = $nis::params::client_package_ensure,
   $yp_config_command     = $nis::params::yp_config_command,
   $exec_path             = $nis::params::exec_path,
   $securenets_file       = $nis::params::securenets_file,
   $nis_pattern           = $nis::params::nis_pattern,
   $nsswitch_passwd_order = $nis::params::passwd_order,
   $nsswitch_shadow_order = $nis::params::shadow_order,
   $nsswitch_group_order  = $nis::params::group_order,
   $nsswitch_hosts_order  = $nis::params::hosts_order
) inherits nis::params {

   if ($client == false and $server == false) {
     fail('You must indicate whether a client, server or both will be installed') 
   }
   validate_string($ypdomain)
   validate_string($ypmaster)
   if ($ypserv) { validate_array($ypserv) }
   if ($client) { validate_array($ypserv) }
   if ($client) { validate_string($ypmaster) }
   if ($server) { validate_bool($master) }
   validate_bool($client)
   validate_bool($server)
   validate_bool($master)
   if ($pwdir) { validate_string($pwdir) }
   validate_string($client_package)
   validate_string($client_service)
   validate_array($server_package)
   validate_string($server_service)
   validate_bool($client_service_enable)
   validate_bool($server_service_enable)
   validate_array($exec_path)
   validate_bool($client_service_enable)
   validate_bool($client_service_ensure)
   validate_bool($client_service_hasrestart)
   validate_bool($server_service_enable)
   validate_bool($server_service_ensure)
   validate_bool($server_service_hasrestart)
   validate_string($server_package_ensure)
   validate_string($client_package_ensure)

   if ($client) {
     anchor{'nis::begin':}->
     class{'::nis::client::install':}->
     class{'::nis::config':}~>
     class{'::nis::client::config':}~>
     class{'::nis::client::service':}->
     anchor{'nis::end':}
   }

   if ($server) {
     anchor{'nis::begin':}->
     class{'::nis::server::install':}->
     class{'::nis::config':}~>
     class{'::nis::server::config':}~>
     class{'::nis::server::service':}->
     anchor{'nis::end':}
   }

}
