#!/bin/bash
echo "Pi node monitor is running "
date "+%H:%M:%S  %Y/%m/%d"
echo "脚本将一直运行，想要停止，请按 Ctrl + C"

# shell 监控函数
function node_monitor(){

        ## 获取本机公网ip地址
        ip_=`curl http://ifconfig.me 2> /dev/null`

        ## 采集stellar-core 信息，写入到文件
        touch ./consensus_log.log
        info="./consensus_log.log"
        docker exec -it pi-consensus stellar-core http-command peers > $info
        docker exec -it pi-consensus stellar-core http-command info >> $info

        ## 采集 Docker stats 信息
        dinfo=` docker stats --no-stream |grep "pi-consensus" |awk  '{print $2"\n"$3"\n"$7"\n"$8"\n"$10}'`

        c_version=$1
        c_name=`echo $dinfo|awk '{print $1}'`
        c_cpu=`echo $dinfo|awk '{print $2}'`
        c_mem=`echo $dinfo|awk '{print $3}'`
        c_in=`echo $dinfo|awk '{print $4}'`
        c_out=`echo $dinfo|awk '{print $5}'`

        ## 采集 Pi Node troubleshooting 相关信息 
        start_inbound=`cat $info |sed -n -e "/bound/=" -e "/bound/p" |sed -n '/^[0-9]/p' |head -1`
        end_inbound=`cat $info |sed -n -e "/bound/=" -e "/bound/p" |sed -n '/^[0-9]/p' |head -2|tail -1`
        end_outbound=`cat $info |sed -n -e "/bound/=" -e "/bound/p" |sed -n '/^[0-9]/p' |head -3|tail -1`

        n_version=$2
        n_state=`cat $info |egrep "age|num|ledger|state" |awk -F':' '{print $2}' |sed -n '6p' |awk -F'"' '{print $2}'`
        n_age=`cat $info |egrep "age|num|ledger|state" |awk -F':' '{print $2}' |sed -n '2p' |awk -F',' '{print $1}'`
        n_num=`cat $info |egrep "age|num|ledger|state" |awk -F':' '{print $2}' |sed -n '3p' |awk -F',' '{print $1}'`
        n_in=`sed -n "${start_inbound},${end_inbound}p" $info |grep "stellar" |wc -l`
        n_out=`sed -n "${end_inbound},${end_outbound}p" $info |grep "stellar" |wc -l`
        n_status_=`cat $info |egrep "Catching|Waiting" |tail -1`

        ## 采集更多 stellar-core 参数
        adv=`cat $info |egrep "history_failure_rate|authenticated_count|pending_count|cost|last_check_ledger" |awk -F':' '{print $2}' |sed 's/^ *//g'|sed 's/"//g'|sed 's/,//g'|sed 's/ *$//g' >./advanced.log`
        a_fault_rate=`head -1 ./advanced.log`
        a_auth_count=`head -2 ./advanced.log |tail -1`
        a_pending_count=`head -3 ./advanced.log |tail -1`
        a_cost=`head -4 ./advanced.log |tail -1`
        a_last_check_ledger=`head -5 ./advanced.log |tail -1`
        
        ## 采集主机系统相关信息，使用Windows powershell 命令完成
        ./systeminfo.sh >./hostlog.log
        dos2unix ./hostlog.log &>/dev/null

        s_version=`head -1 ./hostlog.log`
        s_name=`head -2 ./hostlog.log|tail -1`
        s_cpu=`head -3 ./hostlog.log|tail -1`
        s_mem_percent=`head -4 ./hostlog.log|tail -1`
        s_memall=`head -5 ./hostlog.log|tail -1`
        s_memused=`head -6 ./hostlog.log|tail -1`

        # 创建web页面表格，把监控信息填写到表格
        touch ./web_table.html
        touch ./webinfo.html
        file_="./web_table.html"
        echo "" >$file_
        echo '<div>
                <table id="hor-minimalist-a" summary="Employee Pay Sheet">
                <thead>
                <tr>
                    <th scope="col">' >$file_
                    echo ${ip_} >>$file_
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
        ## 下面判断语句，如果出现不同步情况，将采集 status 相关信息，并写入网页文件
        if [ "" != "$n_status_" ];then
                echo '
                <tr >
                    <td>Status: </td>
                    <td colspan="5">' >>$file_
                    echo $n_status_ >>$file_
                    echo '</td>
                </tr>' >>$file_
        fi

            echo '</tbody>
        </table>
            </div>' >>$file_
}


# 不经常变动的参数，采集一次即可，一次性获取Docer 版本号，Pi node软件版本号
c_version=`powershell.exe winget list --name "Docker" |awk '/Docker/{print $4}'`
pn_version=`powershell.exe winget list --name "Pi Network" |awk '/Pi Network/{print $4}'`

#  循环监控容器、操作系统和pi node troubleshooting 节点信息，并写入网页 index.html
for ((i=1; i<=10;i++))
do
        node_monitor $c_version $pn_version
        cat ./web_head.html >./webinfo.html
        cat ./web_table.html >>./webinfo.html
        cat ./web_tail.html >>./webinfo.html
        cat ./webinfo.html >./nginx/index.html
        echo "" >./webinfo.html
        sleep 1
        let i-=1
done
