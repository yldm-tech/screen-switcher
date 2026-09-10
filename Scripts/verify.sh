#!/bin/sh
set -eu
cd "$(dirname "$0")/.."
sh apps/macos/Scripts/verify.sh
npm run check --workspace @screen-switcher/web
npm run build --workspace @screen-switcher/web
