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

function blur_detection() {
    python3 process.py "$@" |&
        sed -n -e 's/.*score_var: \([0-9]\+\)\.[0-9]\+ score_max: \([0-9]\+\)\.[0-9]\+.*/\1\n\2/p'
}

# Compute values
echo -e 'size\tvar_k1\tmax_k1\tvar_k3\tmax_k3\tvar_k5\tmax_k5\tpath'
for file in "$DIR"/**/*.JPG
do
    {
    du -b "$file" | awk '{ print $1 }'
    blur_detection -i "$file" -k 1
    blur_detection -i "$file" -k 3
    blur_detection -i "$file" -k 5
    echo -n "$file"
    } | tr '\n' $'\t'
    echo
done > results.tsv

# Generate Cryptpad form
items="$(tail -n+2 results.tsv |
    awk -F'\t' '{print $8}' |
    tr -d '\r' |
    cut -b7- |
    xargs -I% basename % |
    sort |
    while read filename
    do
        jq --null-input --arg v "$filename" --arg uid $(basename "$filename" .JPG) \
            '{v: $v, uid: $uid}'
    done | jq -sc)"
jq --argjson items "$items" '.form.scores.opts.items|=$items' form-template.json > form.json
