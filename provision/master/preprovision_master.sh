#! /bin/sh

if [ $# -ne 1 ]
then
        echo "\n===\n=== ERROR. Usage: sudo <./preprovision_master> <clusterN> \n===\n"
        exit
fi

echo "\n===\n=== MASTER BASICS: Configuring network \n===\n"

sudo echo "$1" > /etc/hostname
sudo hostname $1

### install ansible

printf "\n===\n=== BASICS: Installing ansible \n===\n"

sudo apt-get -y update
sudo apt-get -y install ssh software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible
sudo apt-get -y update
sudo apt-get -y install ansible

printf "\n(1/2)\n===\n=== Please, configure manually the file ../provision/ansible/vars/vars_common.yml before proceeding and press ENTER \n===\n"
read -n 1 -s

printf "\n(2/2)\n===\n=== Please, configure manually the file ../provision/ansible/vars/vars_master.yml before proceeding and press ENTER \n===\n"
read -n 1 -s
