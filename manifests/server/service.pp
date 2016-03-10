class nis::server::service inherits nis {

  service {$nis::server_service:
    ensure => $nis::server_service_ensure,
    enable => $nis::server_service_enable,
    hasrestart => $nis::server_service_hasrestart,
    require => Package[$nis::server_package],
  }

}
