# docker-compose down --rmi all --volumes --remove-orphans
# docker-compose up --build -d

# 使用最新的 Ubuntu 基礎鏡像
FROM ubuntu:latest

# 設置環境變數
ENV ACCEPT_EULA=Y DEBIAN_FRONTEND=noninteractive

# 更新系統並安裝必要工具
RUN apt-get update && \
    apt-get install -y wget bzip2 curl openssh-server && \
    apt-get clean

# 安裝 Miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/miniconda3 && \
    rm /tmp/miniconda.sh && \
    echo "export PATH=/opt/miniconda3/bin:$PATH" > /etc/profile.d/miniconda.sh

# 添加 Miniconda 到 PATH
ENV PATH="/opt/miniconda3/bin:$PATH"

# 初始化 Conda
RUN conda init bash

# 創建基本用戶
RUN useradd -m -s /bin/bash devuser && \
    echo "devuser:password123" | chpasswd && \
    mkdir -p /home/devuser/.ssh && \
    chown -R devuser:devuser /home/devuser/.ssh

# 配置 SSH
RUN mkdir /run/sshd && \
    echo 'root:password' | chpasswd && \
    echo "PermitRootLogin no" >> /etc/ssh/sshd_config && \
    echo "Port 22" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "AllowUsers devuser" >> /etc/ssh/sshd_config

# 暴露端口 22
EXPOSE 22

# 設置工作目錄
WORKDIR /app

# 切換成非 root 使用者
USER devuser

# 啟動 SSH 服務
CMD ["/usr/sbin/sshd", "-D"]
