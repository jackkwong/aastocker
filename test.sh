#!/bin/bash

library="`cat <<-'JQ_LIBRARY'

def get_cash_dividend_history:
    . as $dividend_history
    | $dividend_history
    | map(select(."方式" == "現金"))
    | group_by(."年度/截至")
    | sort_by(.[0]."年度/截至")
    | reverse
    | {
        date: map( (.[0]."年度/截至") ),
        dividend: map(. | map(."派息內容" | capture("港元 *(?<V>[0-9.]+)").V | tonumber) | add | .*100000 + 0.5 | floor | ./100000 )
    }
;

JQ_LIBRARY
`"

filter="`cat <<-JQ_FILTER
$library

.dividend_history | get_cash_dividend_history
JQ_FILTER
`"
cat main_board/tc/900.json | jq -r "$filter"
