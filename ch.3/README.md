# csv を生成する

rec_to_csv 関数テスト
```
$ seq 12 | xargs -n 3 | awk '@include "rec_to_csv"; {print(rec_to_csv())}'
"1","2","3"
"4","5","6"
"7","8","9"
"10","11","12"
```

# タイタニック号
## データ整合性チェック
各レコードのフィールド数が5か？
トータル人数のチェック
```
$ awk 'NF != 5 || $3 != $4 + $5' titanic.tsv
Type    Class   Total   Lived   Died
$
```