# 免责声明
# 此脚本主要由 Linux shell，Windows power shell 相关查询命令完成，不涉及改动任何系统相关设置，不会造成任何不良影响。
# 使用此脚本应具有相关Linux 基础、Windows系统基础，Docker基础和HTML基础。
# 由于自身操作不当导致系统故障或者节点故障，本人不承担任何责任。
# 此脚本无偿分享给派友，仅限于个人使用，禁止将此脚本用于商业行为。
# 本人无义务和责任为使用者排查使用方面的问题，请自行学习下面的使用方法
# 没有把握的情况，建议先使用虚拟机做实验，熟练后再放到节点上运行
# 感谢理解。

# pi-node-monitor
Pi Network Pi node Stellar-core，docker and server monitoring.

此 Pi node 节点监控shell脚本代码,仅适用于Windows 10和11 版本的Linux 子系统Ubuntu。

# 原理简介：

在Windows 系统安装Linux Ubuntu子系统，下载此shell脚本，解压后直接运行 ./node-monitor.sh 

首次使用需要先运行初始化脚本 ./initial.sh

node-monitor.sh 脚本使用 Linux和Windows 相关查询命令，采集以下信息：
  1) pi node 共识容器的状态，cpu使用率，内存使用率，I/O 
  2) 主机系统状态，CPU使用率，内存使用率
  3) pi node stellar-core 状态，常见参数 同步状态 state age local_block_number Incoming Outgoing

将以上信息写入到脚本所在目录的nginx 目录内的网页文件 index.html ,就可以访问这个网页。
要在网络上进行访问index.html, 所以需要安装网页访问服务软件 nginx
不过现在很方便，Docker 提供了nginx 容器，我们拉取到本地，把刚才nginx 目录挂载给nginx容器，就可以实现真正的网络访问。
由于节点服务器有公网ip，或者路由器有公网ip，我们把nginx容器的端口在路由器上做端口映射，就可以实现在公网访问节点的监控信息。

# 以下动手实操部分，建议有相关基础和动手能力强的小伙伴根据下面的说明进行操作。

前提：
Docker 和 pi node 软件已经正常运行。

第一部分：

节点服务器必须安装Windows Linux子系统发行版之一（例如：Ubuntu-20.04），并设置版本为V2.
WSL2安装步骤参考微软官网链接：
https://docs.microsoft.com/en-us/windows/wsl/install-manual#step-4---download-the-linux-kernel-update-package

在微软应用商店搜索 ubuntu 并安装

