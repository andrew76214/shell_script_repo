#!/usr/bin/env bash
# 此腳本在 Ubuntu 24.04 LTS 上安裝 GPU 驅動、CUDA、Docker、NVIDIA Container Toolkit
# 並建立供多使用者共用的環境。
# 請以 root 或可 sudo 權限的使用者執行此腳本。

set -e

## 更新系統套件
apt-get update -y && apt-get upgrade -y

## 安裝基本必需套件
apt-get install -y build-essential git curl wget apt-transport-https ca-certificates gnupg-agent software-properties-common

### 安裝 NVIDIA 驅動及 CUDA ###

# 將官方 CUDA repository 加入系統
# 注意：此處的 CUDA 版本與 GPU 驅動版本需依實際情況調整，以下僅為示例。
CUDA_VERSION="12.4"
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-ubuntu2404.pin
mv cuda-ubuntu2404.pin /etc/apt/preferences.d/cuda-repository-pin-600
wget https://developer.download.nvidia.com/compute/cuda/${CUDA_VERSION}/local_installers/cuda-repo-ubuntu2404-${CUDA_VERSION}-local_amd64.deb
dpkg -i cuda-repo-ubuntu2404-${CUDA_VERSION}-local_amd64.deb
cp /var/cuda-repo-ubuntu2404-${CUDA_VERSION}-local/cuda-keyring.gpg /usr/share/keyrings/
apt-get update
apt-get -y install cuda

# 安裝後重新載入 shell profile
echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 驗證 NVIDIA 驅動是否可用 (可在稍後重啟後執行 nvidia-smi)
# nvidia-smi

### 安裝 Docker ###

# 安裝 Docker GPG key 和 repository
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 啟用 Docker 並開機自動啟動
systemctl enable docker
systemctl start docker

### 安裝 NVIDIA Container Toolkit ###
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/nvidia-container-runtime/gpgkey | gpg --dearmor -o /etc/apt/keyrings/nvidia-container-runtime.gpg
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | \
sed 's#deb https://#deb [signed-by=/etc/apt/keyrings/nvidia-container-runtime.gpg] https://#' | tee /etc/apt/sources.list.d/nvidia-container-runtime.list

apt-get update
apt-get install -y nvidia-container-toolkit
nvidia-ctk runtime configure --runtime=docker
systemctl restart docker

# 測試 docker 是否可用 GPU
# docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu24.04 nvidia-smi

### 建立共享開發環境用戶與群組 ###

# 建立一個群組，例如 dlusers
groupadd -r dlusers || true

# 建立一個共享資料目錄，例如 /data，並設定給 dlusers 群組使用
mkdir -p /data
chown root:dlusers /data
chmod 2770 /data

# 要加入多用戶可在此添加，用戶會被加入 dlusers 群組，並有權使用 docker
# 例如：
# useradd -m -G dlusers,docker -s /bin/bash trainee
# passwd trainee

# 您可重複此步驟為多個用戶建立帳號，並確保他們在 docker 群組中可以使用 GPU docker

echo "Base GPU/Docker environment setup complete."
echo "Please reboot to ensure Nvidia drivers are fully operational."
