#! /bin/sh

### get ansible script from master

echo "\n==="
echo "=== INIT_SLAVE: Downloading ansible folder"
echo "===\n"

wget -nH --cut-dirs=2 -P /tmp/ansible -r --no-parent --reject="index.html*" http://192.168.1.1:8000/atboot/ansible/

### do ansible stuff

echo "\n==="
echo "=== INIT_SLAVE: Performing ansible"
echo "===\n"

ansible-playbook /tmp/ansible/playbook_slave.yml

echo "\n==="
echo "=== INIT_SLAVE: Done"
