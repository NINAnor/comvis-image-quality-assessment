#!/bin/bash

# Bash configuration
set -Eeuo pipefail
shopt -s globstar nullglob

# Global options
DIR="$1"
shift

# Prepare data
for file in "$DIR"/**/*.JPG
do
    jpegoptim --strip-all "$file"
    new_path="$(dirname "$file")/$(xxd -p -l 16 /dev/random).JPG"
    mv "$file" "$new_path"
done

# Compute values
echo -e 'size\tlaplacian_variance\tpath'
for file in "$DIR"/**/*.JPG
do
    {
    du -b "$file" | awk '{ print $1 }'
    python3 process.py `# -t 300` -i "$file" "$@" |&
        sed -n 's/.*score: \([0-9]\+\.[0-9]\+\) .*/\1/p'
    echo -n "$file"
    } | tr '\n' $'\t'
    echo
done
