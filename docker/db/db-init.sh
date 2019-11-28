#!/bin/sh

create_standalone_databases() {
    echo "Initializing databases..."
    for db in _users _replicator _global_changes; do
        local query=("curl" "--request" "PUT" "http://127.0.0.1:${COUCHDB_PORT_NUMBER:-5984}/${db}")
        if [ -n "${COUCHDB_USER}" ] && [ -n "${COUCHDB_PASSWORD}" ]; then
            query+=("--user" "${COUCHDB_USER}:${COUCHDB_PASSWORD}")
        fi
        echo "Creating database '${db}'"
        echo "${query[@]}"
        "${query[@]}"
    done
}

wait_couchdb_start() {
    for port in 5984 6984 9100; do
        timeout 15 bash -c \
        "until echo > /dev/tcp/localhost/${port}; do
            sleep 0.5;
        done"
    done
}

wait_couchdb_stop() {
    for port in 5984 6984 9100; do
        timeout 15 bash -c \
        "until ! echo > /dev/tcp/localhost/${port}; do
            sleep 0.5;
        done"
    done
}

start_couchdb_bg() {
        echo "Starting CouchDB..."
        /opt/couchdb/bin/couchdb &
}

stop_couchdb() {
    echo "Stopping CouchDB..."
    pkill --full --signal TERM "/opt/couchdb"
}

initialize_couchdb_database() {
    # start_couchdb_bg
    wait_couchdb_start
    create_standalone_databases
    # stop_couchdb
    # wait_couchdb_stop
}

CONTAINER_CONFIGURED="/opt/couchdb/etc/local.d/.CONTAINER_COUCHDB_CONFIGURED"
if [ ! -e $CONTAINER_CONFIGURED ]; then
    initialize_couchdb_database
    touch $CONTAINER_CONFIGURED
fi
