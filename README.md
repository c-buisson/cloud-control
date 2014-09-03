Description
===========

Cloud-Control is a KVM based set of scripts to create/start/shutdown/destroy virtual machines.
You can choose to start a new virtual machine with an ISO or an Ubuntu Cloud image.

For ease of use, these scripts could be executed from Rundeck.

Assumptions
===========

KVM should already be working. (kvm-ok should return INFO: /dev/kvm exists\n KVM acceleration can be used)
Rundeck should be working as well.

Requirements
============

Environment
-----------

You will need to edit the ENV file to point HOME and CLOUD_UTILS variables to their correct path.

Templates
---------

You can add your public key to TEMPLATE-user-data.erb in the templates directory.

When an Ubuntu Cloud image is used to launch a new instance, it will get a static IP. You will need to reflect your IP settings in the TEMPLATE-user-data.erb file.


Setup
=====

You will need to execute the setup script to install all the required packages and gems.
Cloud-Control is using RVM.
