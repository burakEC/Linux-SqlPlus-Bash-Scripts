#!/bin/bash

for year in `seq 2017 2017`
do
  for month in `seq 1 3`
  do
    CURMTH=$month
    CURYR=$year

    #PRVMTH=`expr $CURMTH - 1`
    PRVMTH=$CURMTH
    PRVYR=$CURYR

    if [ $PRVMTH -lt 10 ]
    then PRVMTH="0"$PRVMTH
    fi

    LASTDY=`cal $PRVMTH $PRVYR | egrep "28|29|30|31" |tail -1 |awk '{print $NF}'`

    STRT_DATE=`echo 01-$PRVMTH-$PRVYR`
    END_DATE=`echo $LASTDY-$PRVMTH-$PRVYR`

    startdate=$(awk -F[-] '{print $3$2$1}' <<< $STRT_DATE)
    enddate=$(awk -F[-] '{print $3$2$1}' <<< $END_DATE)

    startdate=$(date -d "$startdate" +'%Y%m%d')
    enddate=$(date -d "$enddate" +'%Y%m%d')

    #echo $startdate
    #echo $enddate

    p2="$startdate"

    until [ "$p2" -eq "$enddate" ]; do
      diff=$(($enddate-$p2))
      if [ $diff -lt 7 ]; then
       x=$diff
      else
       x=7
      fi
      #p1=$(($p2+1))
      p1=$p2
      p2=$(date -d "$p2 + $x day" +'%Y%m%d')
      p2_p=$(date -d "$p2" +'%d%m%Y')
      p1_p=$(date -d "$p1" +'%d%m%Y')
      echo exit | sqlplus MUSD/A14EDf3Qwfd1s@IWIN_CDR_REPORTING @test.sql thy"$p1_p""_""$p2_p" $p1_p $p2_p
      #echo $p1_p" "$p2_p
    done

  done
done
