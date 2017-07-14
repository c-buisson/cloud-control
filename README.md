# Mission_Control

## Description

Mission_Control is a set of Rundeck projects that lets you `create / start / shutdown / destroy` virtual machines and containers.

## Installation

First, edit the `vars` file with your parameters. Then, you will need to execute the `install` script to install all the required packages, gems and lay down the configuration files.
```bash
    cbuisson@server:~/mission_control$ ./install
```
To update the current configuration, edit the `vars` file and execute the `install` script again. The script can be run anytime.

## Environment

Mission_Control has been developed for a **brand new** install of **Ubuntu Xenial 16.04 LTS**.

## Project: *kvm-control*

Launch a new personalized KVM guest with:
 - SSH public keys importation
 - Automatic DNS entry creation
 - Static IP assignment
 - VNC accessibility
 - Chef-client installed and configured

kvm-control will launch the KVM guests with a fully qualified domain name `.local`. Bind9 will be installed/used by default to dynamically manage the DNS A and PTR records.

kvm-control was designed to work with Class C IPs. The netmask is hard coded to: **255.255.255.0**.

You can also choose to start a new virtual machine with an ISO or an Ubuntu Cloud image. When an Ubuntu Cloud image is used to launch a new instance, the KVM guest will get a static IP. ISO's on the other hand, will get a DHCP IP.

### Network setup (Floating IP / NAT IP)

You can choose to assign a floating IP (public address accessible by external servers on the same local network) or a NAT IP (private address accessible by the hypervisor only) when launching a new KVM guest in Rundeck. The guest will be assigned a static IP and a VNC port.

Deleting the KVM guest will release both the IP (floating or NAT) and the VNC port.

### Floating IPs

You will need to edit the `vars` file and already have created a Linux bridge interface:

 - Interface out (**Must be named**: `br0`!)
 - Start IP (*i.e 192.168.0.1*)
 - End IP (*i.e 192.168.0.100*)
 - Gateway IP (*i.e 192.168.0.254*)

The kvm-control's jobs will assign floating IPs to the KVM guests. These floating IPs should be able to reach the hypervisor and the gateway IPs.

### NAT IPs

By default, Libvirt will configure a new interface (`virbr0`) that will be managed by a DNSmasq process. DNSmasq will assign IPs to the new KVM guest with DHCP. The default range is from **192.168.122.2** to **192.168.122.254**.

### Chef-Server

You can optionally bootstrap the KVM guests to a Chef-Server at launch time.
In order to use this feature, select the "Docker Chef container" option while running the `install` script. This option will appears after the installation of `kvm-control`.

Mission_Control will start the two following Docker instances:

**Chef-Server**: Comes with Chef Server 12 already installed and configured. Mission_Control will also grab the Knife admin keys and configure both your current user and the Rundeck user to be able to use the Knife command.

**Chef-Rundeck**: Allows Rundeck to display the Chef client nodes directly in the "Nodes" tab. Once visible, you can run commands directly to the Chef client nodes from the Rundeck UI.

### Notes

 - KVM guests will reach the internet trough the hypervisor via `br0` when the floating IPs are selected.

 - If a guest is launched with the NAT option, `virbr0` (192.168.122.1) will be used to route out.

 - The Chef-Server container will be accessible from the hypervisor via: HTTPS://$CHEF_SERVER_CONTAINER_NAME:$CHEF_PORT.

### KVM Requirements

The hypervisor should have `Virtual Technology` enabled. You can test this prior the installation by running:
```bash
    cbuisson@server:~$ egrep -c '(vmx|svm)' /proc/cpuinfo
    #Anything but 0 is good.
```
And after the installation:
```bash
    cbuisson@server:~$ kvm-ok
    INFO: /dev/kvm exists
    KVM acceleration can be used
```

## Project: *docker-control*

You can manage Docker containers and images with this project.
