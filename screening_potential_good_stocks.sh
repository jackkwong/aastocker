#!/bin/bash

library="`cat <<-'JQ_LIBRARY'

def percentile(n):
    . as $array
    | ((length - 1) * n / 100) as $middle_index
    | ($middle_index | floor) as $floor_middle_index
    | if ($middle_index == $floor_middle_index)
        then
            $array[$middle_index]
        else
            ($array[$floor_middle_index] + $array[$floor_middle_index+1])/2
    end
;

def dividend_years_between(from; to):
    . as $dividend_history
    | $dividend_history
    | map( 
        select(
            ."派息內容"
            | test("股息[:：]", "x")
        )
        | {
            "year": ( ."年度/截至" | strptime("%Y/%m")? | .[0] ), 
            "dividend_content": ."派息內容"
        }
        | select( (.year | isnan | not) and .year >= from and .year <= to )
    )
    | group_by(.year)
;

def has_at_least_n_dividends(numberOfDividendYear; from; to):
    . as $dividend_history
    | $dividend_history
    | dividend_years_between(from; to)
    | length
    | . >= numberOfDividendYear
;

def get_cash_dividend_history:
    . as $dividend_history
    | $dividend_history
    | map(select(."方式" == "現金"))
    | group_by(."年度/截至")
    | sort_by(.[0]."年度/截至")
    | reverse
    | {
        date: map( (.[0]."年度/截至") ),
        dividend: map(. | map(."派息內容" | capture("港元[ \n]*(?<V>[0-9.]+)").V | tonumber) | add | if . == null then null else (.*100000 + 0.5 | floor | ./100000) end )
    }
;
JQ_LIBRARY
`"

filter="`cat <<-'JQ_FILTER'
map(
    select( .dividend_history | has_at_least_n_dividends(9; 2008; 2017) )
        | select(
            .financial_ratio."股東權益回報率(%)"
            | map(. | tonumber?)?
            | (add / length)
            | . > 10
        )
        | select((.basic_information."市盈率(倍)" | tonumber?) <= 20)
        | select((.basic_information."市盈率(倍)" | tonumber?) > 0)
        | select((.basic_information."股價/每股淨資產值(倍)" | tonumber?) <= 4)
        | select((.basic_information."周息率(%)") >= 6)
)
| sort_by((.basic_information."周息率(%)") | tonumber | -1 * .)
| map(
. as $stock
| ( (.basic_information."股價/每股淨資產值(倍)" | tonumber?) * (.basic_information."每股淨資產值(港元)" | tonumber?) | (.*100000 + 0.5 | floor | ./100000) ) as $deduced_p
| (.dividend_history | get_cash_dividend_history) as $cash_dividend_history
| "
\(.stock_code) - \(.basic_information."公司名稱")
========================================================================================================================================================================================================

    Quick-Check
    ________________________________________________________________________________
    上市日期:                              \(."basic_information"."上市日期")
    1st recorded dividend date (AAStock):  \($cash_dividend_history | .date | last)

    3-years min yield:                     \($cash_dividend_history | .dividend | .[0:3] | min / $deduced_p * 100) %
    5-years min yield:                     \($cash_dividend_history | .dividend | .[0:5] | min / $deduced_p * 100) %

    3-years equity per share change:       \(.earning_summary."每股賬面資產淨值" | map(tonumber) | .[(length-3):] | ((last - first) / first * 100)) %
    5-years equity per share change:       \(.earning_summary."每股賬面資產淨值" | map(tonumber) | .[(length-5):] | ((last - first) / first * 100)) %


    Price-related
    ________________________________________________________________________________
    deduced P:             \($deduced_p)
    PE:                    \(.basic_information."市盈率(倍)")
    PB:                    \(.basic_information."股價/每股淨資產值(倍)")
    Yield:                 \(.basic_information."周息率(%)")

    Basic
    ________________________________________________________________________________
    Date:                  \($cash_dividend_history | .date | .[0:6] | reverse | join(" -> "))
    Dividend:              \($cash_dividend_history | .dividend | map(tostring?) | .[0:6] | reverse | join(" -> "))

    Date:                  \( (.financial_ratio."截止日期" // [] | join(" -> ")) )
    Current Ratio:         \( (.financial_ratio."流動比率(倍)" // [] | join(" -> ")) )
    Quick Ratio:           \( (.financial_ratio."速動比率(倍)" // [] | join(" -> ")) )

    Long-term Debit/Equity:\( (.financial_ratio."長期債項/股東權益(%)" // [] | join(" -> ")) )
    Debt/Equity:           \( (.financial_ratio."總債項/股東權益(%)" // [] | join(" -> ")) )
    Debt/Capital Employ:   \( (.financial_ratio."總債項/資本運用(%)" // [] | join(" -> ")) )

    ROE:                   \( (.financial_ratio."股東權益回報率(%)" // [] | join(" -> ")) )
    ROCE:                  \( (.financial_ratio."資本運用回報率(%)" // [] | join(" -> ")) )
    ROA:                   \( (.financial_ratio."總資產回報率(%)" // [] | join(" -> ")) )

    經營利潤率(%):         \( (.financial_ratio."經營利潤率(%)" // [] | join(" -> ")) )
    稅前利潤率(%):         \( (.financial_ratio."稅前利潤率(%)" // [] | join(" -> ")) )
    邊際利潤率(%):         \( (.financial_ratio."邊際利潤率(%)" // [] | join(" -> ")) )

    存貨周轉率(倍):        \( (.financial_ratio."存貨周轉率(倍)" // [] | join(" -> ")) )

    Unit Stock
    ________________________________________________________________________________
    Date:                  \( (.earning_summary."截止日期" // [] | join(" -> ")) )
    EPS:                   \( (.earning_summary."每股盈利" // [] | join(" -> ")) )
    EPS change (%):        \( (.earning_summary."每股盈利增長(%)" // [] | join(" -> ")) )
    Equity Per Share:      \( (.earning_summary."每股賬面資產淨值" // [] | join(" -> ")) )
    Dividend Per Share:    \( (.earning_summary."每股派息" // [] | join(" -> ")) )
    Dividend Rate (%):     \( (.earning_summary."派息比率(%)" // [] | join(" -> ")) )
    Currency:              \( (.earning_summary."基準貨幣" // [] | join(" -> ")) )
    Currency Exhange Rate: \( (.earning_summary."兌換比率" // [] | join(" -> ")) )

    Details
    ________________________________________________________________________________
    Date:                  \($cash_dividend_history | .date | join(" <- "))
    Dividend:              \($cash_dividend_history | .dividend | map(tostring?) | join(" <- "))
") 
| .[]
JQ_FILTER
`"

jq_script="`cat <<-JQ_SCRIPT
$library
$filter
JQ_SCRIPT
`"

#filter2="`cat <<-JQ_FILTER
#$library
#map(
#    select( .dividend_history | has_at_least_n_dividends(9; 2007; 2016) )
#        | select((.financial_ratio."流動比率(倍)" | last | tonumber?) >= 1)
#        | select((.financial_ratio."速動比率(倍)" | last | tonumber?) >= 1)
#    | .financial_ratio."股東權益回報率(%)"
#    | map(. | tonumber?)?
#    | (add / length)
#)
#| sort
#| {p10:percentile(10), p25: percentile(25), p50: percentile(50), p75:percentile(75), p90: percentile(90)}
#JQ_FILTER
#`"

#cat main_board/tc/*.json | jq -s -r "$filter2"

cat main_board/tc/*.json | jq -s -r "$jq_script"