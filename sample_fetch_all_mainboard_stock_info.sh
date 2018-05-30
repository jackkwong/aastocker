cat main_board.txt | sed 's/\..*//' | parallel 'i="{}"; echo "fetching $i (TC)..." >&2; ./aastock.sh $i tc > main_board/tc/"$i.json"'
cat main_board.txt | sed 's/\..*//' | parallel 'i="{}"; echo "fetching $i (EN)..." >&2; ./aastock.sh $i en > main_board/en/"$i.json"'
