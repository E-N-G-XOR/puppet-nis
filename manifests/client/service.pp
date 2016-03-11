class nis::client::service inherits nis {

  service { $nis::client_service:
     ensure     => $nis::client_service_ensure,
     enable     => $nis::client_service_enable,
     hasrestart => $nis::client_service_hasrestart,
     pattern    => $nis::nis_pattern,
     subscribe  => [File["/etc/yp.conf"]],
     require    => [File["/etc/yp.conf"],File["/etc/nsswitch.conf"]]
  }

}

