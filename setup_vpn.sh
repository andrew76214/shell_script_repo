#!/usr/bin/env bash
# 安裝與設定 StrongSwan IPSec VPN
# 請以 root 權限執行

set -e

apt-get update -y
apt-get install -y strongswan strongswan-pki libcharon-extra-plugins libstrongswan-extra-plugins

# 假設使用預共享金鑰(Preshared Key)，可在 /etc/ipsec.secrets 設定
# 若使用憑證模式，需另外建立 CA 與伺服器憑證。
# 以下範例以預共享金鑰為例
VPN_SERVER_PUBLIC_IP="YOUR_SERVER_PUBLIC_IP"
VPN_PSK="YOUR_SECRET_PSK"
VPN_USER="vpnuser"
VPN_USER_PASSWORD="vpnpassword" 

# 設定 ipsec.secrets
cat > /etc/ipsec.secrets <<EOF
: PSK "$VPN_PSK"
$VPN_USER : EAP "$VPN_USER_PASSWORD"
EOF

# 設定 ipsec.conf 基本 L2TP/IPsec 或 IKEv2 設定（此範例為 IKEv2 EAP-MSCHAPv2）
cat > /etc/ipsec.conf <<EOF
config setup
    charondebug="ike 1, knl 1, cfg 0"
    uniqueids=no

conn ikev2-eap
    keyexchange=ikev2
    ike=aes256-sha256-modp2048!
    esp=aes256-sha256!
    left=%any
    leftid=$VPN_SERVER_PUBLIC_IP
    leftsubnet=0.0.0.0/0
    leftauth=pubkey
    leftcert=serverCert.pem
    leftsendcert=always
    right=%any
    rightauth=eap-mschapv2
    rightsourceip=10.10.10.0/24
    rightdns=8.8.8.8,8.8.4.4
    rightsendcert=never
    eap_identity=%identity
    auto=add
EOF

# 注意：上面設定 leftcert=serverCert.pem 為例，需要您先行產生並放置伺服器憑證
# 若使用 PSK 模式，需調整設定檔以適用 PSK，並移除 cert 相關設定。

# 啟動 strongSwan
systemctl enable strongswan
systemctl start strongswan

# 開啟路由轉發讓 VPN Client 能透過此伺服器存取外網
sysctl -w net.ipv4.ip_forward=1
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf

# 配合防火牆的 NAT 設定 (以UFW為例，可於 /etc/ufw/before.rules 或 iptables 中加入)
# 此處示範用 iptables 臨時設定：
iptables -t nat -A POSTROUTING -s 10.10.10.0/24 -o eth0 -j MASQUERADE

echo "VPN setup complete. Please ensure you have a valid server certificate if using cert-based auth."
