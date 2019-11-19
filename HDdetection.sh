#!/bin/bash
#检查硬盘健康状态的函数，主要检查C5和C7两个值
Diskcheck(){
	disknum=$1 #接收参数决定需要检查的磁盘的盘符
	echo "Check $disknum"

	IFS=" " read -r -a C5info <<< "$(smartctl -a /dev/$disknum | grep Current_Pending_Sector)"
  IFS=" " read -r -a C7info <<< "$(smartctl -a /dev/$disknum | grep UDMA_CRC_Error_Count)" #通过smartctl 获取需要检测的两个参数的值，放入数组
  echo "The Value of C5 is ${C5info[9]}"
	echo "The Value of C7 is ${C7info[9]}"	
	if  [[ "${C5info[9]}" -gt "0"  ||  "${C7info[9]}" -gt "0" ]]; then #判断两个值是否为零，不为零即硬盘可能有问题，提示重启检查
	        echo -e "\033[31m Your HardDisk has some problem, Please reboot and checkout \033[0m"
	        read -p "Press [Enter] key to restart..."
	        echo "reboot"
		      reboot
	else
	  echo -e "\033[31m Hard disk no exception,Continue \033[0m "
	fi
}

disktype=$(cat /sys/block/sda/queue/rotational) #判断sda的盘是机械还是固态，机械数值应为1
if [[ "$disktype" -eq "1" ]]; then #若数值为1说明第一个盘为机械或nvme固态，即检测sda的盘即可
	echo "The First  Disk is HDD or Nvme"
	Diskcheck sda
	sleep 5
else
	echo "The First  Disk is SATA ssd" #否则则是sata接口的固态，即检测sdb的盘
	Diskcheck sdb
	sleep 5
fi












