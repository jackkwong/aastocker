function getNormalizedHTML {
    local url="$1"
    local html="`curl -sL "$url" | hxnormalize -x -e 2>/dev/null`"
    echo "$html"
}

function getUrlCompanyProfile {
    local symbol="$1"
    local language="${2:-en}"
    local url="http://www.aastocks.com/$language/stocks/analysis/company-fundamental/company-profile?symbol=$symbol"
    echo "$url"
}

function getUrlCompanyInformation {
    local symbol="$1"
    local language="${2:-en}"
    local url="http://www.aastocks.com/$language/stocks/analysis/company-fundamental/company-information?symbol=$symbol"
    echo "$url"
}

function getUrlBasicInformation {
    local symbol="$1"
    local language="${2:-en}"
    local url="http://www.aastocks.com/$language/stocks/analysis/company-fundamental/basic-information?symbol=$symbol"
    echo "$url"
}

function getUrlEarningSummary {
    local symbol="$1"
    local language="${2:-en}"
    local url="http://www.aastocks.com/$language/stocks/analysis/company-fundamental/earnings-summary?symbol=$symbol"
    echo "$url"
}

function getBasicInformation {
    local symbol="$1"
    local language="${2:-en}"
    local url="`getUrlBasicInformation "$1" "$2"`"
    local html="`getNormalizedHTML "$url"`"
    echo "$html" | node read_basic_info.js
}

function getEarningSummary {
    local symbol="$1"
    local language="${2:-en}"
    local url="`getUrlEarningSummary "$1" "$2"`"
    local html="`getNormalizedHTML "$url"`"
    echo "$html" | node read_financial_ratio.js
}

function getUrlFinancialRatio {
    local symbol="$1"
    local language="${2:-en}"
    local url="http://www.aastocks.com/$language/stocks/analysis/company-fundamental/financial-ratios?symbol=$symbol"
    echo "$url"
}

function getFinancialRatio {
    local symbol="$1"
    local language="${2:-en}"
    local url="`getUrlFinancialRatio "$1" "$2"`"
    local html="`getNormalizedHTML "$url"`"
    echo "$html" | node read_financial_ratio.js
}

function getUrlProfitLoss {
    local symbol="$1"
    local language="${2:-en}"
    local url="http://www.aastocks.com/$language/stocks/analysis/company-fundamental/profit-loss?symbol=$symbol"
    echo "$url"
}

function getProfitLoss {
    local symbol="$1"
    local language="${2:-en}"
    local url="`getUrlProfitLoss "$1" "$2"`"
    local html="`getNormalizedHTML "$url"`"
    echo "$html" | node read_financial_ratio.js
}

function getUrlCashFlow {
    local symbol="$1"
    local language="${2:-en}"
    local url="http://www.aastocks.com/$language/stocks/analysis/company-fundamental/cash-flow?symbol=$symbol"
    echo "$url"
}

function getCashFlow {
    local symbol="$1"
    local language="${2:-en}"
    local url="`getUrlCashFlow "$1" "$2"`"
    local html="`getNormalizedHTML "$url"`"
    echo "$html" | node read_financial_ratio.js
}

function getUrlBalanceSheet {
    local symbol="$1"
    local language="${2:-en}"
    local url="http://www.aastocks.com/$language/stocks/analysis/company-fundamental/balance-sheet?symbol=$symbol"
    echo "$url"
}

function getBalanceSheet {
    local symbol="$1"
    local language="${2:-en}"
    local url="`getUrlBalanceSheet "$1" "$2"`"
    local html="`getNormalizedHTML "$url"`"
    echo "$html" | node read_financial_ratio.js
}

function getUrlEarningsSummary {
    local symbol="$1"
    local language="${2:-en}"
    local url="http://www.aastocks.com/$language/stocks/analysis/company-fundamental/earnings-summary?symbol=$symbol"
    echo "$url"
}

function getUrlDividendHistory {
    local symbol="$1"
    local language="${2:-en}"
    local url="http://www.aastocks.com/$language/stocks/analysis/company-fundamental/dividend-history?symbol=$symbol"
    echo "$url"
}

function getDividendHistory {
    local symbol="$1"
    local language="${2:-en}"
    local url="`getUrlDividendHistory "$1" "$2"`"
    local html="`getNormalizedHTML "$url"`"
    echo "$html" | node read_dividend_history.js
}

function getUrlSecuritiesBuyback {
    local symbol="$1"
    local language="${2:-en}"
    local url="http://www.aastocks.com/$language/stocks/analysis/company-fundamental/securities-buyback?symbol=$symbol"
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
    local tag="`inferCSSTagForField "$fieldName" "$html"`"
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

function reportField {
    local fieldName="$1"
    local html="$2"
    local values="`getFiveYearsFiguresForField "$fieldName" "$html" 2>/dev/null`"

    echo "last 5 historical $fieldName:"
    echo "$values" | paste -s -

    echo "5-years arithmetic mean of $fieldName:"
    arithmeticMean "$values" 2>/dev/null
    echo
}
