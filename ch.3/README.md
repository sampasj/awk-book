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
## passengers.csv 書籍によるとWikipediaのデータと機械学習で使われるデータをマージしたと書かれているが、再現不能なので以下のデータを使用
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
## passengers.csv 作成
```
$ awk --csv 'BEGIN{ OFS = "\t" }NR > 1 {print NR - 1, $1, $2, $3, $5, $11, $14, $10, $8, $12, $4}' titanic3.csv | awk -F"\t" '@include "rec_to_csv"; {print(rec_to_csv())}' | sed '1i"row.names","pclass","survived","name","age","embarked","home.dest","room","ticket","boat","sex"' > passengers.csv
$
```
## How many infants were there? 乳児（生まれて一年未満の子）は何人いたか。年齢（age）データが欠けているものがあるので除外する
```
$ awk --csv 'NR > 1 { OFS="\t"; print $2, $3, $4, $5, $11 }' passengers.csv | awk -F"\t" '$4 != "" && $4 < 1'
1       1       Allison, Master. Hudson Trevor  0.92    male
2       1       Caldwell, Master. Alden Gates   0.83    male
2       1       Hamalainen, Master. Viljo       0.67    male
2       1       Richards, Master. George Sibley 0.83    male
2       1       West, Miss. Barbara J   0.92    female
3       1       Aks, Master. Philip Frank       0.83    male
3       1       Baclini, Miss. Eugenie  0.75    female
3       1       Baclini, Miss. Helene Barbara   0.75    female
3       0       Danbom, Master. Gilbert Sigvard Emanuel 0.33    male
3       1       Dean, Miss. Elizabeth Gladys "Millvina" 0.17    female
3       0       Peacock, Master. Alfred Edward  0.75    male
3       1       Thomas, Master. Assad Alexander 0.42    male
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
## MPFR(-Mオプション bignum)を有効にしてmakeするには以下の手順
```
sudo apt install build-essential libgmp-dev libmpfr-dev libmpc-dev
cd gawk-5.3.1/
./configure --with-mpfr
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
"This is consistent with the personal preferences of at least one of the authors."  
「これは、少なくとも著者の一人[^1]の個人的な好みと一致している。」
[^1]: カーニハンに決まっている
## データのグループ化
### 男性乗客，女性乗客の人数は何人か？
```
$ awk --csv '{g[$11]++} END{for (i in g) print i, g[i]}' passengers.csv
male 843
female 466
sex 1
$
```
### どんな年齢の乗客が何人いたか？
```
$ awk --csv '{g[$5]++}END{for (i in g) print i, g[i]}' passengers.csv | sort -n
age 1
0.17 1
0.33 1
0.42 1
0.67 1
0.75 3
0.83 3
0.92 2
1 10
2 12
3 7
4 10
5 5
6 6
7 4
8 6
9 10
10 4
11 4
11.5 1
12 3
13 5
14 8
14.5 2
15 6
16 19
17 20
18 39
18.5 3
19 29
20 23
20.5 1
21 41
22 43
22.5 1
23 26
23.5 1
24 47
24.5 1
25 34
26 30
26.5 1
27 30
28 32
28.5 3
29 30
30 40
30.5 2
31 23
32 24
32.5 4
33 21
34 16
34.5 2
35 23
36 31
36.5 2
37 9
38 14
38.5 1
39 20
40 18
40.5 3
41 11
42 18
43 9
44 10
45 21
45.5 2
46 6
47 14
48 14
49 9
50 15
51 8
52 6
53 4
54 10
55 8
55.5 1
56 4
57 5
58 6
59 3
60 7
60.5 1
61 5
62 5
63 4
64 5
65 3
66 1
67 1
70 2
70.5 1
71 2
74 1
76 1
80 1
 263
$
```
この年齢データチェックにより1309人の乗客データのうち263件が年齢データがないと分かった。書籍では258人の年齢データがないと記述されている。ことごとく微妙に違っている。
### 年齢チェックの人数確認。（本項オリジナル）
```
$ awk --csv '{g[$5]++}END{for (i in g) print i, g[i]}' passengers.csv | sort -n | awk -F"[ \t]" '{s += $2}END{print s}'
1310
$
```

```
$ awk --csv '{split($4, name, " "); print name[2]}' passengers.csv | sort | uniq -c | sort -nr
    736 Mr.
    256 Miss.
    191 Mrs.
     59 Master.
      8 y
      8 Rev.
      8 Dr.
      4 Planke,
      4 Col.
      3 Impe,
      3 Billiard,
      2 Ms.
      2 Mlle.
      2 Messemaeker,
      2 Major.
      2 Gordon,
      2 Carlo,
      1 the
      1 der
      1 Walle,
      1 Velde,
      1 Steen,
      1 Shawah,
      1 Pelsmaeker,
      1 Palmquist,
      1 Mulder,
      1 Mme.
      1 Melkebeke,
      1 Khalil,
      1 Jonkheer.
      1 Don.
      1 Cruyssen,
      1 Capt.
      1 Brito,
      1
$
```
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
DELL XPS 13 のWSL2(Ubuntu 22.04 LTS)で61秒かかった。書籍では2015年製 MacBook Air でGawkで実行した場合72秒と書かれている。XPS 13 のCPUはインテル第6世代 ノートPC向け Core i7 である。2015年12月5日購入。  
書籍と出力結果が違っている。MacとUbuntuでsortコマンドの仕様が違うためか？  
文字種が195個というのは一致している。
再頻出の文字は書籍では空白文字(SPACE)と書いてあるが、SPACEは10586176個、「,」は19094985個、「e」が12308925個でSPACEは3番目ではないか？  
```
$ ./charfreq-kai reviews.csv
19094985        ,
12308925        e
10586176
8311408 r
7269630 4
7014111 a
6993858 5
5988147 n
5919067 i
5759828 1
5665754 3
5336105 o
5040101 .
4985347 l
--- (中略) ---
1       Þ
1       葉
1       須
1       山
1       賀
1       横
1       ル
1       サ
1       ケ
1       ア
1       ー
1       ^
1       ‏
1       «
1       ²
1       »
$
```