#!/bin/bash
# JRiDEoS Studio-UI builder wrapper — run from repo root.
# Usage: ./build-studio-ui.sh
set -euo pipefail
cd "$(dirname "$0")/studio-ui"
exec bash build.sh "$@"
