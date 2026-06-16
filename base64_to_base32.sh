#!/bin/bash

# Exit immediately if any command fails or any variable is undefined
set -euo pipefail

INPUT_JSON=$(cat)
INPUT=$(echo "$INPUT_JSON" | grep -o '"input":"[^"]*' | grep -o '[^"]*$')

OUTPUT=$(echo -n "$INPUT" | base64 -d | base32)

echo "{\"output\":\"$OUTPUT\"}"
