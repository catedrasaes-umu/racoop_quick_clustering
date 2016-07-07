#! /bin/sh

### BEGIN INIT INFO
# Provides:          get_init_slave
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop:     $network $local_fs $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: This is executed at slave boot
# Description:       This is a boot script.
#                    It gets init_slave script and executes it.
### END INIT INFO

FILE="init_slave.sh"
URI="http://192.168.1.1:8000/atboot/slave/$FILE"
OUTPUT="/tmp/$FILE"
LOGFILE="/tmp/get_init_slave.sh.log"

rm -f $LOGFILE

echo "\n===\n=== GET_INIT_SLAVE: Getting atboot slave configuration\n===\n" >> $LOGFILE 2>&1

wget -N -O $OUTPUT $URI >> $LOGFILE 2>&1

echo "\n===\n=== GET_INIT_SLAVE: Executing init_slave script\n===\n" >> $LOGFILE 2>&1

. $OUTPUT >> $LOGFILE 2>&1

echo "\n===\n=== GET_INIT_SLAVE: Done \n===\n" >> $LOGFILE 2>&1

exit 0
