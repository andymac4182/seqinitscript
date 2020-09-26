#!/bin/bash

if [[ $ACCEPT_EULA != Y && ( $ACCEPT_EULA != y ) && ( -z ${1+x} || "$1" == "run" ) ]]; then
    echo "The Seq End User License Agreement must be accepted in order to use this Docker image."
    exit 1;
fi

# Exit if any command fails
set -e
set -o pipefail

# Default arguments to those passed to the container
args=$@
storage_arg="--storage=/data"

# If there aren't any arguments, then default to `run`
if [ -z ${1+x} ]; then
    args="run $storage_arg"
fi

# For anything except 'version', 'config hash' and 'help' commands, add an implicit 'storage' if missing
if [ "$1" != "version" ] && [ "$1" != "help" ] && [ "$1 $2" != "config hash" ]; then
    has_storage=0
    for arg in "$@"
    do
        if [[ "$arg" =~ ^--storage=.* ]]; then
            has_storage=1
            storage_arg=$arg
        fi
    done

    if [ "$has_storage" = "0" ]; then
        args="$args $storage_arg"
    fi
fi

/bin/seq-server/Seq config $storage_arg --create -k diagnostics.internalLogPath -v /data/Logs
/bin/seq-server/Seq config $storage_arg -k api.listenUris -v http://localhost:80,http://localhost:5341
/bin/seq-server/Seq config $storage_arg -k api.ingestionPort -v 5341

if [ $BASE_URI ]; then
    /bin/seq-server/Seq config $storage_arg -k api.canonicalUri -v $BASE_URI
fi

RUST_BACKTRACE=1

if [ ! -z "$INITFILE" ] && [ -f "$INITFILE" ]; then 
    echo "$INITFILE exists. Starting init process"
    /init-runner.sh &
fi

exec /bin/seq-server/Seq $args
