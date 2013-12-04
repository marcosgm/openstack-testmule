openstack-testmule
==================

Code to test many openstack topologies in a test mule machine (24 GB ram, single NIC, hosted on OVH)

GOAL:
Have a fully virtual environment to test all of Openstack features, specially with Neutron latest version. By using puppet configurations, we will replicate many environment configurations, and deploy openstack using automatisation tools (packstack, puppet stackforge modules, etc)

 As only one IPv4 is provided by OVH, but many IPv6 are available, we will probably have to use NAT for IPv4 or go fully IPv6.

REQUIRES: 
-Centos 6.4  64 bits
-Regular kernel with KVM (don't use OVH one)
-- do 'yum install kernel; grub2-mkconfig -o /boot/grub2/grub.cfg' and reboot
-- or, you can follow this guide to install the default kernel 

FIRST STEPS
yum update
rpm -ivh http://fedora.mirror.nexicom.net/epel/6/i386/epel-release-6-8.noarch.rpm
yum install puppet git
cd && git clone git@github.com:marcosgm/openstack-testmule.git
cd openstack-testmule/manifests
puppet apply node-testmule.pp

PUPPET REQUIREMENTS:
puppet module install puppetlabs-apache
puppet module install spiette/selinux
puppet module install spiette/selinux
puppet module install thias/libvirt
puppet module install puppetlabs-stdlib
puppet module install razorsedge/network


APACHE PUPPET MODULE FIX (F19 bug)
#puppet module install puppetlabs-apache
#sed 's/^User /Include conf.modules.d\/*.conf\nUser /g' /etc/puppet/modules/apache/templates/httpd.conf.erb


FOREMAN
yum -y install http://yum.theforeman.org/releases/1.3/f19/x86_64/foreman-release.rpm
yum -y install foreman-installer
