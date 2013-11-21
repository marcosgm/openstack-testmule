class hypervisor{
	$basicpackages = ['vim-enhanced','puppet','git','screen']
	
	package { $basicpackages: ensure => installed }

	$hypervisorpackages = ['bridge-utils','kernel','libvirt']
	
	package { $hypervisorpackages: ensure => installed }
	
}
