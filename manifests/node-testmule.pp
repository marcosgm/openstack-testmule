node default {
    include hypervisor
    include webproxy
}


class webproxy {
    class { 'apache':  
              default_mods => true,
              default_vhost => false,
    }
  include apache::mod::proxy                                                                                                                                                                     

  apache::vhost { 'vm-foreman.mooo.com':
      port    => '443',
      ssl     => true,
      docroot => '/var/www/html',
      proxy_pass => [
         { path => '/', url => 'https://192.168.1.2' },
      ]
  }
}

class hypervisor{
	$basicpackages = ['vim-enhanced','puppet','git','screen','mlocate','lsof','etckeeper']
	
	package { $basicpackages: ensure => installed }

	$hypervisorpackages = ['bridge-utils','kernel','qemu-kvm-tools','virt-viewer'] #libvirt, qemu-kvm not necessary
	
	package { $hypervisorpackages: ensure => installed }
	package { ['virt-manager','redhat-lsb','xorg-x11-xauth','dejavu-lgc-sans-fonts']: ensure => installed }


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
   		forward_dev        => 'muleNIC0',
	}	
	libvirt::network { 'mule-int':
   		ensure             => 'enabled',
   		autostart          => true,
   		forward_mode       => 'bridge',
   		forward_dev        => 'muleNIC1',
	}
}

class hypervisor::network {

        network::bridge::static { 'mule-ext':
	  ensure    => 'up',
	  ipaddress => '192.168.1.1',
	  netmask   => '255.255.255.0',
	}
	network::bridge::static { 'mule-int':
	  ensure    => 'up',
	  ipaddress => '172.20.1.1',
	  netmask   => '255.255.255.0',
	}
	
	file {'/etc/modprobe.d/dummy.conf':
		content=>"	alias dummy0 muleNIC0
			alias dummy1 muleNIC1
			options dummy numdummies=2 \n",
		mode=>664,
	}
	#a reboot is needed to create the dummy interfaces
	network::if::bridge { 'muleNIC0':
	  ensure => 'up',
	  bridge => 'mule-ext'
	}
	network::if::bridge { 'muleNIC1':
	  ensure => 'up',
	  bridge => 'mule-int'
	}
}
