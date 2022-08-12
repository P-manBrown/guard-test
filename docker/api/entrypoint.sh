#!/bin/bash

set -e

rm -f /myapp-backend/tmp/pids/server.pid

exec "$@"
