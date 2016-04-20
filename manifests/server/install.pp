class nis::server::install inherits nis {

  package {$nis::server_package:
    ensure => $nis::server_package_ensure,
  }

  # Client service is used as ypbind needs to be notified
  service { $nis::client_service:
     ensure     => $nis::client_service_ensure,
     enable     => $nis::client_service_enable,
     hasrestart => $nis::client_service_hasrestart,
     pattern    => $nis::nis_pattern,
  }


}
