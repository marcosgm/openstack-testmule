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
yum groupinstall development
yum install libxslt-devel libxml2-devel libvirt-devel
cd && git clone git@github.com:marcosgm/openstack-testmule.git
cd openstack-testmule/manifests
puppet apply node-testmule.pp

PUPPET REQUIREMENTS:
puppet module install puppetlabs-apache
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


PLAYING WITH VAGRANT-KVM
rpm -ivh http://files.vagrantup.com/packages/a40522f5fabccb9ddabad03d836e120ff5d14093/vagrant_1.3.5_x86_64.rpm
vagrant plugin install vagrant-kvm
vagrant up --provider=kvm


CREATING THE VM's

==Storage pool directory==
Create a new partition, undefine the 'default' one, so there is only one pool available

==Golden image==
Install centos in a VM named 'baseVM'
execute: virt-sysprep -d baseVM

==Cloning VMs==

virt-clone \
     --connect qemu:///system \
     --original baseVM \
     --name controller \
     --file /mnt/images/controller \
     --mac AA:AA:AA:AA:00:F1

(same for the other VM's)


USING OPENSTACK FOR THE FIRST TIME
ssh 192.168.1.254 for reading the credentials

Login into http://controller.testmule.mooo.com/dashboard

Everything should work OK, but is empty

== Import OS images into glance ==
(logged into the controller 192.168.1.254)
glance image-create --name 'Fedora 20 x86_64' --disk-format qcow2 --container-format bare --is-public true --copy-from http://cloud.fedoraproject.org/fedora-20.x86_64.qcow2

wget https://launchpad.net/cirros/trunk/0.3.0/+download/cirros-0.3.0-x86_64-disk.img 
glance image-create --name='cirros image' --is-public=true --container-format=bare --disk-format=qcow2 < cirros-0.3.0-x86_64-disk.img


== ENABLE NESTED KVM in Centos ==
http://wiki.centos.org/HowTos/NestedVirt
