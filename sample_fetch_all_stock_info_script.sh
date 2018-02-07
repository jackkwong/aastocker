#!/bin/bash
mkdir -p company_data
cat hsi.txt | sed 's/\..*//' | parallel 'i="{}"; echo "fetching $i..." >&2; ./aastock.sh $i tc > company_data/"$i.json"'