![image](https://user-images.githubusercontent.com/33740652/145417025-96b9bb91-f4fa-421b-9b7f-0e5c1b5f14be.png)

安装完成，点击打开

![image](https://user-images.githubusercontent.com/33740652/145417208-87032c15-9027-4144-99bc-745852126dda.png)

第一次运行时，需要设置一个用户名和密码（可以随意设置用户名和密码）

![image](https://user-images.githubusercontent.com/33740652/145417870-a68df0f9-4dea-4d5f-97d3-d5ac5ecccda5.png)

Ubuntu子系统已经安装成功。

我们在 “开始” 菜单搜索 power shell，打开 power shell

在命令行输入 

wsl -l -v 

可以查看当前已经安装的Linux 子系统

设置 刚才安装的 Ubuntu-20.04 为默认子系统

wsl --set-default Ubuntu-20.04

再次查看 wsl -l -v ，设置成功

输入 ubuntu 即可进入 Ubuntu-20.04 子系统

效果如下：

![image](https://user-images.githubusercontent.com/33740652/145419150-95fb096a-3521-42ed-9d10-dd56973e0f12.png)




第二部分：

节点服务器已经安装并正常运行 docker 4.1.1 以及更高版本。
在 Settings -->> Resources -->> · WSL INTEGRATION 启用一个已安装的Linux子系统发行版，例如下图，应用并重启。
![image](https://user-images.githubusercontent.com/33740652/145140772-64cff51a-f928-494e-b1a1-d46b9c982084.png)


第三部分：

下载脚本压缩包到本地，链接地址 https://github.com/wuchanghui5220/pi-node-monitor
按照下图点击 zip 下载文件

![image](https://user-images.githubusercontent.com/33740652/145364856-17e8bd44-0eeb-45fd-8a10-267703d39837.png)

第四部分：

如果你使用的是谷歌浏览器，默认文件下载目录是 “下载” 或者 “Download” 目录，解压缩下载的zip文件，解压到当前文件夹 或者你喜欢的目录位置

![image](https://user-images.githubusercontent.com/33740652/145366051-8fbca61b-632c-4d66-b9cf-91375b94a264.png)

双击进入目录，

![image](https://user-images.githubusercontent.com/33740652/145421322-7f3c4677-5185-46ce-8856-880586fdf7fc.png)

在空白处点击右键，选择 在Windows 终端中打开

![image](https://user-images.githubusercontent.com/33740652/145422862-3b15f57f-067f-467c-b061-e1288e39c9e3.png)


点击小箭头，选择 Ubuntu-20.04

![image](https://user-images.githubusercontent.com/33740652/145423044-7b9bc1c0-654d-4554-9d0c-6c09ddbd949d.png)



在Ubuntu 环境，开始使用shell 命令操作

进入下载目录 

cd Downloads/

再进入到解压文件的目录

cd pi-node-monitor-main/

查看查看目录内的文件

ls

效果如下图

![image](https://user-images.githubusercontent.com/33740652/145424563-607ea953-8b5f-4917-abfc-9f50330adfe0.png)



第五部分：

运行脚本

首次使用，请先运行 初始化脚本，以后则不需要重复运行。

./initial.sh

点 和 斜杠 不能少

![image](https://user-images.githubusercontent.com/33740652/145513158-08f1ed1a-7b35-41f7-a8e1-1329a80b287a.png)

Windows 的 winget 命令需要 同意源协议条款 ，输入 y 继续

提示输入 Linux 子系统用户的密码

![image](https://user-images.githubusercontent.com/33740652/145441722-6704fa59-0d67-4995-8b64-860873393238.png)

初始化完成后，运行监控采集脚本

./node-monitor.sh           

点 和 斜杠 不能少

效果如下图

![image](https://user-images.githubusercontent.com/33740652/145425001-435c496e-d4f9-4a5b-b90a-f67e3477e319.png)

如图所示，脚本一直运行，要停止 按 Ctrl + C 即可停止。

脚本已经开始采集相关信息，并将相关信息写入 当前目录下的 nginx目录内的index.hmtl 文件，这是web 网页文件。

监控信息的网页已设置每隔6秒自动刷新，使用浏览器访问这个网页即可看到相关监控。

双击目录 nginx，目录内 的index.html 就是我们需要访问的网页。

![image](https://user-images.githubusercontent.com/33740652/145426408-6bc67bf1-6447-45fa-8c3d-2154ed8d0484.png)


![image](https://user-images.githubusercontent.com/33740652/145369308-5499fcc4-ea23-4579-911a-8d66f2706cab.png)

![image](https://user-images.githubusercontent.com/33740652/145427749-302cccc9-bcb7-4b88-ade4-7d5a48cba08f.png)



第六部分：

以上5个部分完成了信息采集，并生成网页，我们可以本地查看，但要想使用网络访问，比如手机上或者其它电脑来访问，
就需要将我们的网页挂载到提供 访问服务的 软件 nginx 上，Docker提供了nginx 容器，我们直接拉取到本地，运行nginx容器，
把刚才的目录挂载给nginx，就可以通过网络访问了。

拉取nginx 容器

docker pull nginx

![image](https://user-images.githubusercontent.com/33740652/145439687-a792edd2-ded6-4cc1-8f70-a89297b85522.png)

耐心等待下载完成，网速快的话几分钟完成。

查看已下载的容器

docker images

运行容器，如果下载的目录不是 "Download"，得根据你实际位置修改路径，nginx容器能找到的目录

docker run --name mynginx -p 8080:80 -v /mnt/c/Users/wucha/Downloads/pi-node-monitor-main/nginx:/usr/share/nginx/html:ro -d nginx

简单说明：
      --name 给容器取个名字，叫 mynginx
      -p 8080:80  容器内部是80端口，映射到主机的 8080 端口
      -v /mnt/c/Users/wucha/Downloads/pi-node-monitor-main/nginx 这个就是我们下载后解压缩的目录，要把 nginx 目录挂载给容器
      :/usr/share/nginx/html:ro -d nginx  这是容器内部的目录，不要改动，照着写就行
  
  
查看容器状态

docker ps

如下图

![image](https://user-images.githubusercontent.com/33740652/145440666-e1d95d11-209c-42a6-a8d7-ebfb0c068181.png)



网页访问测试

主机服务器的内网IP地址 为 192.168.31.6

本地主机服务器浏览器访问

localhost:8080

![image](https://user-images.githubusercontent.com/33740652/145435120-d1956f1f-d07d-4df4-8baa-13d97a2e2f2a.png)

或者局域网内的另外一台电脑或者手机浏览器访问

192.168.31.6:8080

![image](https://user-images.githubusercontent.com/33740652/145435654-13543b38-67f9-43f6-bff4-2f4e088a496c.png)

使用公网ip进行访问

此节点的公网IP为 114.246.194.94

在浏览器输入

114.246.194.94:8888

8888 是在路由器配置的映射端口（当然，你可以设置为其他数字，比如9999，5678 都可以，只要在路由器映射正确即可），

将公网ip的 8888端口映射到局域网内 IP 为 192.168.31.6 这台主机的 8080 端口，访问nginx

![image](https://user-images.githubusercontent.com/33740652/145437754-9a56006c-cb95-4791-b965-2a30c0d4c475.png)

![image](https://user-images.githubusercontent.com/33740652/145436842-9f7de7f4-9aa7-4790-9155-329bffe8afb2.png)


# 常见问题总结

如果Docker 重启，或者主机重启 ，nginx 容器不会自动运行，需要手动打开，

如下图

![image](https://user-images.githubusercontent.com/33740652/145514017-88195195-afb6-4537-b3ea-74c924a1f358.png)

