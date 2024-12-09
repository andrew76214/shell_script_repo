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

# 將當前用戶加入 docker 群組以避免權限問題
sudo usermod -aG docker $USER

echo "已將用戶 $USER 加入 docker 群組。請登出並重新登入以使權限生效，或者手動運行以下命令使更改立即生效："
echo "newgrp docker"

# 驗證 Docker 安裝
docker --version

# 選擇節點類型
echo "選擇要設置的 Docker Swarm 節點類型："
echo "1) 主節點 (Manager)"
echo "2) 工作節點 (Worker)"
echo "3) 主節點 (Manager) + 工作節點 (Worker)"
read -p "請輸入選項 (1 或 2 或 3): " node_type

if [ "$node_type" == "1" ]; then
    # 初始化 Docker Swarm 主節點
    echo "初始化 Docker Swarm 主節點..."
    sudo docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')

    # 顯示加入 Swarm 的命令
    echo "使用以下命令來添加其他節點到 Swarm 集群中："
    sudo docker swarm join-token worker | grep 'docker swarm join'

    echo "Docker Swarm 主節點安裝並初始化完成！"

elif [ "$node_type" == "2" ]; then
    # 請求加入 Swarm 的命令
    echo "請輸入主節點提供的 Swarm 加入命令："
    read -p "Swarm 加入命令: " join_command

    # 執行加入 Swarm 命令
    eval "$join_command"

    echo "Docker Swarm 工作節點安裝並加入完成！"

elif [ "$node_type" == "3" ]; then
    # 初始化 Docker Swarm 主節點
    echo "初始化 Docker Swarm 主節點..."
    sudo docker swarm init --advertise-addr $(hostname -I | awk '{print $1}')

    # 顯示加入 Swarm 的命令
    echo "使用以下命令來添加其他節點到 Swarm 集群中："
    join_command=$(sudo docker swarm join-token worker | grep 'docker swarm join')

    echo "Docker Swarm 主節點安裝並初始化完成！"
    
    # 執行加入 Swarm 命令
    eval "$join_command"

    echo "Docker Swarm 工作節點安裝並加入完成！"

else
    echo "無效的選項，請重新運行腳本並選擇 1 或 2。"
    exit 1
fi
