#!/bin/bash

# 屏幕显示，运行环境检查
echo "运行环境检查："
# 运行环境检查函数

function env_check(){
        pi="Pi-Network"
        docker="Docker-Desktop"
        l_nmap="nmap"
        l_dos2unix="dos2unix"
        nginx="nginx"
        c_pi=`powershell.exe Get-Process "Pi*Network" |awk '/Pi/{print $8"-"$9}' |head -1`
        c_docker=`powershell.exe Get-Process "Docker*Desktop" |awk '/Docker/{print $8"-"$9}' |head -1`
        c_nmap=`dpkg -l |grep "nmap" |head -1 |awk '{print $2}'`
        c_dos2unix=`dpkg -l |grep "dos2unix" |head -1 |awk '{print $2}'`
        c_nginx=` docker ps |awk '/nginx/{print $2}'`

        echo -n "Docker Desktop:   "
        if [ "$c_docker" == "$docker" ];then
                echo -e "\033[1;32m[ OK ]\033[0m"
                echo "OK" >check_env.log
        else
                echo -e "\033[1;31m[ None ]\033[0m"
                echo "None" >check_env.log
        fi
        sleep 1
        echo -n "Pi Network Node:  "
        if [ "$c_pi" == "$pi" ];then
                echo -e "\033[1;32m[ OK ]\033[0m"
                echo "OK" >>check_env.log
        else
                echo -e "\033[1;31m[ None ]\033[0m"
                echo "None" >>check_env.log
        fi
        sleep 1
        echo -n "Linux nmap:       "
        if [ "$c_nmap" == "$l_nmap" ];then
                echo -e "\033[1;32m[ OK ]\033[0m"
                echo "OK" >>check_env.log
        else
                echo -e "\033[1;31m[ None ]\033[0m"
                echo "None" >>check_env.log
        fi
        sleep 1
        echo -n "Linux dos2unix:   "
        if [ "$c_dos2unix" == "$l_dos2unix" ];then
                echo -e "\033[1;32m[ OK ]\033[0m"
                echo "OK" >>check_env.log
        else
                echo -e "\033[1;31m[ None ]\033[0m"
                echo "None" >>check_env.log
        fi
        sleep 1
        echo -n "nginx container:  "
        if [ "$c_nginx" == "$nginx" ];then
                echo -e "\033[1;32m[ OK ]\033[0m"
                echo "OK" >>check_env.log
        else
                echo -e "\033[1;31m[ None ]\033[0m"
                echo "None" >>check_env.log
        fi
        sleep 1
}

env_check
# 环境检查结果判断，满足则程序开始运行，不满足退出。
function check_out(){
        for n  in `cat check_env.log`
        do
                if [ "$n" == "None" ];then
                        echo "检查未全部通过，程序退出！"
                        exit 0
                fi
        done
}

check_out

# 监控程序开始运行
echo "Pi node monitor is running "
date "+%H:%M:%S  %Y/%m/%d"
echo "脚本将一直运行，想要停止，请按 Ctrl + C"

########## 定义相关函数功能 ##############

# 开机运行时间
function get_upt(){
        upt=`uptime |sed 's/,  [0-9] user.*//g'|sed 's/.*up //g' |sed 's/,//g'|sed 's/\ /_/g'`
        echo $upt >args1.log
}

# 系统时钟
function sys_time(){
        syst=`date "+%H:%M:%S %Y/%m/%d" |sed 's/\//X/g'|sed 's/\ /_/g'`
        echo $syst >>args1.log
}

# 获取本机公网ip地址
function get_ip(){
        ip=`curl http://ifconfig.me 2> /dev/null`
        echo $ip >>args1.log
}

# 查询 pi-consensus 容器运行状态。
function ds(){
        docker_stats_info=`docker container stats pi-consensus --no-stream |grep "pi-consensus" |awk  '{print $2"\n"$3"\n"$7"\n"$8"\n"$10}'`
        # docker版本是相对稳定的参数，没必要每次都要查询，运行脚本时查询一次即可，此处直接读取。
        c_version=$1
        c_name=`echo $docker_stats_info|awk '{print $1}'`
        c_cpu=`echo $docker_stats_info|awk '{print $2}'`
        c_mem=`echo $docker_stats_info|awk '{print $3}'`
        c_in=`echo $docker_stats_info|awk '{print $4}'`
        c_out=`echo $docker_stats_info|awk '{print $5}'`

        echo $c_version >>args1.log
        echo $c_name >>args1.log
        echo $c_cpu >>args1.log
        echo $c_mem >>args1.log
        echo $c_in >>args1.log
        echo $c_out >>args1.log
}

# 查询主机信息，由 Windows power shell 完成。
function system_info(){
        # 运行powershell查询信息，写入到文件，并将文件转换为Linux系统文件。
        ./systeminfo.sh >./hostlog.log
        dos2unix ./hostlog.log &>/dev/null
        # 对数据筛选。
        s_version=`head -1 ./hostlog.log`
        s_name=`head -2 ./hostlog.log|tail -1`
        s_cpu=`head -3 ./hostlog.log|tail -1`
        s_mem_percent=`head -4 ./hostlog.log|tail -1`
        s_memall=`head -5 ./hostlog.log|tail -1`
        s_memused=`head -6 ./hostlog.log|tail -1`

        echo $s_version >>args1.log
        echo $s_name >>args1.log
        echo $s_cpu >>args1.log
        echo $s_mem_percent >>args1.log
        echo $s_memall >>args1.log
        echo $s_memused >>args1.log
}

