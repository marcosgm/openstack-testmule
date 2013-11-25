class webproxy {
    class { 'apache':  
	      default_mods => false,
	      default_vhost => false,
    }
#  apache::mod { 'proxy': }
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
