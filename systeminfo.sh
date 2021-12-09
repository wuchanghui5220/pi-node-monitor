#!/bin/bash

# OS version
powershell.exe gwmi win32_OperatingSystem |awk '/Version/{print $3}'

# hostname
echo $HOSTNAME

# CPU percentage
powershell.exe wmic cpu get loadpercentage |head -2 |tail -1|awk '{print $1"%"}'

# Memory information
powershell.exe Get-WmiObject -Class win32_OperatingSystem  TotalVisibleMemorySize |awk '/TotalVisibleMemorySize/{print $3}' |sed 's/[ \t]*$//g' >totalmem
powershell.exe Get-WmiObject -Class win32_OperatingSystem  FreePhysicalMemory |awk '/FreePhysicalMemory/{print $3}' |sed 's/[ \t]*$//g' >freemem

# converse text format
dos2unix ./totalmem &>/dev/null
dos2unix ./freemem &>/dev/null

t_mem=`awk '{print $1}' ./totalmem`
f_mem=`awk '{print $1}' ./freemem`

tm=`echo "scale=0;$t_mem/1000/1024" |bc`
um=`echo "scale=2;($t_mem - $f_mem)/1000/1024" |bc`
ump=$(printf "%.2s" `echo "scale=2;$um/$tm*100" |bc`)
echo "$ump%"
echo $tm
echo $um
