#!/usr/bin/env bash
# 使用 UFW 設定基本防火牆規則
# 請以 root 權限執行

set -e

apt-get update -y
apt-get install -y ufw

# 預設拒絕輸入，允許輸出，拒絕轉發
ufw default deny incoming
ufw default allow outgoing
ufw default deny routed

# 開放 SSH (22 port)
ufw allow 22/tcp

# 開放 HTTP/HTTPS (如有必要)
ufw allow 80/tcp
ufw allow 443/tcp

# 如果 Docker Container 有要開放特定服務，請在此加入。例如 Jupyter Notebook 常用 8888:
ufw allow 8888/tcp

# 開放 VPN 用的 ESP, IKE port (IPSec 常用)
ufw allow 500/udp    # IKE
ufw allow 4500/udp   # NAT-T

# 啟用防火牆
ufw enable

echo "Firewall setup complete."
