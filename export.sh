#!/bin/bash

# ssh-add - <<< $DWH_SFTP_PRIVATE_KEY

echo "Started with table list: $DWH_TABLES"

for table in $DWH_TABLES
do
    echo "Export table: $table"
    psql -c "\\copy $table to '/tmp/$table.csv' csv header"
    ls -larth /tmp/$table.csv
done

