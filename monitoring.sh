#!bin/bash
arch=$(uname -a)
physical_processor=$(grep "physical id" /proc/cpuinfo | wc -l)
virtual_processor=$(grep "processor" /proc/cpuinfo | wc -l)
memory_used=$(free -mt | awk 'FNR == 2 {print $3}')
total_memory=$(free -mt | awk 'FNR == 2 {print $2}')
memory_pct=$(free -mt | awk -v OFMT=%.2f 'FNR == 2 {print $3/$2*100}')
disk_used=$(df --total | awk -v OFMT=%.0f 'END {print $3/1024}')
disk_available=$(df -h --total | awk 'END {print $4}')
disk_pct=$(df -h --total | awk 'END {print $5}')
cpu_utilize=$(mpstat | awk -v OFMT=%.1f 'END {print 100-$NF}')
last_boot=$(who -b | awk '{print substr($0, index($0, $3))}')
lvm_check=$(lvscan -v | grep -v 'ACTIVE' | wc -l)
if !($lvm_check == 0)
then
  lvm_status="yes"
else
  lvm_status="no"
fi
active_tcp=$(ss -s | grep 'TCP' | grep 'estab' | awk -F, '{print $1}' | awk '{print $4}')
unique_user=$(who | cut -d " " -f 1 | sort -u | wc -l)
ipv4=$(hostname -I)
MAC=$(ip link show | awk '$1 == "link/ether" {print $2}')
commands_wsudo=$(cat /var/log/sudo/sudo.log | grep 'TSID' | wc -l)

wall "
#Architecture   : "$arch"
#CPU physical   : "$physical_processor"
#vCPU           : "$virtual_processor"
#Memory Usage   : "$memory_used/$total_memory MB" "\($memory_pct\)%"
#Disk Usage     : "$disk_used/$disk_available" "\($disk_pct\)"
#CPU load       : "$cpu_utilize%"
#Last boot      : "$last_boot"
#LVM use        : "$lvm_status"
#Connections TCP: "$active_tcp ESTABLISHED"
#User log       : "$unique_user"
#Network        : "IP $ipv4" "\($MAC\)"
#Sudo           : "$commands_wsudo cmd"
"
