symbol=$1
source lib.sh
url="`getUrlFinancialRatio "$symbol"`"
echo "URL: \"$url\"" >&2
html="`getNormalizedHTML "$url"`"
values="`getFiveYearsFiguresForField 'Return on Equity (%)' "$html"`"

echo "last 5 historical ROE:"
echo "$values" | paste -s -

formula="(`echo "$values" | paste -sd+ -`)/5"
echo "5-years average ROE:"
echo "scale=4; ($formula)" | bc
