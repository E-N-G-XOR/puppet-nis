class nis::client::install inherits nis {

  package {$nis::client_package:
    ensure => $nis::client_package_ensure,
  }

}
