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
        if [ "$docker" == "$c_docker" ];then
                echo -e "\033[1;32m[ OK ]\033[0m"
                echo "OK" >check_env.log
        else
                echo -e "\033[1;31m[ None ]\033[0m"
                echo "None" >check_env.log

        fi
        sleep 1
        echo -n "Pi Network Node:  "
        if [ "$pi" == "$c_pi" ];then
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

# 获取本机公网ip地址
function get_ip(){
        ip=`curl http://ifconfig.me 2> /dev/null`
        # shellcheck disable=SC2086
        # shellcheck disable=SC2034
        return_ip=$ip
}



# 查询 pi-consensus 容器运行状态。
function docker_stats(){
        # shellcheck disable=SC2006
        docker_stats_info=` docker stats --no-stream |grep "pi-consensus" |awk  '{print $2"\n"$3"\n"$7"\n"$8"\n"$10}'`
        # docker版本是相对稳定的参数，没必要每次都要查询，运行脚本时查询一次即可，此处直接读取。
        c_version=$1
        c_name=`echo $docker_stats_info|awk '{print $1}'`
        c_cpu=`echo $docker_stats_info|awk '{print $2}'`
        c_mem=`echo $docker_stats_info|awk '{print $3}'`
        c_in=`echo $docker_stats_info|awk '{print $4}'`
        c_out=`echo $docker_stats_info|awk '{print $5}'`
}

# 查询 stellar-core 信息，结果写入到文件待用。
function stellar-core_info(){
        touch ./consensus_log.log
        info="./consensus_log.log"
        docker exec -it pi-consensus stellar-core http-command peers > $info
        docker exec -it pi-consensus stellar-core http-command info >> $info

        ## 使用 stellar-core 查询结果进行数据筛选，读取相关参数。

        ## 读取更多参数
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
        n_state=`cat $info |egrep "age|num|ledger|state" |awk -F':' '{print $2}' |sed -n '6p' |awk -F'"' '{print $2}'`
        n_age=`cat $info |egrep "age|num|ledger|state" |awk -F':' '{print $2}' |sed -n '2p' |awk -F',' '{print $1}'`
        n_num=`cat $info |egrep "age|num|ledger|state" |awk -F':' '{print $2}' |sed -n '3p' |awk -F',' '{print $1}'`
        # shellcheck disable=SC2126
        n_in=`sed -n "${start_inbound},${end_inbound}p" $info |grep "stellar" |wc -l`
        n_out=`sed -n "${end_inbound},${end_outbound}p" $info |grep "stellar" |wc -l`
        n_status_=`cat $info |egrep "Catching|Waiting" |tail -1`

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
}

# 端口扫描
function nmap_port(){
        nmap -Pn -p $ports $1 |awk '/3140[0-9]/{print $2}' |sed 's/[ \t]*$//g'>portscan.log
}

# 端口状态信息
function show_pic(){
for i in `cat portscan.log`
do
        if [ "$i" == "filtered" ];then
                echo '<td><img class="gray" src="./web/logo-pi.png"></td>' >>$file_
        elif [ "$i" == "closed" ];then
                echo '<td><img class="gray" src="./web/logo-pi.png"></td>' >>$file_
        else
                echo '<td><img class="gold" src="./web/logo-pi.png"></td>' >>$file_
        fi
done
}
# 端口扫描间隔
function scan_time(){
        upt=`uptime |awk -F':' '{print $2}'`
        if [ "$upt" == "$CLOCK" ];then
                nmap_port $local_ip
                show_pic
        else
                nmap_port $ip
                show_pic
        fi
        CLOCK=$upt
        sleep 0.5
}

