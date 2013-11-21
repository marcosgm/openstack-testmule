openstack-testmule
==================

Code to test many openstack topologies in a test mule machine (24 GB ram, single NIC, hosted on OVH)

GOAL:
Have a fully virtual environment to test all of Openstack features, specially with Neutron latest version. By using puppet configurations, we will replicate many environment configurations, and deploy openstack using automatisation tools (packstack, puppet stackforge modules, etc)

 As only one IPv4 is provided by OVH, but many IPv6 are available, we will probably have to use NAT for IPv4 or go fully IPv6.

REQUIRES: 
-Fedora 19 64 bits
-Regular kernel with KVM (don't use OVH one)
-- do 'yum install kernel' and reboot
-- or, you can follow this guide to install the default kernel 
