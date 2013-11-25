node default {
    file { "/tmp/test":
        owner => 'root',
        group => 'root',
        mode  => '0440',
	content => 'this is only a test\n',
    }
    include hypervisor
    include webproxy
}

