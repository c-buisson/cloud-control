Description
===========

Cloud-Control is a project using KVM and Rundeck that lets you create/start/shutdown/destroy virtual machines.
You can choose to start a new virtual machine with an ISO or an Ubuntu Cloud image.


Assumptions
===========

KVM should already be working.

kvm-ok should return:
INFO: /dev/kvm exists
KVM acceleration can be used

Rundeck should be working as well.


Requirements
============

Environment
-----------

You will need to edit the "setup" file and add:
  -A backend type (file OR MySQL)
  -Start IP (i.e 192.168.0.1)
  -End IP (i.e 192.168.0.100)
  -Gateway IP (i.e 192.168.0.254)

Cloud-Control will assign static IPs to the KVM guests.
You need to specify an IP range for the guests and a gateway to route out.

Templates
---------

SSH-KEY: You can add your public key to TEMPLATE-user-data.erb in the templates directory.

When an Ubuntu Cloud image is used to launch a new instance, it will get a static IP.
ISO's on the other hand, will get a DHCP ip.


Setup
=====

You will need to execute the "setup" script to install all the required packages and gems.
Cloud-Control is using RVM.
