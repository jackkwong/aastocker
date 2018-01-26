function getNormalizedHTML {
    local url="$1"
    local html="`curl -sL "$url" | hxnormalize -x -e 2>/dev/null`"
    echo "$html"
}

function getUrlFinancialRatio {
    local symbol="$1"
    local url="http://www.aastocks.com/en/stocks/analysis/company-fundamental/financial-ratios?symbol=$symbol"
    echo "$url"
}

function inferCSSTagForField {
    local fieldName="$1"
    local html="$2"
    local tag="`echo "$html" | grep "$fieldName" -B 2 | grep 'ref=' | sed -E 's/.*ref="([^"]*)".*/\1/' `"
    echo "$tag"
}

function getFiveYearsFiguresForField {
    local fieldName="$1"
    local html="$2"
    local tag="`inferCSSTagForField 'Return on Equity (%)' "$html"`"
    echo "inferred CSS tag: \"$tag\"" >&2

    local values="`echo "$html" | hxselect -s '\n' "tr[ref=$tag] td.cfvalue" | sed -E 's/<[^\>]*>//g'`"
    echo "$values"
}

function arithmeticMean {
    local numbers="$1"
    local n="`echo "$numbers" | wc -l | sed 's/[ 	\s]//g'`"
    local formula="(`echo "$numbers" | paste -sd+ -`) / $n"
    echo "$formula" >&2
    echo "scale=4; ($formula)" | bc
}
