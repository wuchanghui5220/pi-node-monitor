#!/bin/bash

# 首次使用 winget 命令，需要同意 Windows源协议条款
powershell.exe winget list --name "Docker"

# winget 命令采集的信息文件需要转换为Linux 系统文件
# 所以要安装 dos2unix 工具

sudo apt update
sudo apt install dos2unix

# 安装端口扫描工具 nmap
sudo apt install nmap
