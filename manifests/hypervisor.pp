class hypervisor{
	$basicpackages = ['vim-enhanced','puppet','git','screen','mlocate','lsof','etckeeper']
	
	package { $basicpackages: ensure => installed }

	$hypervisorpackages = ['bridge-utils','kernel','qemu-kvm-tools','qemu-sanity-check'] #libvirt, qemu-kvm not necessary
	
	package { $hypervisorpackages: ensure => installed }
	package { ['virt-manager','redhat-lsb','xorg-x11-xauth','dejavu-lgc-sans-fonts']: ensure => installed }


	#SELINUX
	class { 'selinux':
	  mode => 'disabled'
	}
	include hypervisor::libvirtconf
	include hypervisor::firewall
}

class hypervisor::firewall{
	package {["iptables-services","system-config-firewall-tui"]: ensure=> installed }
	#service {'firewalld': 
	#	enable => false,
	#	ensure => stopped,
	#}
	#service {['iptables','iptables6']: 
	#	enable => true,
	#	ensure => running,
	#}
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
