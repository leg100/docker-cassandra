#!/usr/bin/env bash

set -e

# Get running container's IP
IP=`hostname --ip-address`

# Use IP for self-seeding unless SEEDS already set
SEEDS=${SEEDS:-$IP}

# Set RPC to private address
sed -i -e "s/^rpc_address.*/rpc_address: $IP/" $CASSANDRA_CONFIG/cassandra.yaml

# Provide seeds
sed -i -e "s/- seeds: \"127.0.0.1\"/- seeds: \"$SEEDS\"/" $CASSANDRA_CONFIG/cassandra.yaml

# Listen on IP:port of the container
sed -i -e "s/^listen_address.*/listen_address: $IP/" $CASSANDRA_CONFIG/cassandra.yaml

# series of optimisations if not running a cluster
if [[ ! -z "$SINGLE_NODE" ]]; then
  # Disable virtual nodes
  sed -i -e "s/num_tokens/\#num_tokens/" $CASSANDRA_CONFIG/cassandra.yaml

  # With virtual nodes disabled, we need to manually specify the token
  echo "JVM_OPTS=\"\$JVM_OPTS -Dcassandra.initial_token=0\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

  # Pointless in one-node cluster, saves about 5 sec waiting time
  echo "JVM_OPTS=\"\$JVM_OPTS -Dcassandra.skip_wait_for_gossip_to_settle=0\"" >> $CASSANDRA_CONFIG/cassandra-env.sh
fi

# Most likely not needed
echo "JVM_OPTS=\"\$JVM_OPTS -Djava.rmi.server.hostname=$IP\"" >> $CASSANDRA_CONFIG/cassandra-env.sh

exec bin/cassandra -f
