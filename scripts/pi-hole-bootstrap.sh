#!/bin/bash
# Run as root on pi-hole (DietPi / dropbear). One-time: install the dedicated
# SSH key from pi-cluster, then serve NTP to the k3s LAN and Tailscale CGNAT.
set -euo pipefail

install -d -m 0700 /root/.ssh
pubkey='ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMYDA/2YaiAC25BsS9n6uXi7U18Zywjx1cC3vSDwCXVz pi-cluster-to-pi-hole'
grep -qxF "$pubkey" /root/.ssh/authorized_keys 2>/dev/null || echo "$pubkey" >> /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys
if [ -d /etc/dropbear ]; then
  grep -qxF "$pubkey" /etc/dropbear/authorized_keys 2>/dev/null || echo "$pubkey" >> /etc/dropbear/authorized_keys
  chmod 600 /etc/dropbear/authorized_keys
fi

cat >/etc/chrony/conf.d/lab.conf <<'EOF'
bindaddress 0.0.0.0
allow 192.168.50.0/24
allow 100.64.0.0/10
local stratum 10
EOF

cat >/etc/systemd/system/ntp-allow.service <<'EOF'
[Unit]
Description=Allow NTP client queries on UDP 123
After=network-pre.target
Before=chrony.service

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/bin/sh -c '/usr/sbin/iptables -C INPUT -p udp --dport 123 -j ACCEPT 2>/dev/null || /usr/sbin/iptables -I INPUT -p udp --dport 123 -j ACCEPT'

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now ntp-allow.service
systemctl restart chrony
ss -ulnp | grep 123 || true
chronyc tracking | head -8
echo "bootstrap done"
