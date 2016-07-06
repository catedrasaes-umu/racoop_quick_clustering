#! /bin/sh

if [ $# -ne 1 ]
then
	echo "\n===\n=== ERROR. Usage: sudo <./provision_slave> <clusterN> \n===\n"
	exit
fi

##
##
echo "\n===\n=== SLAVE BASICS: Configuring network \n===\n"

sudo echo "$1" > /etc/hostname

sudo hostname $1

MAC_ADDRESS=`sudo ifconfig | grep HW | awk '{print $5}'`
DRIVER_NAME=`sudo lshw -c network | grep driver= | awk '{print $4}' | cut -d "=" -f 2`

### Configuring network interfaces
sudo echo "# external interface
SUBSYSTEM==\"net\", ACTION==\"add\", ATTR{address}==\"$MAC_ADDRESS\", NAME=\"eth0\"" > /etc/udev/rules.d/10-my-network.rules

if ! grep -q "auto eth0" /etc/network/interfaces ;
then
   sudo echo "
auto eth0
iface eth0 inet dhcp" >> /etc/network/interfaces
fi

### Restarting networking service and Ethernet driver
sudo /etc/init.d/networking stop && sudo modprobe -r $DRIVER_NAME && sudo udevadm control --reload-rules && sudo udevadm trigger && sudo modprobe $DRIVER_NAME && sudo /etc/init.d/networking start

sudo dhclient eth0

##
##
echo "\n===\n=== SLAVE BASICS: Installing ansible \n===\n"

sudo apt-get -y update
sudo apt-get -y install software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get -y update
sudo apt-get -y install ansible

##
##
echo "\n===\n=== SLAVE BASICS: Downloading provision configuration files \n===\n" 

wget -nH --cut-dirs=1 --reject="index.html*" -P /tmp -r --no-parent http://192.168.1.1:8000/configuration/provision/ 

printf "\n(1/2)\n===\n=== Please, configure manually the file ../provision/ansible/vars/vars_common.yml before proceeding and press ENTER \n===\n"
read -n 1 -s
