# quick_cluster


# Installation guide

## Master node configuration

### Install Ubuntu (including graphical mode) over RAID 1

**(If you decide to install a different Ubuntu distribution, just go to next step.)**

(Ubuntu 16.04 is not supported yet by Ansible. Remove this when it will.)

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

### Manage keys and clone this Git repo

Generate public key:

    ssh-keygen -t rsa
    (Press `Return` 3 times)

Copy your id in the machine holding the repo:

    ssh-copy-id <git-user>@<git-host>

Clone the repo:

    sudo apt-get install git -y
    git clone https://github.com/catedrasaes-umu/quick_cluster.git

### Execute `preprovision` script

1. Locate this script: `$nosql/cluster/configuration/provision/master/prepovision_master.sh`
2. Execute it as sudo:


    ./prepovision_master.sh <host_name> 
    (e.g., use cluster0 as host name)

### Execute Ansible `provision` script
  
1. Editar $nosql/cluster/configuration/provision/ansible/vars/vars_common.yml y configurar el valor correcto de las siguientes variables:


    master_hostname: 'cluster0' (Master host name)
    master_user: 'master' (Master user)
    master_ip: '192.168.1.1' (Master host IP)

  
2. Editar $nosql/cluster/configuration/provision/ansible/vars/vars_master.yml y configurar el valor correcto de las siguientes variables:


    mac_eth0: '00:80:5a:60:d1:aa' (Physical MAC address)
    mac_eth1: 'b8:ac:6f:20:13:1e' (Physical MAC address)
    modprobe_eth0: '8139too' (Modprobe)
    modprobe_eth1: 'tg3' (Modprobe)
    cluster_repository: '{{ansible_env.HOME}}/nosql/cluster' (Path to cluster configuration repository)


3. Lanzar el playbook ansible localizado en /tmp/provision/ansible/


    cd ~/nosql/cluster/provision/ansible/
    ansible-playbook playbook_master.yml -K

4. Reboot.
