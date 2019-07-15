#!/bin/bash
#说明：这个脚本用于将Windows下编写文档中的图片路径与Mac兼容
# 我的Windows路径定义为 D:\龙盘虎踞\Typora\typora-pic\，执行脚本之后路径将会转换为 /D:/龙盘虎踞/Typora/typora-pic/ ，从而兼容Mac端。
#有如下注意事项：
#	1，使用方法是 bash change_dir.sh dirname 然后就会自动替换目录下的图片路径了。
#	2，要注意，上边的dirname下的文件名称，不要有空格，否则将不会处理，且可能出现意外情况。
#	3，要注意，dirname下不要包含图片，否则脚本可能会将图片打成乱码。
#	4，日常编写完文档，可以直接运行命令进行更替，重复执行不会有影响。
#	5，操作之前，一定一定要先备份自己原来的数据，然后经过调试测试之后再对正式的目录进行操作。

#定义一个操作函数
function read_dir(){
for file in `ls $1`
do
    if [ -d $1"/"$file ];then
        read_dir $1"/"$file
    else
        echo $1"/"$file
        while true
        do
            grep "(D:" $1"/"$file &> /dev/null
            if [ $? != 0 ];then
                echo "此文件没有需要变更路径的图片，故而跳过"
                break
            else
			    sed -i 's/(D:\\龙盘虎踞\\Typora\\typora-pic\\/(\/D:\/龙盘虎踞\/Typora\/typora-pic\//g' $1"/"$file
                break
            fi
        done
    fi
done
}

#后边跟随目录参数
read_dir $1