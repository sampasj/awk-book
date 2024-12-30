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

Dell XPS 13  
CPU: Core i7-6500U  @2.50GHz 2Core 4threds  
メモリ: 8GB  
SSD: Samsung 980 1TB  
Windows 11 24H2  
WSL2 Ubuntu 22.04 LTS  
```
$ time wc reviews.csv
  1586615  12170544 180174429 reviews.csv

real    0m1.292s
user    0m1.190s
sys     0m0.098s
$
```
```
$ time awk '{ nc += length($0) +1; nw += NF }
> END{ print NR, nw, nc, FILENAME }' reviews.csv
1586615 12170527 179963813 reviews.csv

real    0m3.413s
user    0m1.497s
sys     0m1.916s
$

```
## gawk 最新のインストール 2024.12.25現在  
--csv オプションを使用できるバージョンにするため
```
https://ftp.jaist.ac.jp/pub/GNU/gawk/

tar xvf gawk-5.3.1.tar.gz
cd gawk-5.3.1/
./configure
make
sudo make install
```
## 5項目抽出　タブ区切りに変換
```
$ awk --csv 'BEGIN{OFS="\t"}{print $2, $4, $8, $11, $12}' reviews.csv > rev.tsv
```
### レビューデータの中のアルコール度数が最大のビール
```
$ awk -F"\t" 'NR > 1 && $5 > maxabv { maxabv = $5; brewery = $1; name = $4 }END { print maxabv, brewery, name }' rev.tsv
57.7 Schorschbräu Schorschbräu Schorschbock 57%
$
```
### ABVが10%以上のレビュー数
```
$ awk -F"\t" '$5 >= 10 { print $1, $4, $5 }' rev.tsv | wc -l
194359
$
```
### ABVが0.5%以下のレビュー数
```
$ awk -F"\t" '$5 != "" && $5 <= 0.5 { print $1, $4, $5 }' rev.tsv | wc -l
1023
$
```
What ratings are associated with high and low alcohol?
```
$ awk -F"\t" '$5 >= 10 {rate += $2; nrate++ }END{print rate/nrate, nrate}' rev.tsv
3.93702 194359
$ awk -F"\t" '$5 != "" && $5 <= 0.5 {rate += $2; nrate++ }END{print rate/nrate, nrate}' rev.tsv
2.58895 1023
$ awk -F"\t" '{rate += $2; nrate++ }END{print rate/nrate, nrate}' rev.tsv
3.81558 1586615
$
```
アルコール度数が高いビールの点数は、全体の平均点より高い。  
This is consistent with the personal preferences of at least one of the authors.  
これは、少なくとも著者の一人[^1]の個人的な好みと一致している。

[^1]: カーニハンに決まっている