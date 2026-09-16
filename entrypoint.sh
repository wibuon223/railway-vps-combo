#!/usr/bin/env bash
set -Eeuo pipefail

echo "============================================================"
echo "🚀 Railway Ubuntu 24.04 VPS (OpenSSH + Pinggy tunnel)"
echo "   Base: minhdevtry/railway-vps + tunnel: AdityaHalder/railway-vps"
echo "============================================================"

# 1. Password: env ROOT_PASSWORD / PASSWORD, atau auto-random ala Aditya
if [[ -n "${ROOT_PASSWORD:-${PASSWORD:-}}" ]]; then
    ROOT_PASS="${ROOT_PASSWORD:-${PASSWORD}}"
else
    ROOT_PASS="$(openssl rand -base64 12 | tr -d '=+/')"
fi
SSH_KEY="${SSH_PUB_KEY:-${AUTHORIZED_KEYS:-}}"
HTTP_PORT="${PORT:-8080}"

# 2. System dirs + host keys
mkdir -p /var/run/sshd /run/sshd /etc/ssh/sshd_config.d /root/.ssh
chmod 0755 /var/run/sshd /run/sshd
chmod 0700 /root/.ssh
ssh-keygen -A >/dev/null 2>&1 || true

# 3. OpenSSH config (keep-alive ala minhdevtry)
cat > /etc/ssh/sshd_config.d/01-railway-ssh.conf << 'EOF'
Port 22
ListenAddress 0.0.0.0
PermitRootLogin yes
PasswordAuthentication yes
KbdInteractiveAuthentication yes
MaxStartups 100:30:200
TCPKeepAlive yes
ClientAliveInterval 30
ClientAliveCountMax 5
EOF
sed -i 's/^#\?PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config 2>/dev/null || true
sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config 2>/dev/null || true

# 4. Root password
echo "root:${ROOT_PASS}" | chpasswd
echo "🔑 Root password: set."

# 5. SSH public key (opsional)
if [[ -n "${SSH_KEY}" ]]; then
    printf '\n%b\n' "${SSH_KEY}" >> /root/.ssh/authorized_keys
    chmod 0600 /root/.ssh/authorized_keys
    echo "🔑 SSH Public Key loaded."
fi

# 6. Validasi config
if ! /usr/sbin/sshd -t; then
    echo "❌ SSH config invalid!" >&2
    exit 1
fi

# 7. Start sshd background dulu (biar bisa print tunnel info ala Aditya)
/usr/sbin/sshd
echo "✅ SSH Server running on port 22."

# 8. Pinggy tunnel (ala AdityaHalder/railway-vps, tanpa token tambahan)
echo "🚀 Starting Pinggy tunnel..."
rm -f /tmp/pinggy.log
ssh \
  -p 443 \
  -o StrictHostKeyChecking=no \
  -o ServerAliveInterval=30 \
  -o ExitOnForwardFailure=yes \
  -R0:localhost:22 \
  tcp@a.pinggy.io > /tmp/pinggy.log 2>&1 &

TUNNEL=""
for i in $(seq 1 30); do
    TUNNEL=$(grep -Eo 'tcp://[^ "]*:[0-9]+' /tmp/pinggy.log | tail -1 || true)
    if [[ -n "${TUNNEL}" ]]; then break; fi
    sleep 1
done

HOST=$(echo "$TUNNEL" | sed -E 's#tcp://([^:]+):([0-9]+)#\1#')
PORT_NUM=$(echo "$TUNNEL" | sed -E 's#tcp://([^:]+):([0-9]+)#\2#')

echo ""
echo "========================================"
echo "         SSH ACCESS DETAILS"
echo "========================================"
echo ""
echo "Host     : $HOST"
echo "Port     : $PORT_NUM"
echo "Username : root"
echo "Password : $ROOT_PASS"
echo ""
echo "SSH Command:"
echo ""
echo "ssh root@$HOST -p $PORT_NUM"
echo ""
echo "========================================"

# 9. Keep alive: sshd sudah jalan (background), tahan container
tail -f /dev/null
