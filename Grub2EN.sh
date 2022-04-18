#!/bin/bash

cat <<EOF
=========================================
本脚本只支持Centos7 or Centos8的grub2加密

加密脚本由white出品，感谢使用！！！
=========================================
EOF

#read username
read -p"Enter user name:" username
#read password
read -s -p"Enter user password:" password
echo -e "\n"
#免交互，并提取出加密字符串
string=`echo -e "${password}\n${password}\n" | grub2-mkpasswd-pbkdf2 | grep grub.pbkdf2 | awk '{print $7}'`

#判断是否存在指定字符
grep 'password_pbkdf2' /etc/grub.d/00_header > /dev/null
if [ 0 -eq `echo $?` ];then
	echo "00_header文件存在旧的加密信息，正在删除……"
	for i in `seq 4`;do 
	sed -i '$d' /etc/grub.d/00_header
	done
	echo "原加密信息成功！"
fi

#字符拼接,并将字符串追加到/etc/grub.d/00_header末尾
echo -e "cat <<EOF\nset superusers='${username}'\npassword_pbkdf2 ${username} ${string}\nEOF" >> /etc/grub.d/00_header

#更新grub信息
grub2-mkconfig -o /boot/grub2/grub.cfg >& /dev/null

#判断是否成功更新
if [ 0 -eq `echo $?` ];then
	echo "grub.cfg信息更新成功！"
else
	echo "grub.cfg信息更新失败！"
fi
#重启系统
read -p "是否重启系统?: y/n " an
if [ "y" == "$an" ] || [ "yes" == "$an" ];then
	/usr/sbin/reboot
fi
