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

## 連想配列( associative arrays )の例
```
$ awk -f array-sample1 titanic.tsv
Female 425
Child 109
Male 1690

Third 706
First 325
Crew 908
Second 285
$
```
# ビール評価
## オリジナルデータ
https://www.kaggle.com/datasets/rdoume/beerreviews

## DropBoxコピー
GitHubには100MB以上のファイルをアップロードできなかったのでDropBoxで共有した。

https://www.dropbox.com/scl/fi/3pjfqj1o6bon4m6ihyqy4/beer_reviews.csv?rlkey=vzhmtc9mw58tqtknr2j353ixn&st=f2pfxr3l&dl=0