# 整合信息，写入到 HTML 表格
function web_table_info(){
        touch ./web_table.html
        touch ./webinfo.html
        file_="./web_table.html"
        echo "" >$file_
        echo '<div>
                <table id="hor-minimalist-a" summary="Employee Pay Sheet">
                <thead>
                <tr>
                    <th scope="col">' >$file_
                    # shellcheck disable=SC2129
                    echo ${ip} >>$file_
                    echo '</th>
                    <th scope="col"></th>
                    <th colspan="2" scope="col">' >>$file_
                    uptime |awk -F'up' '{print $2}'|awk -F',' '{print $1$2}' |awk -F'users' '{print $1}' >>$file_
                    echo '
                    </th>
                    <th colspan="2" scope="col"> ' >>$file_
                    date "+%H:%M:%S  %Y/%m/%d" >>$file_
                    echo '</th>
                </tr>
            </thead>
            <tbody>
                <tr>
                    <td >Docker stats</td>
                    <td>Container</td>
                    <td>CPU%</td>
                    <td>MEM%</td>
                    <td>Network_In</td>
                    <td>Network_Out</td>

                </tr>
                <tr id="hor-minimalist-a-td">
                    <td>' >>$file_
                    echo $c_version >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo $c_name >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo "${c_cpu}" >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo $c_mem >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo $c_in >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo $c_out >>$file_
                    echo '</td>
                </tr>
                <tr>
                    <td>System Info</td>
                    <td>Hostname</td>
                    <td>CPU%</td>
                    <td>MEM%</td>
                    <td>Total_Memory</td>
                    <td>Used_Memory</td>

                </tr>
                <tr id="hor-minimalist-a-td">
                    <td>' >>$file_
                    echo $s_version >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo $s_name >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo "$s_cpu" >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo "${s_mem_percent}" >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo ${s_memall}GB >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo ${s_memused}GB >>$file_
                    echo '</td>
                </tr>
                <tr>
                    <td>Pi Node Info</td>
                    <td>State</td>
                    <td>age</td>
                    <td>local num</td>
                    <td>Incoming</td>
                    <td>Outgoing</td>

                </tr>
                <tr id="hor-minimalist-a-td">
                    <td>Ver: ' >>$file_
                    echo $n_version >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo $n_state >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo $n_age >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo $n_num >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo $n_in >>$file_
                    echo '</td>
                    <td>' >>$file_
                    echo $n_out >>$file_
                    echo '</td>
                    </tr> '>>$file_

                    echo '
                    <tr>
                          <td></td>
                          <td>failure_rate</td>
                          <td>cost</td>
                          <td>last_check</td>
                          <td>a_count</td>
                          <td>p_count</td>
                    </tr>

                    <tr id="hor-minimalist-a-td">
                          <td> ' >>$file_
                          echo "" >>$file_
                          echo '</td>
                          <td>' >>$file_
                          echo $a_fault_rate >>$file_
                          echo '</td>
                          <td>' >>$file_
                          echo $a_cost >>$file_
                          echo '</td>
                          <td>' >>$file_
                          echo $a_last_check_ledger>>$file_
                          echo '</td>
                          <td>' >>$file_
                          echo $a_auth_count >>$file_
                          echo '</td>
                          <td>' >>$file_
                          echo $a_pending_count>>$file_
                          echo '</td>
                    </tr> '>>$file_
            # 不同步时，将status状态写入到 HTML 表格，方便查看当前状态进度。
                    if [ "" != "$n_status_" ];then
                            # shellcheck disable=SC2129
                            echo '
                            <tr >
                                <td>Status: </td>
                                <td colspan="5">' >>$file_
                                echo $n_status_ >>$file_
                                echo '</td>
                            </tr>' >>$file_
                    fi

                        # shellcheck disable=SC2129
                        echo '</tbody>
                        </table>
                    </div>' >>$file_

                    echo '
                    <div>
                        <table id="hor-minimalist-a" summary="Employee Pay Sheet">
                          <thead>
                            <tr>
                              <th scope="col">' >>$file_
                              # shellcheck disable=SC2129
                              echo 'Open port'>>$file_
                              echo '</th>
                              <th scope="col">00</th>
                              <th scope="col">01</th>
                              <th scope="col">02</th>
                              <th scope="col">03</th>
                              <th scope="col">04</th>
                              <th scope="col">05</th>
                              <th scope="col">06</th>
                              <th scope="col">07</th>
                              <th scope="col">08</th>
                              <th scope="col">09</th>
                              <th scope="col"></th>
                              ' >>$file_
                              echo '</th>
                            </tr>
                          </thead>
                        <tbody>
                          <tr>
                            <td >31400-31409</td>' >>$file_
                              scan_time
                      echo '<td></td>
                          </tr>
                        </tbody>
                      </table>
                    </div>' >>$file_
}


# 不经常变动的参数，采集一次即可，一次性获取Docker 版本号，Pi node软件版本号
c_version=`powershell.exe winget list --name "Docker" |awk '/Docker/{print $4}'`
pn_version=`powershell.exe winget list --name "Pi Network" |awk '/Pi Network/{print $4}'`
local_ip="localhost"
ports="31400-31409"
CLOCK="00"

# 网页文件路径参数
web_info="./webinfo.html"
web_index="./nginx/index.html"
#  循环监控容器、操作系统和pi node troubleshooting 节点信息，并写入网页 index.html
for ((i=1; i<=10;i++))
do

# 执行函数
get_ip
docker_stats $c_version
stellar-core_info $pn_version
system_info

web_table_info

# 写入信息到网页
cat ./web_head.html >$web_info
cat ./web_table.html >>$web_info
cat ./web_tail.html >>$web_info
cat $web_info >$web_index
echo "" >$web_info
sleep 0.5
# shellcheck disable=SC2219
let i-=1

done
