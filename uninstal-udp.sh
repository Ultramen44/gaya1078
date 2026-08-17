#!/bin/bash
# ==================================================
# UNINSTALLER UDP CUSTOM, ZIVPN & SLOWDNS (UPDATED)
# ==================================================

# Warna untuk output
GREEN="\e[92;1m"
RED="\033[31m"
YELLOW="\033[33m"
NC='\e[0m'

echo -e "${YELLOW}======================================================${NC}"
echo -e "${GREEN}  MEMULAI PROSES UNINSTALL ZIVPN, UDP CUSTOM & SLOWDNS  ${NC}"
echo -e "${YELLOW}======================================================${NC}"
echo ""

if [ "${EUID}" -ne 0 ]; then
    echo -e "${RED}[ERROR] You need to run this script as root${NC}"
    exit 1
fi

# ==========================================
# 1. MENGHENTIKAN DAN MENGHAPUS SERVICE & PROSES
# ==========================================
echo -e "${YELLOW}[1/4] Menghentikan dan mendisable services & proses...${NC}"

# Kill Running Processes
pkill -f udp-custom >/dev/null 2>&1
pkill -f zivpn >/dev/null 2>&1
pkill -f sldns >/dev/null 2>&1

# Stop & Disable ZiVPN Service
systemctl stop zivpn.service >/dev/null 2>&1
systemctl disable zivpn.service >/dev/null 2>&1

# Stop & Disable UDP Custom Services
systemctl stop udp-custom.service >/dev/null 2>&1
systemctl disable udp-custom.service >/dev/null 2>&1
systemctl stop udp-request.service >/dev/null 2>&1
systemctl disable udp-request.service >/dev/null 2>&1

# Stop & Disable SlowDNS Services
systemctl stop client-sldns.service >/dev/null 2>&1
systemctl disable client-sldns.service >/dev/null 2>&1
systemctl stop server-sldns.service >/dev/null 2>&1
systemctl disable server-sldns.service >/dev/null 2>&1

# Reset failed systemd units
systemctl reset-failed >/dev/null 2>&1

# ==========================================
# 2. MENGHAPUS FILE DAN DIREKTORI (TOTAL CLEANUP)
# ==========================================
echo -e "${YELLOW}[2/4] Menghapus file core, biner, dan konfigurasi...${NC}"

# Hapus ZiVPN (Lengkap)
rm -rf /etc/zivpn
rm -rf /root/zivpn
rm -f /usr/local/bin/zivpn
rm -f /usr/local/bin/zivpn-sync
rm -f /usr/bin/zivpn
rm -f /etc/systemd/system/zivpn.service

# Hapus UDP Custom (Lengkap - Termasuk /root/udp & /usr/bin/udp-custom)
rm -rf /etc/udp
rm -rf /root/udp
rm -rf /usr/local/udp-custom
rm -f /usr/bin/udp-custom
rm -f /usr/local/bin/udp-custom
rm -f /etc/systemd/system/udp-custom.service
rm -f /etc/systemd/system/udp-request.service
rm -f /root/udp-custom.sh
rm -f /tmp/udp-custom*

# Hapus SlowDNS (Lengkap)
rm -rf /etc/slowdns
rm -rf /root/slowdns
rm -f /usr/bin/sldns-server
rm -f /usr/bin/sldns-client
rm -f /etc/systemd/system/client-sldns.service
rm -f /etc/systemd/system/server-sldns.service
rm -f /tmp/nameserver

# ==========================================
# 3. MEMBERSIHKAN ATURAN IPTABLES & ROUTING
# ==========================================
echo -e "${YELLOW}[3/4] Membersihkan routing iptables...${NC}"

# Menghapus rule iptables yang dibuat oleh ZiVPN & UDP Custom
iptables -t nat -D PREROUTING -p udp --dport 6000:19999 -j REDIRECT --to-ports 5667 >/dev/null 2>&1
iptables -D INPUT -p udp --dport 5667 -j ACCEPT >/dev/null 2>&1
iptables -D INPUT -p udp -m multiport --dports 6000:19999 -j ACCEPT >/dev/null 2>&1

# Menyimpan ulang iptables agar permanen
if command -v iptables-save >/dev/null 2>&1; then
    iptables-save > /etc/iptables.up.rules 2>/dev/null
fi

if command -v netfilter-persistent >/dev/null 2>&1; then
    netfilter-persistent save >/dev/null 2>&1
    netfilter-persistent reload >/dev/null 2>&1
fi

# ==========================================
# 4. RESTART DAEMON & CLEANUP
# ==========================================
echo -e "${YELLOW}[4/4] Reload system daemon...${NC}"
systemctl daemon-reload

echo ""
echo -e "${GREEN}======================================================${NC}"
echo -e "${GREEN}  UNINSTALL SELESAI & BERSIH TOTAL!                  ${NC}"
echo -e "${GREEN}  ZiVPN UDP, UDP Custom, dan SlowDNS telah dihapus.   ${NC}"
echo -e "${GREEN}  Sistem siap untuk di-install ulang tanpa bentrok.   ${NC}"
echo -e "${GREEN}======================================================${NC}"
