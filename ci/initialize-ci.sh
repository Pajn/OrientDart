#!/bin/bash

PARENT_DIR=$(dirname $(cd "$(dirname "$0")"; pwd))

ODB_VERSION=${1:-"2.0.1"}
ODB_EDITION="orientdb-community-${ODB_VERSION}"
ODB_URL="http://www.orientechnologies.com/download.php?email=unknown@unknown.com&file=${ODB_EDITION}.tar.gz&os=linux"
ODB_LAUNCHER="${ODB_EDITION}/bin/server.sh"

cd "$PARENT_DIR"

if [ ! -d "ODB_EDITION" ]; then
  # Download and extract OrientDB server
  echo "--- Downloading OrientDB v${ODB_VERSION} ---"
  wget $ODB_URL -O "${ODB_EDITION}.tar.gz"
  tar -xvzf "${ODB_EDITION}.tar.gz"

  # Ensure that launcher script is executable and copy configurations file
  echo "--- Setting up OrientDB ---"
  chmod +x $ODB_LAUNCHER
  chmod -R +rw "${ODB_EDITION}/config/"
else
  echo "!!! Found OrientDB v${ODB_VERSION} in ${ODB_EDITION} !!!"
fi

cp $PARENT_DIR/ci/orientdb-server-config.xml "${ODB_EDITION}/config/"

# Start OrientDB in background.
echo "--- Starting an instance of OrientDB ---"
sh -c $ODB_LAUNCHER </dev/null &>/dev/null &

# Wait a bit for OrientDB to finish the initialization phase.
sleep 7
printf "\n=== The CI environment has been initialized ===\n"
