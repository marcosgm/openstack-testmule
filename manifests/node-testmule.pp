node default {
    include hypervisor
    include webproxy
    include netmanager
}

class netmanager {
	class { 'dnsmasq':
	  interface      => 'mule-ext', #very important, to avoid dhcp on external interfaces
	  listen_address => '192.168.1.1',
	  domain         => 'testmule.moo.com',
	  port           => '53',
	  expand_hosts   => true,
	  enable_tftp    => false,
	  domain_needed  => true,
	  resolv_file    => '/etc/resolv.conf',
	  cache_size     => 1000
	}
	dnsmasq::dhcp { 'dhcp': 
	  dhcp_start => '192.168.1.100',
	  dhcp_end   => '192.168.1.254',
	  netmask    => '255.255.255.0',
	  lease_time => '24h'
	}
	dnsmasq::dhcpstatic { 'controller':
 	   mac => 'AA:AA:AA:AA:00:F1',
	   ip  => '192.168.1.254',
	}
	dnsmasq::dhcpstatic { 'compute1':
 	   mac => 'AA:AA:AA:AA:00:C1',
	   ip  => '192.168.1.241',
	}
	dnsmasq::dhcpstatic { 'compute2':
 	   mac => 'AA:AA:AA:AA:00:C2',
	   ip  => '192.168.1.242',
	}
	dnsmasq::dhcpstatic { 'compute3':
 	   mac => 'AA:AA:AA:AA:00:C3',
	   ip  => '192.168.1.243',
	}
}

class webproxy {
    class { 'apache':  
              default_mods => false,
              default_vhost => false,
    }
    include apache::mod::proxy
    include apache::mod::proxy_http
    $proxy_pass = [
      { 'path' => '/', 'url' => 'http://192.168.1.254/' },
    ]
    apache::vhost { 'controller.testmule.mooo.com':
      port    => '80',
      docroot => '/var/www/',
      proxy_pass => $proxy_pass, 
    }
}

class hypervisor{
	$basicpackages = ['vim-enhanced','puppet','git','screen','mlocate','lsof','etckeeper']
	
	package { $basicpackages: ensure => installed }

	$hypervisorpackages = ['bridge-utils','kernel','qemu-kvm-tools','virt-viewer'] #libvirt, qemu-kvm not necessary
	
	package { $hypervisorpackages: ensure => installed }
	package { ['virt-manager','redhat-lsb','xorg-x11-xauth','dejavu-lgc-sans-fonts']: ensure => installed }

	#nested KVM, needs a reboot after applied
	file {'/etc/modprobe.d/kvm-intel.conf':
		content=>"options kvm-intel nested=y"
	}
	
	#SELINUX
	class { 'selinux':
	  mode => 'disabled'
	}
	include hypervisor::libvirtconf
	include hypervisor::firewall
	include hypervisor::network
	include hypervisor::polipo
}

class hypervisor::polipo{
	package {'polipo':
		ensure => installed
	}
	service {'polipo':
                ensure => running,
	}
}

class hypervisor::firewall{
	package {"system-config-firewall-tui": ensure=> installed }
	service {"iptables": 
		ensure => running,
	}
}

class hypervisor::libvirtconf{

	#fix for #Error: internal error Process exited while reading console log output: chardev: opening backend "pty" failed: Permission denied
	user {'qemu':
		groups => ['qemu','kvm','tty'] , #tty group
	}

	class { 'libvirt':
	  defaultnetwork => false, # This is the default
	}

	libvirt::network { 'mule-ext':
   		ensure             => 'enabled',
   		autostart          => true,
   		forward_mode       => 'bridge',
   		forward_dev        => 'dummy0',
	}	
	libvirt::network { 'mule-int':
   		ensure             => 'enabled',
   		autostart          => true,
   		forward_mode       => 'bridge',
   		forward_dev        => 'dummy1',
	}
}

class hypervisor::network {

        network::bridge::static { 'mule-ext':
	  ensure    => 'up',
	  ipaddress => '192.168.1.1',
	  netmask   => '255.255.255.0',
	  delay  => '0',
	}
	network::bridge::static { 'mule-int':
	  ensure    => 'up',
	  ipaddress => '172.20.1.1',
	  netmask   => '255.255.255.0',
	  delay  => '0',
	}
#	file {'/etc/modprobe.conf':
#		content=>"dummy\n",
#		mode=>664,
#	}
	
	file {'/etc/modprobe.d/dummy.conf':
		#content=>"alias dummy0 muleNIC0\nalias dummy1 muleNIC1\noptions dummy numdummies=2 \n",
		content=>"options dummy numdummies=2 \n",
		mode=>664,
	}
	#a reboot is needed to create the dummy interfaces
	network::if::bridge { 'dummy0':
	  ensure => 'up',
	  bridge => 'mule-ext',
	}
	network::if::bridge { 'dummy1':
	  ensure => 'up',
	  bridge => 'mule-int',
	}
	host {'testmule.mooo.com':
		ip => '127.0.0.1'
	}
}
