#!/bin/bash

# Wait 120 seconds for SQL Server to start up by ensuring that 
# calling SQLCMD does not return an error code, which will ensure that sqlcmd is accessible
# and that system and user databases return "0" which means all databases are in an "online" state
# https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-databases-transact-sql?view=sql-server-2017 

ERRCODE=1
start_time="$(date -u +%s)"
end_time="$(date -u +%s)"

/bin/seqcli/seqcli config -k connection.serverUrl -v http://localhost/

echo "Monitoring for seq server coming online"

while [[ $ERRCODE -ne 0 ]]; do # || [[ $((end_time-start_time)) -lt 120 ]]
	/bin/seqcli/seqcli signal list > /dev/null 2>&1
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
