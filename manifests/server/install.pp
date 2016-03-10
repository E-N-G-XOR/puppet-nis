class nis::server::install inherits nis {

  package {$nis::server_package:
    ensure => $nis::server_package_ensure,
  }

}
