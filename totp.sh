#!/bin/bash

# Exit immediately if any command fails or any variable is undefined
set -euo pipefail

# 1. Parse the JSON query passed from Terraform's stdin
# Since 'jq' might not be installed on a bare runner, we use a lightweight built-in grep/sed pattern
# to pull the exact contents of the "secret_base64" string.
INPUT_JSON=$(cat)
B64_INPUT=$(echo "$INPUT_JSON" | grep -o '"secret_base64":"[^"]*' | grep -o '[^"]*$')

# 2. Decode the Base64 input string to raw binary bytes, then re-encode using the Linux 'base32' CLI tool.
# We pipe through 'tr' to delete any '=' padding characters as required by TOTP authenticator apps.
BASE32_OUTPUT=$(echo -n "$B64_INPUT" | base64 -d | base32 | tr -d '=')

# 3. Print a single-level valid JSON string to stdout to pass back to Terraform
echo "{\"base32\":\"$BASE32_OUTPUT\",\"base64\":\"$B64_INPUT\"}"
