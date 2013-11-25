class webproxy {
    class { 'apache':  
	      default_mods => false,
	      default_vhost => false,
    }
}
