#!/bin/bash

set -x
set -e

echo "Start SSH agent"
eval `ssh-agent`

echo "Add key to agent"
ssh-add - <<< $DWH_SFTP_PRIVATE_KEY

echo "Started with table list: $DWH_TABLES"

for table in $DWH_TABLES
do
    echo "Export table: $table"
    psql -c "\\copy (select * from $table) to '/tmp/$table.csv' csv header"
    ls -larth /tmp/$table.csv

    scp /tmp/$table.csv $DWH_USERNAME@$DWH_HOSTNAME:/$table.csv
done

