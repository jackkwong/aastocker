#!/bin/bash

library="`cat <<-JQ_LIBRARY
def hasRegularDividend:
    .
    | map( 
        select(
            ."派息內容"
            | test("股息[:：]", "x")
        )
        | {
            "year": ( ."年度/截至" | strptime("%Y/%m")? | .[0] ), 
            "dividend_content": ."派息內容"
        }
        | select( (.year | isnan | not) and .year >= 2007 and .year <= 2016 )
    )
    | group_by(.year)
    | length
    | . >= 9
;
JQ_LIBRARY
`"

filter="`cat <<-JQ_FILTER
$library

map(
    select( .dividend_history | hasRegularDividend )
    | {
        "stock_code": .stock_code,
        "name": .basic_information."公司名稱"
    }
)
| sort_by(.stock_code | tonumber) 
| map("\(.stock_code) - \(.name)") 
| .[]
JQ_FILTER
`"

cat main_board/tc/*.json | jq -s -r "$filter"