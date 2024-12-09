#!/bin/bash

# 更新並安裝必要的依賴
sudo apt-get update -y
sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# 添加 Docker GPG 金鑰並設定 Repository
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 安裝 Docker 引擎
sudo apt-get update -y
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# 啟動並啟用 Docker 服務
sudo systemctl start docker
sudo systemctl enable docker

# 驗證 Docker 安裝
docker --version

# 初始化 Docker Swarm
echo "初始化 Docker Swarm..."
sudo docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')

# 顯示 Swarm 加入命令
echo "使用以下命令來添加其他節點到 Swarm 中："
sudo docker swarm join-token worker | grep 'docker swarm join'

echo "Docker Swarm 主節點安裝並初始化完成！"
