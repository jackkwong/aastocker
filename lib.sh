function getNormalizedHTML {
    url="$1"
    html="`curl -sL "$url" | hxnormalize -x -e 2>/dev/null`"
    echo "$html"
}

function getUrlFinancialRatio {
    symbol="$1"
    url="http://www.aastocks.com/en/stocks/analysis/company-fundamental/financial-ratios?symbol=$symbol"
    echo "$url"
}

function inferCSSTagForField {
    fieldName="$1"
    html="$2"
    tag="`echo "$html" | grep "$fieldName" -B 2 | grep 'ref=' | sed -E 's/.*ref="([^"]*)".*/\1/' `"
    echo "$tag"
}

function getFiveYearsFiguresForField {
    fieldName="$1"
    html="$2"
    tag="`inferCSSTagForField 'Return on Equity (%)' "$html"`"
    echo "inferred CSS tag: \"$tag\"" >&2

    values="`echo "$html" | hxselect -s '\n' "tr[ref=$tag] td.cfvalue" | sed -E 's/<[^\>]*>//g'`"
    echo "$values"
}
