#!/bin/bash
# JRiDEoS Studio builder wrapper — run from repo root.
# Usage: ./build-studio.sh
set -euo pipefail
cd "$(dirname "$0")/studio"
exec bash build.sh "$@"
