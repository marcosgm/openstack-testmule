openstack-testmule
==================

Code to test many openstack topologies in a test mule machine (24 GB ram, single NIC, hosted on OVH)

GOAL:
Have a fully virtual environment to test all of Openstack features, specially with Neutron latest version. By using puppet configurations, we will replicate many environment configurations, and deploy openstack using automatisation tools (packstack, puppet stackforge modules, etc)

 As only one IPv4 is provided by OVH, but many IPv6 are available, we will probably have to use NAT for IPv4 or go fully IPv6.

REQUIRES: 
-Fedora 19 64 bits
-Regular kernel with KVM (don't use OVH one)
-- do 'yum install kernel; grub2-mkconfig -o /boot/grub2/grub.cfg' and reboot
-- or, you can follow this guide to install the default kernel 

PUPPET REQUIREMENTS:
(puppet 3 installed via 'yum install puppet')
puppet module install carlasouza/virt
puppet module install spiette/selinux
puppet module install thias/libvirt
puppet module install puppetlabs-stdlib

APACHE PUPPET MODULE FIX (F19 bug)
#puppet module install puppetlabs-apache
#sed 's/^User /Include conf.modules.d\/*.conf\nUser /g' /etc/puppet/modules/apache/templates/httpd.conf.erb


FOREMAN
yum -y install http://yum.theforeman.org/releases/1.3/f19/x86_64/foreman-release.rpm
yum -y install foreman-installer
