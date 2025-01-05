# csv を生成する

rec_to_csv 関数テスト
```
$ seq 12 | xargs -n 3 | awk '@include "rec_to_csv"; {print(rec_to_csv())}'
"1","2","3"
"4","5","6"
"7","8","9"
"10","11","12"
```

# タイタニック号の沈没
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
## データセット

参考「Titanic：タイタニック号乗客者の生存状況（年齢や性別などの13項目）の表形式データセット」  
https://atmarkit.itmedia.co.jp/ait/articles/2007/02/news016.html
```
titanic3.csv
各属性（列項目）の意味は以下のようになっている。

pclass： 旅客クラス（1＝1等、2＝2等、3＝3等）。裕福さの目安となる
name： 乗客の名前
sex： 性別（male＝男性、female＝女性）
age： 年齢。一部の乳児は小数値
sibsp： タイタニック号に同乗している兄弟（Siblings）や配偶者（Spouses）の数
parch： タイタニック号に同乗している親（Parents）や子供（Children）の数
ticket： チケット番号
fare： 旅客運賃
cabin： 客室番号
embarked： 出港地（C＝Cherbourg：シェルブール、Q＝Queenstown：クイーンズタウン、S＝Southampton：サウサンプトン）
boat： 救命ボート番号
body： 遺体収容時の識別番号
home.dest： 自宅または目的地
survived：生存状況（0＝死亡、1＝生存）。通常はこの数値が目的変数として使われる
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
2015年12月5日購入  
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
高アルコールと低アルコールにはどのような評価があるのか？
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

## Unicode データ
### charfreq Unicode文字の出現数を数えるAwkプログラム
```
$ ./charfreq reviews.csv
,       19094985
e       12308925
r       8311408
4       7269630
a       7014111
5       6993858
n       5988147
i       5919067
1       5759828
3       5665754
o       5336105
.       5040101
l       4985347
....(中略)......
Â       1
Þ       1
葉      1
須      1
山      1
賀      1
横      1
ル      1
サ      1
ケ      1
ア      1
ー      1
^       1
«       1
²       1
»       1
        1
        10586176
$
```
DELL XPS 13 のWSL2(Ubuntu 22.04 LTS)で61秒かかった。書籍では2015年製 MacBook Air で250秒と書かれているのでそれよりはずっと速い。XPS 13 のCPUはインテル第6世代 ノートPC向け Core i7 である。2015年12月5日購入。  
書籍と出力結果が違っている。MacとUbuntuでsortコマンドの仕様が違うためか？  
文字種が195個というのは一致している。
再頻出の文字は書籍では空白文字(SPACE)と書いてあるが、SPACEは10586176個、「,」は19094985個、「e」が12308925個でSPACEは3番目ではないか？