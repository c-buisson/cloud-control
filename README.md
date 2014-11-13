#Mission_Control

##Description

Mission_Control is a set of Rundeck projects that lets you `create / start / shutdown / destroy` virtual machines and containers.

##Installation

You will need to execute the `install` script to install all the required packages, gems and lay down the configuration files.

    ./install

**Variables:** You can edit the `vars` file to reflect your current environment or what you want. You can paste your SSH public keys here.

The install process will display a menu where you can choose to install any feature that you want.

##Environment

Mission_Control has been developed for **Ubuntu Trusty 14.04 LTS**.

#*kvm-control*

You can choose to start a new virtual machine with an ISO or an Ubuntu Cloud image.

When an Ubuntu Cloud image is used to launch a new instance, the vm will get a static IP. ISO's on the other hand, will get a DHCP ip.

###Network types:
*Netmask*: Mission_Control is setup to work on with Class C IPs, therefore the netmask is hard coded to: 255.255.255.0

####Floating IPs

You will need to edit the `vars` file and add:

 - The interface out (**Must be br0** if using floating static IPs!)
 - A backend type (*MySQL or PostgreSQL*)
 - Start IP (*i.e 192.168.0.1*)
 - End IP (*i.e 192.168.0.100*)
 - Gateway IP (*i.e 192.168.0.254*)

Mission_Control will assign floating IPs to the KVM guests. Those floating IPs should be able to reach the hypervisor's IP and the gateway. You need to specify a floating IP range for the guests and a gateway to route out.

**NAT IPs**:

By default Libvirt will install a new interface `virbr0` that will be managed by a DNSmasq process. DNSmasq will assign IPs to the new KVM guest with DHCP. The default range is:

- *192.168.122.2 to 192.168.122.254*

You can choose to assign a floating IP or a NAT IP when launching a new guest in Rundeck (i.e `Launch KVM guest`). Either way, the guest will be assigned a reserve static IP and a VNC port.

Deleting the KVM guest will release both the IP (floating or NAT) and the VNC port.

#*chef_server-control*

This is a Docker container that come with Chef Server 11 already installed. Mission_Control will download and launch this container if you want to. It will also grab the Knife admin keys and configure the Rundeck user to be able to use Knife.

#*docker-control*

You can manage Docker containers and images with this project.

Assumptions
-----------

###kvm-control:

 - VMs will reach the internet trough the hypervisor via `br0` if floating IP selected. While using NAT, `virbr0` will be used.

 - If a guest is launched with the NAT option, `virbr0` (192.168.122.1) will be used to route out.

###chef_server-control:

 - The Docker Chef_Server will be accessible via HTTPS:4443

Requirements
-----------

###KVM

The hypervisor should have `Virtual Technology` enabled. You can test this prior the installation by running:

    ubuntu@cbuisson:~$ egrep -c '(vmx|svm)' /proc/cpuinfo
    #Anything but 0 is good.

And after the installation:

    ubuntu@cbuisson:~$ kvm-ok
    INFO: /dev/kvm exists
    KVM acceleration can be used
