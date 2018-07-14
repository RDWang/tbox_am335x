#!/bin/sh 
#编译xmake和tbox的脚本文件

#定义全局变量
#定义xmake位置
XMAKE_CMD="../host/bin/xmake"
#工具链位置
SDK_PATH="/disk230/cpb_devkit/linux-devkit/sysroots/i686-arago-linux/usr"
#工具链前缀：
CROSS_COMPILE="arm-linux-gnueabihf-"

#编译xmake工具
if test -e "./host";then
    sudo rm -fr ./host
fi
mkdir host
cd xmake

#如果不是root用户，需要使用在命令前加sudo
sudo sh install ../host

cd ../ 

#交叉编译tbox库，本脚本编译AM335X平台
if test -e "./target_arm/";then
    rm -fr ./target_arm
fi
mkdir target_arm
cd tbox
$XMAKE_CMD  clean
$XMAKE_CMD  config -c
$XMAKE_CMD config -k shared --sqlite3=SQLITE3 --sdk=$SDK_PATH --cross=$CROSS_COMPILE
$XMAKE_CMD 

#处理交叉编译后的库文件
${SDK_PATH}/bin/${CROSS_COMPILE}strip build/release/none/demo
#${SDK_PATH}/bin/${CROSS_COMPILE}strip build/release/none/libtbox.a
cp -fr build/release/none/demo ../target_arm/
cp -fr build/release/none/libtbox.a ../target_arm/
cp -fr build/tbox ../target_arm/

cd ../ 

#增加使用tbox库的测试程序
cd example
${SDK_PATH}/bin/${CROSS_COMPILE}gcc -o test test.c  -I../target_arm -lpthread -lm -L../target_arm -ltbox
