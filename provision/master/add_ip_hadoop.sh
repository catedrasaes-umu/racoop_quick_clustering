#! /bin/sh

if [ $# -ne 1 ]
then
        echo "\n===\n=== ERROR. Usage: sudo <./add_ip_hadoop.sh <ip> \n===\n"
        exit
fi

echo "\n===\n=== Adding IP to filter rules\n===\n"

sudo iptables -t nat -A PREROUTING -s $1 -p tcp --dport 54310 -j DNAT --to-destination 192.168.1.1:54310
sudo iptables -t nat -A POSTROUTING -j MASQUERADE

