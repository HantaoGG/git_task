#!/usr/bin/env bash 

function help {
    echo "-a  统计访问来源主机TOP 100和分别对应出现的总次数"
    echo "-b  统计访问来源主机TOP 100 IP和分别对应出现的总次数"
    echo "-c  统计最频繁被访问的URL TOP 100"
    echo "-d  统计不同响应状态码的出现次数和对应百分比"
    echo "-e  分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数"
    echo "-f yoururl 给定的url输出相应TOP 100访问来源主机"
    echo "-h  打开此帮助文档"
    echo "-w 下载并解压数据文件"
}

function download_unzip {
wget "https://c4pr1c3.github.io/LinuxSysAdmin/exp/chap0x04/web_log.tsv.7z"
7z x web_log.tsv.7z
}


# 统计访问来源主机TOP 100和分别对应出现的总次数
# NR>1表示从第二行开始，即可去掉表头
function record_100_host {
printf  "%-50s\t%-20s\n" "top100_host" "Count"
awk -F "\t" '
    
    NR>1 { host[$1]++;}
    END{ for (i in host) {
            printf  ("%-50s\t%-20d\n",i,host[i])
               }
    } ' web_log.tsv | sort -g -k 2 -r | head -100
}

# 统计访问来源主机TOP 100 IP和分别对应出现的总次数
# 这里用到了正则表达式对应的ip地址
function record_100_ip {
printf  "%-50s\t%-20s\n" "top100_ip" "Count"
awk -F "\t" '
    NR>1 {if(match($1,/^((2(5[0-5]|[0-4][0-9]))|[0-1]?[0-9]{1,2})(\.((2(5[0-5]|[0-4][0-9]))|[0-1]?[0-9]{1,2})){3}$/)) ipnum[$1] ++ ;}
    END {for (i in ipnum) {
        printf ("%-50s\t%-20d\n",i,ipnum[i])}

    }' web_log.tsv | sort -g -k 2 -r | head -100
}
# 统计最频繁被访问的URL TOP 100
function record_100_url {
printf "%-50s\t%-20s\n" "top100_url" "Count"
awk -F "\t" '
NR>1 {urlnum[$5]++;}
END {for (i in urlnum) {
    printf("%-50s\t%-20d\n",i,urlnum[i]);}
}' web_log.tsv | sort -g -k 2 -r | head -100
}

# 统计不同响应状态码的出现次数和对应百分比
function record_status {

printf "%-50s%-10s%-10s\n" "Range" "count" "percentage";
awk -F "\t" '
NR>1 {status[$6]++}
END {for (i in status) {
    printf  "%-50s%-10s%-.4f%%\n",i,status[i],status[i]*100.0/(NR-1);}
}' web_log.tsv | sort -g -k 2 -r | head -100
}

# 分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数
#由上一问我们知道4XX状态码只有404和403
#`sort -g -k 3 -r `这样就可以按照相关要求得到top表
function record_code {
printf "%-10s%-70s%-20s\n" "status" "top10_url" "count";
awk -F "\t" '
NR>1 {if($6=="404") code404[$5]++; }
END {for(i in code404)
{ printf ("%-10s%-70s%-20d\n","404",i,code404[i]);}
}' web_log.tsv | sort -g -k 3 -r | head -10

awk -F "\t" '
NR>1 {if($6=="403") code403[$5]++; }
END {for(j in code403)
{printf ("%-10s%-70s%-20d\n","403",j,code403[j])};
}' web_log.tsv | sort -g -k 3 -r | head -10
}

#给定URL输出TOP 100访问来源主机
function url_lead {
yoururl=$1
printf  "给定的url为%s\n\n" "${yoururl}"
printf "%-50s\t%-20s\n" "top100_host" "Count"
awk -F "\t" '
NR>1 {if($5=="'"${yoururl}"'") {hostnum[$1]++};}
END {for (i in hostnum)
    {printf ("%-50s\t%-20d\n",i,hostnum[i]);}
}' web_log.tsv | sort -g -k 2 -r | head -100
}

while [ "$1" != "" ];do 
    case "$1" in
        "-w")
        echo "下载并解压数据文件"
        download_unzip
        exit 0
        ;;

         "-a")
        echo "统计访问来源主机TOP 100和分别对应出现的总次数"
        record_100_host
        exit 0
        ;;

         "-b")
        echo "统计访问来源主机TOP 100 IP和分别对应出现的总次数"
        record_100_ip
        exit 0
        ;;

         "-c")
        echo "统计最频繁被访问的URL TOP 100"
        record_100_url
        exit 0
        ;;

         "-d")
        echo "统计不同响应状态码的出现次数和对应百分比"
        record_status
        exit 0
        ;;

         "-e")
        echo "分别统计不同4XX状态码对应的TOP 10 URL和对应出现的总次数"
        record_code
        exit 0
        ;;

         "-f")
        echo "给定URL输出TOP 100访问来源主机"
        url_lead "$2"
        exit 0
        ;;

         "-h")
        echo "打开帮助文档"
        help
        exit 0
        ;;

    esac
done


