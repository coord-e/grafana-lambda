#!/bin/sh

set -eu

exports=$(mktemp)
chmod 600 "$exports"

if [ -n "$X_EXPORT_FROM_SSM" ]; then
  echo "lambda_entrypoint.sh: X_EXPORT_FROM_SSM=$X_EXPORT_FROM_SSM"
  aws ssm get-parameters-by-path \
    --path "$X_EXPORT_FROM_SSM" \
    --with-decryption \
    --query 'Parameters[].[Name,Value]' \
    --output text | while IFS= read -r line
  do
    var=$(echo "$line" | cut -f1 | rev | cut -d/ -f1 | rev)
    value=$(echo "$line" | cut -f2)
    echo "lambda_entrypoint.sh: export $var"
    echo "export $var=$value" >> "$exports"
  done
fi

source "$exports"
exec /run.sh "$@"
