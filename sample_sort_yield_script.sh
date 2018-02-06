#!/bin/bash
find company_data -name "*.json" | xargs cat | jq -s '[   .[] | {Name, Yield, PE, "Price/PNAV"}   ] | sort_by(.Yield | (tonumber? // -99999) | . * -1)'
