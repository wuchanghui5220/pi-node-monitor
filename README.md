# pi-node-monitor
Pi Network Pi node Stellar-core，docker and server monitoring.

此 Pi node 节点监控shell脚本代码,仅适用于Windows 10和11 版本的Linux 子系统Ubuntu。

前提：
pi node软件已经正常运行。

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

下载压缩包到本地，链接地址 https://github.com/wuchanghui5220/pi-node-monitor
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


![image](https://user-images.githubusercontent.com/33740652/145367622-f7f8fe63-f5b3-4306-b964-4341e3137d15.png)

在Ubuntu 环境，开始使用shell 命令操作

cd Downloads/               #这个命令进入到 下载目录 

cd pi-node-monitor-main/    #这个命令再进入到解压zip文件的目录

ls                          #查看目录内的文件，效果如下图

![image](https://user-images.githubusercontent.com/33740652/145367874-1eee6bc3-8106-44d8-8b6d-8afcfc30203a.png)

第五部分：

运行脚本

./node-monitor.sh           #  点 斜杠 不能少

效果如下图

![image](https://user-images.githubusercontent.com/33740652/145368497-0f031808-58b8-484a-b315-c70d30d13720.png)
如图所示，脚本一直运行，要停止 按 Ctrl + C 即可停止。

我们需要的监控信息网页已经开始每隔6秒自动刷新，使用浏览器访问这个网页即可看到。
双击目录 nginx，目录内 的index.html 就是我们需要访问的网页。

![image](https://user-images.githubusercontent.com/33740652/145369116-c0257f40-ae1d-4b54-bf80-796e73342141.png)

![image](https://user-images.githubusercontent.com/33740652/145369308-5499fcc4-ea23-4579-911a-8d66f2706cab.png)

![image](https://user-images.githubusercontent.com/33740652/145369661-89f5b377-7068-41db-ba5f-e8b289e6a873.png)


第六部分：

以上5个部分完成了信息采集，并生成网页，我们可以本地查看，但要想使用网络访问，比如手机上或者其它电脑来访问，
就需要将我们的网页放到能提供 访问服务的 软件 nginx ，Docker提供了nginx 容器，我们直接拉取到本地，运行nginx容器，
把刚才的目录挂载给nginx，就可以通过网络访问了。

