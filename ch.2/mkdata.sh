#
# make date and dummy step count data
#

# 2022/1/1 - 2024/11/11
EPOC=1640995200
while [ "$EPOC" -le 1731319337 ]; do
  date -d "@$EPOC" +"%Y/%-m/%-d"
  EPOC=`expr $EPOC + 86400`
done | awk '{$2 = int( rand() * 20000 ) + 1000; print}'