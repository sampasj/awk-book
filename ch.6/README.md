# The AWK Programming Language Second Edition 第6章 program

## main1
randint, randlet関数用メインプログラム
英小文字5文字をランダムに出力する

```
awk -f main1
etqbr
```

## shuffle
標準入力のデータをシャッフルする

```
seq 5 | awk -f shuffle
2
3
1
4
5
```
