#!/bin/bash

ERRCODE=1
start_time="$(date -u +%s)"
end_time="$(date -u +%s)"

PATH=~/bin/seqcli:$PATH

seqcli config -k connection.serverUrl -v http://localhost/

echo "Monitoring for seq server coming online"

while [[ $ERRCODE -ne 0 ]]; do # || [[ $((end_time-start_time)) -lt 120 ]]
	seqcli signal list > /dev/null 2>&1
	ERRCODE=$?
	sleep 1
	end_time="$(date -u +%s)"
done

if [[ $DBSTATUS -ne 0 ]] || [[ $ERRCODE -ne 0 ]]; then
	echo "Seq Server took more than 60 seconds to start up or one or more databases are not in an ONLINE state"
	exit 1
fi

# Run the setup script to create the DB and the schema in the DB
$INITFILE

rm -f $INITFILE
