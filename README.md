Description
-----------

Cloud-Control is a Rundeck/KVM project that lets you create/start/shutdown/destroy virtual machines. You can choose to start a new virtual machine with an ISO or an Ubuntu Cloud image.

Requirements
============

Rundeck should be installed.

The hypervisor should have `Virtual Technology` enabled. You can test this prior the installation by running:

    ubuntu@cbuisson:~$ egrep -c '(vmx|svm)' /proc/cpuinfo
    #Anything but 0 is good.

And after the installation:

    ubuntu@cbuisson:~$ kvm-ok
    INFO: /dev/kvm exists
    KVM acceleration can be used


Installation
============

You will need to execute the `install` script to install all the required packages and gems.
Cloud-Control is using RVM.

    ./install

Environment
-----------

Cloud-Control has been developed for **Ubuntu Trusty 14.04 LTS**.

>Floating IPs:

You will need to edit the `install` file and add:

 - A backend type (*flat file, MySQL or PostgreSQL*)
 - Start IP (*i.e 192.168.0.1*)
 - End IP (*i.e 192.168.0.100*)
 - Gateway IP (*i.e 192.168.0.254*)

Cloud-Control will assign floating IPs to the KVM guests. Those floating IPs should be able to reach the hypervisor's IP and the gateway. You need to specify a floating IP range for the guests and a gateway to route out.

>NAT IPs:

By default Libvirt will install a new interface `virbr0` that will be managed by a DNSmasq process. DNSmasq will assign IPs to the new KVM guest with DHCP. The default range is:

- *192.168.122.2 to 192.168.122.254*

You can choose to assign a floating IP or a NAT IP when launching a new guest in Rundeck (i.e `Launch KVM guest`). Either way, the guest will be assigned a reserve static IP and a VNC port.

Deleting the KVM guest will release both the IP (floating or NAT) and the VNC port.

Templates
---------

 - **ssh-key**: You can add your public key to TEMPLATE-user-data{-nat}.erb  and in the templates directory.
 - **netmask**: Cloud-Control is setup to work on with Class C IPs, therefore the netmask is hard coded to: 255.255.255.0

When an Ubuntu Cloud image is used to launch a new instance, the vm will get a static IP.

ISO's on the other hand, will get a DHCP ip.

Assumptions
-----------

 - VMs will reach the internet trough the hypervisor via `br0`, edit the KVM guests' XML template to reflect your environment.

 - If a guest is launched with the NAT option, `virbr0` (192.168.122.1) will be used to route out.
