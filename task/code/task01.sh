#!/usr/bin/env bash

#帮助文档
function help {

        echo "-h 打开此帮助文档 "
        echo "-R p1 对jpeg格式图片进行p相应的图片质量压缩,如p1为50"
        echo "-r p2 对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩p2相应的分辨率,如p2为50%"
        echo "-a size text 对图片批量添加自定义文本内容为text的字体大小为size水印"
        echo "-add_1 pretext 不影响原始文件扩展名的前提下，统一添加文件名前缀"
        echo "-add_2 suftext 不影响原始文件扩展名的前提下，统一添加文件名后缀"
        echo "-c 将png/svg图片统一转换为jpg格式图片"
}
      
#对jpeg格式图片进行p1相应的图片质量压缩
function quality_compression {

p1=$1

for img in *.jpeg #选中所有jpeg文件
do
convert "${img}" -quality "${p1}" "qc-${img}"
echo "${img}已经完成质量压缩。"
done
}

#对jpeg/png/svg格式图片在保持原始宽高比的前提下压缩p2相应的分辨率
function compression_resolution {

p2=$2

for img in  *.jpg  *.jpeg *.svg;
do
convert "${img}" -resize "${p2}" "cr-${img}"
echo "${img}压缩成功!"
done
}

#对图片批量添加自定义文本水印
function add_watermark {

size=$1

text=$2

for img in *.jpg *.jpeg *.png *.svg;#这里直接把图片和脚本放在一起了，故不能直接使用*
do
convert "${img}" -pointsize "${size}" -fill red -gravity center -draw "text 10,10 '${text}'" "ad-${img}"
echo "${img}添加水印成功!"
done
}

#不影响原始文件扩展名的前提下，统一添加文件名前缀
function add_pretext {

pretext=$1

for img in *.jpg *.jpeg *.png *.svg;
do 
mv "${img}" "$1""${img}"
echo "${img}被命名为${pretext}${img}"
done
}

#不影响原始文件扩展名的前提下，统一添加文件名后缀
function add_suftext {

suftext=$1

for img in *.jpg *.jpeg *.png *.svg;
do 
typename="${img##*.}"
filename="${img%.*}${suftext}"".""${typename}"
mv "${img}" "${filename}"
echo "${img}被命名为${filename}"
done
}

#将png/svg图片统一转换为jpg格式图片
function change_type {

for img in *.png *.svg ;
do
filename="${img%.*}"".""jpg"
convert "${img}" "${filename}"
echo "${img}被成功转化为${filename}"
done
}

while [ "$1" != "" ] ;do 
case "$1" in
        "-h")
        echo "=====打开帮助文档!====="
        help
        exit 0
        ;;

         "-R")
        echo "=====图片质量压缩！====="
        quality_compression "$2"
        exit 0
        ;;

         "-r")
         echo "=====压缩至相应的分辨率！====="
        compression_resolution "$2"
        exit 0
        ;;

         "-a")
        echo "=====添加文本水印！====="
        add_watermark "$2" "$3"
        exit 0
        ;;

         "-add_1")
        echo "=====加前缀名！====="
        add_pretext "$2"
        exit 0
        ;;

         "-add_2")
        echo "=====加后缀名！====="
        add_suftext "$2"
        exit 0
        ;;
         "-c")
        
        echo "=====修改至jpg类型!====="
        change_type
        exit 0
        ;;
    esac
    done