NR > 1 { gender[$1] += $3; class[$2] += $3 }

END {
    for (i in gender) print i, gender[i]
    print ""
    for (i in class) print i, class[i]
}