# 查询 stellar-core 信息，结果写入到文件待用。
function stellar-core_info(){
        touch ./consensus_log.log
        info="./consensus_log.log"
        docker exec -it pi-consensus stellar-core http-command peers > $info
        docker exec -it pi-consensus stellar-core http-command info >> $info
        ## 使用 stellar-core 查询结果进行数据筛选，读取相关参数。
        cat $info |egrep "history_failure_rate|authenticated_count|pending_count|cost|last_check_ledger" |awk -F':' '{print $2}' |sed 's/^ *//g'|sed 's/"//g'|sed 's/,//g'|sed 's/ *$//g' >./advanced.log
        a_fault_rate=`head -1 ./advanced.log`
        a_auth_count=`head -2 ./advanced.log |tail -1`
        a_pending_count=`head -3 ./advanced.log |tail -1`
        a_cost=`head -4 ./advanced.log |tail -1`
        a_last_check_ledger=`head -5 ./advanced.log |tail -1`
        # 读取 incoming
        start_inbound=`cat $info |awk '/inbound/{print NR}' |head -1`
        end_inbound=`cat $info |awk '/outbound/{print NR}' |head -1`
        end_outbound=`cat $info |awk '/outbound/{print NR}' |tail -1`
        # 读取同步状态常见参数
        n_version=$1
        n_state=`cat $info |egrep "age|num|ledger|state" |awk -F':' '{print $2}' |sed -n '6p' |awk -F'"' '{print $2}' | sed 's/\ /_/g'`
        n_age=`cat $info |egrep "age|num|ledger|state" |awk -F':' '{print $2}' |sed -n '2p' |awk -F',' '{print $1}'`
        n_num=`cat $info |egrep "age|num|ledger|state" |awk -F':' '{print $2}' |sed -n '3p' |awk -F',' '{print $1}'`
        # shellcheck disable=SC2126
        n_in=`sed -n "${start_inbound},${end_inbound}p" $info |grep "stellar" |wc -l`
        n_out=`sed -n "${end_inbound},${end_outbound}p" $info |grep "stellar" |wc -l`
        n_status=`cat $info |egrep "Catching|Waiting" |tail -1|sed 's/^[ \t]*//g' |sed 's/\&/AND/g'|sed 's/\ /_/g'|sed 's/\//X/g'`

        echo $n_version >>args1.log
        echo $n_state >>args1.log
        echo $n_age >>args1.log
        echo $n_num >>args1.log
        echo $n_in >>args1.log
        echo $n_out >>args1.log

        echo $a_fault_rate >>args1.log
        echo $a_cost >>args1.log
        echo $a_last_check_ledger >>args1.log
        echo $a_auth_count >> args1.log
        echo $a_pending_count >>args1.log

        echo $n_status >>args1.log
        dos2unix ./args1.log &>/dev/null
}

# nmap host
function nmap_port(){
        nmap -Pn -p $ports $1 |awk '/3140[0-9]/{print $2}' |sed 's/[ \t]*$//g'>portscan.log
}

# 端口扫描间隔
function scan_host(){
        upt=`uptime |awk -F':' '{print $2}'`
        if [ "$upt" == "$CLOCK" ];then
                nmap_port localhost
        else
                nmap_port $ip
                if [ "$n_status" != "" ];then
                        echo -n "localhost clock: " >>stellar-core-status.log
                        date >>stellar-core-status.log
                        docker exec -it pi-consensus stellar-core http-command info >>stellar-core-status.log
                fi
        fi
        CLOCK=$upt
        sleep 0.5
}

# write information
function web_info(){
        for ((x=1;x<=27;x++))
        do
                a=`head -"$x" ./args1.log|tail -1`
                if [ $x == 1 ];then
                        sed -i /arg$x\ /s/\>.*/\>$a/g ./nginx/index.html
                        sed -i '/arg1 /s/_/\ /g' ./nginx/index.html
                elif [ $x == 2 ];then
                        sed -i /arg$x\ /s/\>.*/\>$a/g ./nginx/index.html
                        sed -i '/arg2 /s#_#\&nbsp\;\&nbsp\;\&nbsp\;\&nbsp\;#g' ./nginx/index.html
                        sed -i '/arg2 /s/X/\//g' ./nginx/index.html
                elif [ $x == 27 ];then
                        sed -i /arg$x\ /s/\>.*/\>$a/g ./nginx/index.html
                        sed -i '/arg27 /s/_/\ /g' ./nginx/index.html
                        sed -i '/arg27 /s/X/\//g' ./nginx/index.html
                        sed -i '/arg27 /s/AND/\&/g' ./nginx/index.html

                else
                        sed -i /arg$x\ /s/\>.*/\>$a/g ./nginx/index.html
                fi
        done
        for ((y=1;y<=10;y++))
        do
                p=`head -"$y" ./portscan.log|tail -1`
                sed -i /open_port$y\ /s/\=\".*/\=\"$p/g ./nginx/index.html
        done
        cp ./nginx/index.html ./nginx/index.htm
}


# 常量设置
CLOCK=""
ports="31400-31409"
c_version=`powershell.exe winget list --name "Docker" |awk '/Docker/{print $4}'`
pn_version=`powershell.exe winget list --name "Pi Network" |awk '/Pi Network/{print $4}'`

# 开始循环
for ((k=0;k<10;k++))
do
        get_upt
        sys_time
        get_ip
        ds $c_version
        system_info
        stellar-core_info $pn_version
        scan_host
        web_info
        let k-=1
done
