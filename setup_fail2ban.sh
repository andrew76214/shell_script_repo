#!/usr/bin/env bash
# 此腳本在 Ubuntu 24.04 LTS 上安裝並設定 Fail2ban，
# 並與 UFW 防火牆整合，保護伺服器免受暴力破解攻擊。
# 請以 root 或具有 sudo 權限的使用者執行此腳本。

set -e

echo "開始安裝並設定 Fail2ban 與 UFW 整合..."

## 更新套件清單
apt-get update -y

## 安裝 Fail2ban
apt-get install -y fail2ban

## 設定 UFW 作為 Fail2ban 的防火牆後端
# 修改 /etc/fail2ban/jail.local，如果不存在則建立
cat > /etc/fail2ban/jail.local <<EOF
[DEFAULT]
# 使用 action 的定義，與 UFW 整合
# 這裡使用預設的 action，適用於 UFW
ignoreip = 127.0.0.1/8 ::1
bantime  = 1h
findtime  = 10m
maxretry = 5

# 是否啟用發送通知的電子郵件 (需額外設定)
# destemail = your-email@example.com
# sender = fail2ban@example.com
# action = %(action_mwl)s

# 選擇 UFW 作為防火牆
banaction = ufw

[sshd]
enabled = true
port    = ssh
filter  = sshd
logpath = /var/log/auth.log
maxretry = 5

# 如果您有其他服務需要保護，可以在此新增 jail
# 例如：
# [docker]
# enabled = true
# port    = 2375
# filter  = docker
# logpath = /var/log/docker.log
# maxretry = 5

EOF

## 檢查並設定 UFW 允許 Fail2ban 操作
# 確保 UFW 已安裝
apt-get install -y ufw

# 如果 UFW 未啟用，提示使用者確認
if ! ufw status | grep -q "active"; then
    echo "UFW 尚未啟用。是否現在啟用 UFW？ [y/N]"
    read -r enable_ufw
    if [[ "$enable_ufw" =~ ^[Yy]$ ]]; then
        # 預設規則已在 setup_firewall.sh 設定，這裡直接啟用
        ufw --force enable
    else
        echo "請確保 UFW 已啟用以保護伺服器安全。"
    fi
fi

## 重啟並啟用 Fail2ban
systemctl restart fail2ban
systemctl enable fail2ban

## 驗證 Fail2ban 狀態
echo "Fail2ban 狀態："
systemctl status fail2ban | grep Active

echo "Fail2ban 與 UFW 的整合設定完成。"

## 提供一些基本的 Fail2ban 管理指令
echo "您可以使用以下指令來管理 Fail2ban："
echo "  - 查看所有 jail 狀態: sudo fail2ban-client status"
echo "  - 查看特定 jail 狀態 (例如 sshd): sudo fail2ban-client status sshd"
echo "  - 手動解除封鎖 IP: sudo fail2ban-client set <jail> unbanip <IP_ADDRESS>"
