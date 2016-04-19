define nis::enable_nis_groups {
    augeas{ "${title} nis group enable" :
        context => '/files/etc/passwd',
        changes => [
            "set @nis ${title}",
        ],
    }
}

class nis::client::config inherits nis {

   if (!$groups) {
       augeas{ 'add nis passwd default' :
           context => '/files/etc/passwd',
           changes => [
               'set @nisdefault/password x',
               'set @nisdefault/uid ""',
               'set @nisdefault/gid ""',
               'clear @nisdefault/name',
               'clear @nisdefault/home',
               'set @nisdefault/shell /sbin/nologin',
           ],
       }
       augeas{ 'remove nis groups' :
           context => '/files/etc/passwd',
           changes => [
               'rm @nis',
           ],
       }
   } else {
       augeas{ 'remove nis passwd default' :
           context => '/files/etc/passwd',
           changes => [
               'rm @nisdefault',
           ],
       }
       nis::enable_nis_groups { $groups: }
   }

   file { '/etc/nsswitch.conf':
     ensure => file,
     owner  => 'root',
     group  => 'root',
     mode   => '0644',
     source => 'puppet:///modules/nis/nsswitch.conf',
   }

   augeas{ "nis group default" :
       context => "/files/etc/group",
       changes => [
           'set @nisdefault/password ""',
           'set @nisdefault/gid ""',
       ],
   }

   service{"$nis::client_service":
     ensure => running,
   }



}
