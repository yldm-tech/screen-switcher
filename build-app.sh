#!/bin/sh
set -eu
cd "$(dirname "$0")"
exec sh apps/macos/build-app.sh
