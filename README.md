# quick_cluster


# Installation guide

## Master node configuration

### Install Ubuntu (including graphical mode) over RAID 1

**(If you decide to install a different Ubuntu distribution, just go to next step.)**

We assume two identical hard disks (/dev/sd[ab]) which will be used completely for our new install. 
To simplify recovery if one drive fails, there will be only one mdadm-volume /dev/md0 which will then be partitioned for /, swap and data storage, e.g. /home.
After booting up the live-cd and (if necessary) configuring network access, open up a terminal and assume root access sudo -s

    apt-get install mdadm


Now we create a single primary partition each of /dev/sda and /dev/sdb from sector 2048 to the end of the disk, for example using sudo fdisk. I also like to already set the partition type to fd for linux raid autodetection. The keystroke-sequence in fdisk (if the disk is empty in the beginning, meaning no partitions) is `n <return> p <return> 1 <return> 2048 <return> <return> t <return> fd <return> w <return>`.

Now we create the mdadm volume:

    mdadm --create /dev/md0 --bitmap=internal --level=1 -n 2 /dev/sd[ab]1


I noticed, that the ubiquity installer also does not quite manage to create partitions inside this /dev/md0, so I also did this by hand - again using fdisk. So on /dev/md0 create the following partitions:
 - `/dev/md0p1` for your root filesystem, the size of course depending upon how much software you are going to install.
 - `/dev/md0p2` for swap, the size of course also depending on what you use the machine for and how much ram it's got
 - `/dev/md0p3` for /home, all the space that's left

After that we can begin the Installation. Make sure to start the installer from the terminal with the -b option, because installing the bootloader will fail anyway:

    ubiquity -b


Make sure to go for manual partitioning and "use" the 3 partitions you just created and tick the format checkbox for `/` and `/home` so a filesystem will be created. After the installation the system is not yet bootable, so do not restart the box right away. We need to chroot into the installed system and fixup some stuff:

    sudo -s
    mount /dev/md0p1 /mnt
    mount -o bind /dev /mnt/dev
    mount -o bind /dev/pts /mnt/dev/pts
    mount -o bind /sys /mnt/sys
    mount -o bind /proc /mnt/proc
    cat /etc/resolv.conf >> /mnt/etc/resolv.conf
    chroot /mnt
    apt-get install mdadm
    nano /etc/grub.d/10_linux  # change quick_boot to 0
    grub-install /dev/sda
    grub-install /dev/sdb
    update-grub
    exit


### Enable root user

    sudo passwd root

Please, don't log as root user after doing this.


### Clone this Git repo

    sudo apt-get install git -y
    git clone https://github.com/catedrasaes-umu/quick_cluster.git


### Do `preprovision`

1. Locate this script: `$/configuration/provision/master/prepovision_master.sh`

2. Execute it as sudo:


    sudo ./prepovision_master.sh <host_name> 
    (e.g., use cluster0 as host name)


3. Generate public key:

    ssh-keygen -t rsa
    (Press `Return` 3 times)


4. Configure vars files. Before the Ansible provision can start some variables must be defined. These variables may be found on the `provision/ansible/vars` folder and they are:

  - In vars_common.yml:

    user: The user name to be used in the cluster. It will be the same for the master and the slave nodes.
    master_hostname: The hostname for the master node. It is suggested to be named as "cluster0", so the slave nodes may be named as "cluster1..X".
    master_ip: The ip used by the master to connect to the slaves.

  - In vars_master.yml:

    mac_eth0: The physical MAC address of the interface to be renamed to eth0.
    mac_eth1: The physical MAC address of the interface to be renamed to eth1.
    modprobe_eth0: The module name of the interface to be renamed to eth0. Obtainable with the command dmesg | grep 'interfaceName'.
    modprobe_eth1: The module name of the interface to be renamed to eth1. Obtainable with the command dmesg | grep 'interfaceName'.
    cluster_repository: The path to the cluster git repository.
    nagios_admin_user: The admin user to be used in the Nagios installation.
    nagios_admin_pass: The admin user password to be used in the Nagios installation.
    nagios_admin_email: An admin email to be notified when an alert comes up in Nagios.
    

### Do Ansible `provision`

1. Launch the ansible playbook located at `/tmp/provision/ansible/`:


    cd ~/provision/ansible/
    ansible-playbook playbook_master.yml -K

2. When finished, reboot.


## Slave node configuration

### Install Ubuntu (including graphical mode) over RAID 1

**(If you decide to install a different Ubuntu distribution, just go to next step.)**

Same as in the Master case, we assume two identical hard disks (/dev/sd[ab]) which will be used completely for our new install. For the partitioning and RAID1 details please refer to the beginning of the previous section.

### Do `preprovision`

1. Copy or download the `$/configuration/provision/slave/prepovision_slave.sh` script.

2. Execute it as sudo:


    sudo ./prepovision_slave.sh <host_name> 
    (e.g., use cluster1..X as hostname)

3. Once it finishes, there should be a `/tmp/provision/` folder. Check the vars folder just to make sure everything is ok in `provision/ansible/vars`

4. Execute the slave playbook inside the `/tmp/provision` folder.

    cd /tmp/provision/ansible/
    ansible-playbook playbook_slave.yml -K

5. When finished, check if there is script in `/etc/init.d/get_init_slave.sh`.

6. Reboot the slave machine.

## Signup script.