#!/bin/sh

# Set the working directory to this folder
cd `pwd -P`

# Start OrientDB
/home/rasmus/bin/orientdb-community-2.0.1/bin/server.sh

# Run tests
dart runner.dart
