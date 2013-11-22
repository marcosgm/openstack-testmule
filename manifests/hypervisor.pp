class hypervisor{
	$basicpackages = ['vim-enhanced','puppet','git','screen','mlocate','lsof']
	
	package { $basicpackages: ensure => installed }

	$hypervisorpackages = ['bridge-utils','kernel','qemu-kvm-tools','qemu-sanity-check'] #libvirt, qemu-kvm not necessary
	
	package { $hypervisorpackages: ensure => installed }
	package { ['virt-manager','xorg-x11-xauth','dejavu-lgc-sans-fonts']: ensure => installed }


	#SELINUX
	class { 'selinux':
	  mode => 'disabled'
	}
	include hypervisor::libvirtconf
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
   		forward_dev        => 'br-ext',
	}
}
