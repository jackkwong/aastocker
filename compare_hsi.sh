for i in `cat hsi.txt`
do
    ticker="`echo $i | sed 's/\..*//'`" 
    echo "##### $i #####"
    ./get_stock_info_from_aastock.sh "$ticker" | grep "Return on Equity" -A2
    echo "##############"
    echo
done