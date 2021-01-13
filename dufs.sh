#!/bin/sh
#  ------------------------------------------------------------------
subr1(){
    awk ' BEGIN { sump=0;shft=" " }
    { 
    if($2=="."){rec=NR;tot=$1;nm[NR]=dir;len1=length(dir) }
    else {sump+=$1;sub("./","",$2);nm[NR]=$2;if(length($2)>len2) len2=length($2)}
    vol[NR]=$1 
    }
    END { vol[rec]-=sump;sump=tot;
    lno=len1+len2
    fmt="%-" lno "s %9s  %s\n"
    #fmt0="%-" lno "s %9.1f %5.1f%\n"
    fmt0="%-" lno "s %9.1f %5.1f\n"
    #fmt1="%" len1 "s%-" len2 "s %9.1f %5.1f%\n"
    fmt1="%" len1 "s%-" len2 "s %9.1f %5.1f\n"
    unds="-"
    for(i=0;i<=lno+24;i++) unds=unds "-"
    print unds
    printf(fmt,"DIRNAME","MBYTES","%%%%%")
    print unds
    for(i=NR;i>0;i--) 
    { 
    nam=nm[i]; vlm=vol[i]; prc=100*vlm/sump
    prc1=prc+0;tprc+=prc1
    if(i==rec)
    printf(fmt0,nam,vlm/1024,prc)
    else if(prc1>0.1)
    printf(fmt1,shft,nam,vlm/1024,prc)
    } 
    print unds
    printf(fmt0,"TOTAL",sump/1024,tprc)
    }' dir=$wd
}

subr2(){
    \ls -al |grep -v ^l|grep -v ^d |awk '{s+=$5}
    END {printf("%.2f",s/1024)}'
}
#------------------------------------------------
tf1=/tmp/dust$$
tf2=/tmp/dus$$
if [ $# -ne 0 ]
then 
    cd $1     
fi

FSYS=$(df -P . | tail -1 | awk '{print $NF}')
wd=`pwd`
date
FAV=$(uname -s)

case $FAV in
    HP-UX) bdf $wd ;;
    Linux) df -kh $wd ;;
esac

if [ $wd != "/" ]
then
    wd=$wd"/"
fi
/bin/ls -al|grep -v .ckpt_| grep -v ^l |
awk '/^d/&&!/\.$/ {print $NF}'|while read dnm;do
    cd $dnm
    CFS=$(df -P . | tail -1 | awk '{print $NF}')
    cd $wd
    if [ X$CFS != X$FSYS ]
    then
        continue
    fi
    du -kxs $dnm
done | sort -n >$tf1

ttt=$(subr2)
awk '{s+=$1}
END {printf("%d .\n", s+ad)}' ad=$ttt $tf1 >> $tf1
cat $tf1 | subr1
rm $tf1 2>/dev/null

exit
