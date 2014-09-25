class vmware-perl-sdk {

ensure_packages(['gcc','uuid','uuid-dev','libssl-dev','perl-doc','liburi-perl','libxml-libxml-perl','libcrypt-ssleay-perl'])

  file { '/opt/vmware':
        ensure  => directory,
        owner    => root,
        group    => root,
        before   => File['/opt/vmware/installer'],
  }

  file { '/opt/vmware/installer':
        ensure  => directory,
        owner    => root,
        group    => root,
        require  => File['/opt/vmware'],
        before   => File['/opt/vmware/installer/VMware-vSphere-Perl-SDK-5.5.0-1384587.x86_64.tar.gz'],
  }

  file { '/opt/vmware/installer/VMware-vSphere-Perl-SDK-5.5.0-1384587.x86_64.tar.gz':
        ensure  => file,
        source  => 'puppet:///modules/vmware-perl-sdk/VMware-vSphere-Perl-SDK-5.5.0-1384587.x86_64.tar.gz',
        owner    => root,
        group    => root,
        require  => File['/opt/vmware/installer'],
        before   => Exec['vmware_unzip'],
  }


  exec {"vmware_unzip":
    cwd     => '/opt/vmware/installer',
    command => '/bin/tar -xvzpf /opt/vmware/installer/VMware-vSphere-Perl-SDK-5.5.0-1384587.x86_64.tar.gz',
    unless  => '/usr/bin/test -d /opt/vmware/installer/vmware-vsphere-cli-distrib',
    require =>  File['/opt/vmware/installer/VMware-vSphere-Perl-SDK-5.5.0-1384587.x86_64.tar.gz' ],
  }

  exec {"cpan_libwww-perl-5.837":
    command => '/usr/bin/cpan GAAS/libwww-perl-5.837.tar.gz',
    unless  => '/usr/bin/test -f /opt/vmware/installer/vmware-vsphere-cli-distrib',
  }


}