Description
---------------

Cloud-Control is a Rundeck/KVM project that lets you create/start/shutdown/destroy virtual machines. You can choose to start a new virtual machine with an ISO or an Ubuntu Cloud image.

Requirements
===========


Rundeck should be installed.

KVM should already be working.

    ubuntu@cbuisson:~$ kvm-ok
    INFO: /dev/kvm exists
    KVM acceleration can be used

Installation
========

You will need to execute the `setup` script to install all the required packages and gems.
Cloud-Control is using RVM.

    ./setup

Environment
-----------------

Cloud-Control has been developed for Ubuntu Trusty 14.04 LTS.

You will need to edit the "setup" file and add:

 - A backend type (flat file, MySQL or PostgreSQL)
 - Start IP (i.e 192.168.0.1)
 - End IP (i.e 192.168.0.100)
 - Gateway IP (i.e 192.168.0.254)

Cloud-Control will assign static IPs to the KVM guests.
You need to specify an IP range for the guests and a gateway to route out.

Templates
--------------

 - SSH-KEY: You can add your public key to TEMPLATE-user-data.erb in the templates directory.
 - netmask: Cloud-Control is setup to work on with Class C IPs, therefore the netwask is hard coded to: 255.255.255.0

When an Ubuntu Cloud image is used to launch a new instance, the vm will get a static IP.

ISO's on the other hand, will get a DHCP ip.

Assumptions
-----------------

 - VMs will reach the internet trough the hypervisor via `br0`, edit the KVM guests' XML template to reflect your environment.
