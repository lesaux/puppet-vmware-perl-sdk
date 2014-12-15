class vmwareperlsdk {

  file { '/opt/vmware':
        ensure  => directory,
        owner    => root,
        group    => root,
        before   => File['/opt/vmware/installer'],
  }->

  file { '/opt/vmware/installer':
        ensure  => directory,
        owner    => root,
        group    => root,
        require  => File['/opt/vmware'],
        before   => File['/opt/vmware/installer/VMware-vSphere-Perl-SDK-5.5.0-1384587.x86_64.tar.gz'],
  }->

  file { '/opt/vmware/installer/VMware-vSphere-Perl-SDK-5.5.0-1384587.x86_64.tar.gz':
        ensure  => file,
        source  => 'puppet:///modules/vmware-perl-sdk/VMware-vSphere-Perl-SDK-5.5.0-1384587.x86_64.tar.gz',
        owner    => root,
        group    => root,
        require  => File['/opt/vmware/installer'],
        before   => Exec['vmware_unzip'],
  }->


  exec {"vmware_unzip":
    cwd     => '/opt/vmware/installer',
    command => '/bin/tar -xvzpf /opt/vmware/installer/VMware-vSphere-Perl-SDK-5.5.0-1384587.x86_64.tar.gz',
    unless  => '/usr/bin/test -d /opt/vmware/installer/vmware-vsphere-cli-distrib',
    require =>  File['/opt/vmware/installer/VMware-vSphere-Perl-SDK-5.5.0-1384587.x86_64.tar.gz' ],
  }->

case $::operatingsystem {
    'Debian', 'Ubuntu': {
      ensure_packages(['gcc','uuid','uuid-dev','libssl-dev','perl-doc','liburi-perl','libxml-libxml-perl','libcrypt-ssleay-perl'])
      exec {"cpan_libwww-perl-5.837":
        command => '/usr/bin/cpan GAAS/libwww-perl-5.837.tar.gz',
        unless  => '/usr/bin/test -f /sources/authors/id/G/GA/GAAS/libwww-perl-5.837.tar.gz',
      }
      exec {"vmware_install":
        cwd     => '/opt/vmware/installer/vmware-vsphere-cli-distrib',
        command => '/opt/vmware/installer/vmware-vsphere-cli-distrib/vmware-install.pl --default EULA_AGREED=yes --prefix=/opt/vmware',
        unless  => '/usr/bin/test -d /opt/vmware/bin',
        require =>  [Exec['vmware_unzip'],Exec['cpan_libwww-perl-5.837']],
      }
    }
    'Fedora', 'RedHat', 'CentOS', 'OEL', 'OracleLinux', 'Amazon': {
      ensure_packages(['gcc','perl-CPAN','uuid','uuid-devel','openssl-devel','perl-URI','perl-libxml-perl','perl-Net-SSLeay'])
      exec {"vmware_install":
        cwd     => '/opt/vmware/installer/vmware-vsphere-cli-distrib',
        command => '/opt/vmware/installer/vmware-vsphere-cli-distrib/vmware-install.pl --default EULA_AGREED=yes --prefix=/opt/vmware',
        unless  => '/usr/bin/test -d /opt/vmware/bin',
        require =>  Exec['vmware_unzip'],
      }
    }
    default: {
      fail('The module does not support this OS.')
    }
  }





}
