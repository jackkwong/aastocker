symbol=$1
url="http://www.aastocks.com/en/stocks/analysis/company-fundamental/financial-ratios?symbol=$symbol"
page="`curl -sL "$url" | hxnormalize -x -e`"
tag="`echo "$page" | grep 'Return on Equity (%)' -B 2 | grep 'ref=' | sed -E 's/.*ref="([^"]*)".*/\1/' `"
echo "tag: $tag"

values="`echo "$page" | hxselect -s '\n' "tr[ref=$tag] td.cfvalue" | sed -E 's/<[^\>]*>//g'`"

echo "last 5 historical ROE:"
echo "$values" | paste -s -

formula="(`echo "$values" | paste -sd+ -`)/5"
echo "5-years average ROE:"
echo "scale=4; ($formula)" | bc
