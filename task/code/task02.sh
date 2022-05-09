#!/usr/bin/env bash

function help {

echo "-h    打开帮助文档"
echo "-s    统计不同年龄区间范围"
echo "-p    统计不同场上位置的球员数量、百分比"
echo "-n    查看名字最长和最短的球员名字"
echo "-a    查看年龄最大和最小的球员名字"
echo "-w    下载相应数据文件"
}

#使用wget将数据文件下载到当前目录
function download {
wget "https://c4pr1c3.github.io/LinuxSysAdmin/exp/chap0x04/worldcupplayerinfo.tsv"
}

#统计不同年龄区间范围（20岁以下、[20-30]、30岁以上）的球员数量、百分比
function Sort_age {
    #各个阶段的数量初始值赋值为0
awk -F "\t" '
    BEGIN{lowage=0; midage=0; highage=0;}
    $6!="Age"{
        if($6>=0&&$6<20) {lowage++;}
        else if($6>30) {highage++;}
        else if($6<=30){midage++;}
        }

    END{sum=lowage+midage+highage;
    printf "%-20s%-10s%-10s\n","Range","count","percentage";
    printf "%-18s%-11s%-.1f\%\n","20岁以下",lowage,lowage*100.0/sum;
    printf "%-21s%-10s%-.1f\%\n","[20-30]",midage,midage*100.0/sum;
    printf "%-18s%-10s%-.1f\%\n","30岁以上",highage,highage*100.0/sum;
    }' worldcupplayerinfo.tsv
}
# 统计不同场上位置的球员数量、百分比
#统计所有位置，故可以用循环写
function Record_location {
awk '
    BEGIN{FS="\t";sum=0}
    $5!="Position"{
        num[$5]++;
        sum ++;
     }
     END{
    printf "%-20s%-10s%-10s\n","position","count","percentage";
        for( i in num ){
        printf "%-20s%-10s%-.1f\%\n",i,num[i],num[i]*100.0/sum;}
     }' worldcupplayerinfo.tsv
}

#名字最长的球员是谁？名字最短的球员是谁？
#可能要注意的地方就在于有并列的情况，此时要一并打印出
#取出球员名字的长度，再将该球员和名字长度联系起来

function record_name {

awk '
    BEGIN {FS="\t";maxname=0;minname=1000}
    $9!="Player"{
        len=length($9)
        name[$9]=len;
        if (len>maxname) {maxname=len}
        if(len<minname) {minname=len}
        }
    END {
    printf ("名字最长,长度为 %s 的球员名字如下:\n" ,maxname);
    for (i in name)
    {
    if (name[i]==maxname) {printf "%s\t",i} 
    }
    printf("\n");
    printf ("名字最短,长度为 %s 的球员名字如下:\n" ,minname);
    for (j in name)  
    {
    if (name[j]==minname) {printf( "%s\t",j)}
    }
    printf("\n");
    }' worldcupplayerinfo.tsv
}

#年龄最大的球员是谁？年龄最小的球员是谁？
#这道题与上一道题做法极其类似
function Record_age {

awk  '
    BEGIN {FS="\t";maxage=0;minage=1000}
    $6!="Age"{
        playerage=$6;
        name[$9]=playerage;
        if(playerage>maxage) {maxage=playerage}
        if(playerage<minage) {minage=playerage}
    }
    END {
        printf ("年龄最大,年龄为 %s 的球员名字如下:\n" ,maxage);
    for (i in name)
    {
    if (name[i]==maxage) {printf "%s\t",i} 
    }
    printf("\n");
    printf ("年龄最小,年龄为 %s 的球员名字如下:\n" ,minage);
    for (j in name)  
    {
    if (name[j]==minage) {printf( "%s\t",j)}
    }
    printf("\n");
    }' worldcupplayerinfo.tsv

}

while [ "$1" != "" ] ; do
    case "$1" in 
        "-h")
        echo "======打开帮助文档====="
        help
        exit 0
        ;;
      
        "-s")
        echo "======统计不同年龄区间范围====="
        Sort_age
        exit 0
        ;;

        "-p")
        echo "======统计不同场上位置的球员数量、百分比====="
        Record_location
        exit 0
        ;;

        "-n")
        echo "======查看名字最长和最短的球员名字====="
        record_name
        exit 0
        ;;

        "-a")
        echo "=====查看年龄最大和最小的球员名字======"
        Record_age
        exit 0
        ;;

        "-w")
        echo "=====下载相关数据文件======"
        download
        exit 0
        ;;
    esac
done
