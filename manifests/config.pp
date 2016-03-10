class nis::config inherits nis {

   # Set domain
   case $::osfamily {
     'Debian': {
       file { '/etc/defaultdomain':
         content => "$ypdomain\n",
       }
     }
     'RedHat': {
       augeas{ "nis domain network" :
         context => "/files/etc/sysconfig/network",
         changes => [
           "set NISDOMAIN ${ypdomain}",
           "set DOMAIN ${ypdomain}",
         ],
       }
     }
   }

   augeas{ "nis group default" :
       context => "/files/etc/group",
       changes => [
           'set @nisdefault/password ""',
           'set @nisdefault/gid ""',
       ],
   }

   file { "/etc/yp.conf":
     ensure  => file,
     owner   => "root",
     group   => "root",
     mode    => "0644",
     content => template("nis/yp.conf.erb"),
     require => Package[$nis::nis_package]
   }

}
