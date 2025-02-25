# データプロセッシング
## コンマ付き数字
```
$ awk -f addcomma
0
0                            0.00
-1
-1                          -1.00
.1
.1                           0.10
-12.34
-12.34                     -12.34
-12.345
-12.345                    -12.35
12345
12345                   12,345.00
-1234567.89
-1234567.89         -1,234,567.89
-123.
-123.                     -123.00
-123456
-123456               -123,456.00
7777777777
7777777777       7,777,777,777.00
^C
$
```
## 固定長データ
固定長データを扱うにはsubstrがベストだ。  
ファイルネームの開始位置を得るのにindexを使用している。
```
$ ls -l
合計 68
-rw-r--r-- 1 saku saku 35149  7月  4  2024 LICENSE
-rw-r--r-- 1 saku saku   162 11月 11 20:43 README.md
drwxr-xr-x 2 saku saku  4096  2月 24 19:42 ch.2
drwxr-xr-x 2 saku saku  4096  1月 20 13:24 ch.3
drwxr-xr-x 2 saku saku  4096  1月 20 19:16 ch.4
drwxr-xr-x 2 saku saku  4096  7月 21  2024 ch.5
drwxr-xr-x 2 saku saku  4096 10月  7 17:34 ch.6
drwxr-xr-x 2 saku saku  4096 10月 22 14:39 ch.7
drwxr-xr-x 2 saku saku  4096  7月  4  2024 ch.8
$ ls -l | awk '{print substr($0, index($0, $9))}'
合計 68
LICENSE
README.md
ch.2
ch.3
ch.4
ch.5
ch.6
ch.7
ch.8
$
```