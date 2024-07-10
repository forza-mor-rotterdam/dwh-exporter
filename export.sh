#!/bin/bash

set -x
set -e

echo "Load known hosts file"
mkdir -p /root/.ssh
echo $DWH_KNOWN_HOSTS > /root/.ssh/known_hosts
chmod -R u=rw,g=,o= /root/.ssh

echo "Start SSH agent"
eval `ssh-agent`
echo "SSH agented started with PID: $SSH_AGENT_PID"

echo "Add key to agent"
ssh-add - <<< $DWH_SFTP_PRIVATE_KEY

echo "Started with table list: $DWH_TABLES"

for table in $DWH_TABLES
do
    echo "Export table: $table"
    psql -c "\\copy (select * from $table) to '/tmp/$table.csv' csv header"
    ls -larth /tmp/$table.csv

    scp /tmp/$table.csv $DWH_USERNAME@$DWH_HOSTNAME:/$DWH_PREFIX.$table.csv
done

