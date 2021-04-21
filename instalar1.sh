#!/bin/bash
#
#####################
### Configuration ###
#####################

### API Alias
Filename_alias='myvpn';




# MySQL Remote Server side
DatabaseHost='209.159.147.190';
DatabaseName='routervp_routervp';
DatabaseUser='routervp_routervp';
DatabasePass='KuD%2fsq4I+l';
DatabasePort='3306';
clear
echo -e "\e[1;32m-----------------------------------------------------"
echo -e "\e[1;32m                Openvpn Script by  Al-amin           "
echo -e "\e[1;32m-----------------------------------------------------"
sleep 2
clear
echo "Enter VPS IP Address: "
read ip1
clear
echo -----------------------------------------------------
echo Updating System 2
echo -----------------------------------------------------
sleep 2
apt-get update
apt-get install sudo -y
DEBIAN_FRONTEND=noninteractive apt-get full-upgrade -q -y -u  -o Dpkg::Options::="--force-confdef" --allow-downgrades --allow-remove-essential --allow-change-held-packages --allow-unauthenticated
apt-get install mysql-client nano fail2ban unzip apache2 build-essential curl -y
sudo apt-get install php libapache2-mod-php -y
clear
echo -----------------------------------------------------
echo Installing Openvpn
echo -----------------------------------------------------
sleep 2
apt-get install openvpn easy-rsa -y
mkdir -p /etc/openvpn/easy-rsa/keys
mkdir -p /etc/openvpn/login
mkdir -p /etc/openvpn/script
mkdir -p /var/www/html/status
clear
echo -----------------------------------------------------
echo Installing Squid Proxy
echo -----------------------------------------------------
sleep 2
sudo touch /etc/apt/sources.list.d/trusty_sources.list
echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty main universe" | sudo tee --append /etc/apt/sources.list.d/trusty_sources.list > /dev/null
sudo apt update
sudo apt install -y squid3=3.3.8-1ubuntu6 squid=3.3.8-1ubuntu6 squid3-common=3.3.8-1ubuntu6
wget https://raw.githubusercontent.com/Alaminbd257/openvpn/main/squid3
sudo cp squid3 /etc/init.d/
sudo chmod +x /etc/init.d/squid3
sudo update-rc.d squid3 defaults
clear
echo -----------------------------------------------------
echo Configuring Sysctl
echo -----------------------------------------------------
sleep 2
echo 'fs.file-max = 51200
net.core.rmem_max = 67108864
net.core.wmem_max = 67108864
net.core.netdev_max_backlog = 250000
net.core.somaxconn = 4096
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 10000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_mem = 25600 51200 102400
net.ipv4.tcp_rmem = 4096 87380 67108864
net.ipv4.tcp_wmem = 4096 65536 67108864
net.ipv4.tcp_mtu_probing = 1
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr
net.ipv4.ip_forward=1
net.ipv4.icmp_echo_ignore_all = 1' >> /etc/sysctl.conf
echo '* soft nofile 512000
* hard nofile 512000' >> /etc/security/limits.conf
ulimit -n 512000
clear 
echo -----------------------------------------------------
echo Disabled Selinux!
echo -----------------------------------------------------
sleep 2
SELINUX=disabled 
clear
echo -----------------------------------------------------
echo Installing Stunnel
echo -----------------------------------------------------
sleep 2
apt-get install stunnel4 -y
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
clear
echo -----------------------------------------------------
echo Configuring Stunnel.conf 
echo -----------------------------------------------------
wget https://my-vpn.xyz/pem.zip
unzip pem.zip
rm pem.zip
cat /root/key.pem cert.pem > /etc/stunnel/stunnel.pem
touch /var/www/html/status/stunnel.txt
touch /var/www/html/status/tcp1.txt
touch /var/www/html/status/ipp.txt
sleep 1
rm key.pem
rm cert.pem
sleep 1
echo 'cert=/etc/stunnel/stunnel.pem
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
client = no

[openvpn]
connect = '$ip1':1194
accept = 443' > /etc/stunnel/stunnel.conf
clear
echo -----------------------------------------------------
echo Reduce Overheating with TLP
echo -----------------------------------------------------
sleep 2
sudo add-apt-repository ppa:linrunner/tlp -y
sudo apt-get update
sudo apt-get install tlp tlp-rdw -y
sudo tlp start
clear
echo -----------------------------------------------------
echo Checking Configuration
echo -----------------------------------------------------
sleep 2
update-rc.d apache2 enable
update-rc.d squid3 enable
update-rc.d cron enable
update-rc.d openvpn enable
update-rc.d stunnel4 enable
update-rc.d fail2ban enable
update-rc.d tlp enable
clear
echo -----------------------------------------------------
echo Configuring IP Tables with Anti Torrent
echo -----------------------------------------------------
sleep 2
sysctl -p
iptables -F; iptables -X; iptables -Z
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to $ip1
iptables -t nat -A POSTROUTING -s 192.168.2.0/24 -j SNAT --to $ip1
iptables -A INPUT -i tun0 -j ACCEPT
iptables -A FORWARD -i tun0 -j ACCEPT
iptables -t mangle -A PREROUTING -j CONNMARK --restore-mark
iptables -t mangle -A PREROUTING -m mark ! --mark 0 -j ACCEPT
iptables -t mangle -A PREROUTING -m ipp2p --bit -j MARK --set-mark 1
iptables -t mangle -A PREROUTING -m ipp2p --edk -j MARK --set-mark 1
iptables -t mangle -A PREROUTING -m mark --mark 1 -j CONNMARK --save-mark
iptables -A FORWARD -m mark --mark 1 -j REJECT
iptables -A INPUT -m mark --mark 1 -j REJECT
iptables -A OUTPUT -m mark --mark 1 -j REJECT
clear
echo -----------------------------------------------------
echo Configuring Server and Squid conf
echo -----------------------------------------------------
sleep 2
touch /etc/openvpn/server1.conf
touch /etc/openvpn/server2.conf
sleep 1
echo 'http_port 8080
http_port 3128
http_port 80
http_port 9999
http_port 8585
http_port 8989
http_port 8000
http_port 3333
http_port 2222
http_port 1111
acl to_vpn dst '$ip1'
http_access allow to_vpn 
via off
forwarded_for off
request_header_access Allow allow all
request_header_access Authorization allow all
request_header_access WWW-Authenticate allow all
request_header_access Proxy-Authorization allow all
request_header_access Proxy-Authenticate allow all
request_header_access Cache-Control allow all
request_header_access Content-Encoding allow all
request_header_access Content-Length allow all
request_header_access Content-Type allow all
request_header_access Date allow all
request_header_access Expires allow all
request_header_access Host allow all
request_header_access If-Modified-Since allow all
request_header_access Last-Modified allow all
request_header_access Location allow all
request_header_access Pragma allow all
request_header_access Accept allow all
request_header_access Accept-Charset allow all
request_header_access Accept-Encoding allow all
request_header_access Accept-Language allow all
request_header_access Content-Language allow all
request_header_access Mime-Version allow all
request_header_access Retry-After allow all
request_header_access Title allow all
request_header_access Connection allow all
request_header_access Proxy-Connection allow all
request_header_access User-Agent allow all
request_header_access Cookie allow all
request_header_access All deny all 
http_access deny all' > /etc/squid3/squid.conf
sleep 2
echo 'local '$ip1'
mode server 
tls-server
topology subnet 
port 1194 
proto tcp 
dev tun
keepalive 3 180
resolv-retry infinite 
ca /etc/openvpn/easy-rsa/keys/ca.crt 
cert /etc/openvpn/easy-rsa/keys/server.crt 
key /etc/openvpn/easy-rsa/keys/server.key 
dh /etc/openvpn/easy-rsa/keys/dh2048.pem 
client-cert-not-required 
username-as-common-name 
auth-user-pass-verify "/etc/openvpn/login/auth_vpn" via-file # 
tmp-dir "/etc/openvpn/" # 
server 10.8.0.0 255.255.255.0
sndbuf 0
rcvbuf 0
push "redirect-gateway def1" 
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "sndbuf 0"
push "rcvbuf 0"
cipher AES-128-CBC
tcp-nodelay
verb 3
script-security 2
client-connect /etc/openvpn/script/connect.sh
client-disconnect /etc/openvpn/script/disconnect.sh
up /etc/openvpn/update-resolv-conf                                                                                      
down /etc/openvpn/update-resolv-conf
status /var/www/html/status/tcp1.txt
ifconfig-pool-persist /var/www/html/status/ipp.txt' > /etc/openvpn/server2.conf
sleep 1
cd /etc/openvpn/
chmod 755 server1.conf
chmod 755 server2.conf
sleep 1
cd /etc/openvpn/login/
wget https://raw.githubusercontent.com/Alaminbd257/openvpn/main/auth_vpn
sleep 1
chmod 755 auth_vpn
sleep 1
cd /etc/openvpn/easy-rsa/keys
wget https://my-vpn.xyz/keys.zip
unzip keys.zip
rm keys.zip
cd /etc/openvpn/script
wget https://raw.githubusercontent.com/Alaminbd257/openvpn/main/connect.sh
wget https://raw.githubusercontent.com/Alaminbd257/openvpn/main/disconnect.sh
chmod +x /etc/openvpn/script/connect.sh
chmod +x /etc/openvpn/script/disconnect.sh
clear
echo -----------------------------------------------------
echo Configuring Fail2Ban
echo -----------------------------------------------------
sleep 3
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sed -i 's/bantime  = 600/bantime  = 3600/g' /etc/fail2ban/jail.local
sed -i 's/maxretry = 6/maxretry = 3/g' /etc/fail2ban/jail.local
sed -i 's/destemail = '.*'/destemail = #/g' /etc/fail2ban/jail.local
clear
echo -----------------------------------------------------
echo Setting up Time Zone 
echo -----------------------------------------------------
sleep 2
sudo timedatectl set-timezone Asia/Dhaka
timedatectl
sleep 2
clear
echo -----------------------------------------------------
echo Modifying Permission
echo -----------------------------------------------------
sleep 2
sudo usermod -a -G www-data root
sudo chgrp -R www-data /var/www
sudo chmod -R g+w /var/www
clear
echo -----------------------------------------------------
echo Saving Setup Rules
echo -----------------------------------------------------
sleep 2
sudo apt install debconf-utils -y
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | sudo debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | sudo debconf-set-selections
sudo apt-get install iptables-persistent -y
iptables-save > /etc/iptables/rules.v4 
ip6tables-save > /etc/iptables/rules.v6
clear

touch /usr/local/sbin/reboot.sh
echo 'reboot
' > /usr/local/sbin/reboot.sh

touch /usr/local/sbin/ssl.sh
echo 'service stunnel4 start
' > /usr/local/sbin/ssl.sh

/bin/cat <<"EOM" >/usr/local/sbin/ram.sh
sudo sync; echo 3 > /proc/sys/vm/drop_caches
swapoff -a && swapon -a
echo '#' > /var/log/haproxy.log
echo "Ram Cleaned!"
EOM
chmod +x /usr/local/sbin/reboot.sh
chmod +x /usr/local/sbin/ram.sh
chmod +x /usr/local/sbin/ssl.sh

(crontab -l 2>/dev/null || true; echo "#
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
* 4 * * * /usr/local/sbin/ssl.sh
0 4 * * * /usr/local/sbin/reboot.sh
* * * * * /usr/local/sbin/ram.sh") | crontab -

service cron restart

/bin/cat <<"EOM" >/var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Sakalaka DNS</title>
<meta name="viewport" content="width=device-width, initial-scale=1">
<meta http-equiv="X-UA-Compatible" content="IE=edge" />
<link rel="stylesheet" href="https://bootswatch.com/4/slate/bootstrap.min.css" media="screen">
<link href="https://fonts.googleapis.com/css?family=Press+Start+2P" rel="stylesheet">
<style>
    body {
     font-family: "Press Start 2P", cursive;    
    }
    .fn-color {
        color: #ff00ff;
        background-image: -webkit-linear-gradient(92deg, #f35626, #feab3a);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        -webkit-animation: hue 5s infinite linear;
    }

    @-webkit-keyframes hue {
      from {
        -webkit-filter: hue-rotate(0deg);
      }
      to {
        -webkit-filter: hue-rotate(-360deg);
      }
    }
</style>
</head>
<body>
<div class="container" style="padding-top: 50px">
<div class="jumbotron">
<h1 class="display-3 text-center fn-color">Sakalaka DNS</h1>
<h4 class="text-center text-danger">Power By</h4>
<p class="text-center">A2Z-SERVER-LTD</p>
</div>
</div>
</body>
</html>
EOM

echo -----------------------------------------------------
echo Starting Services
echo -----------------------------------------------------
sleep 2
service openvpn start
service squid3 start
service apache2 start
service fail2ban start
service stunnel4 start
sudo systemctl restart ocserv.service
clear
echo -----------------------------------------------------
echo Cleaning up
echo -----------------------------------------------------
sleep 2
sudo apt-get autoremove -y
sudo apt-get clean
history -c
clear
echo -----------------------------------------------------
echo "Installation is finish! Server Reboot in 3 seconds"
echo ------------------------------------------------------
echo "VPS Protection"
echo "   - Fail2Ban		: ON"
echo ""
echo "Application & Port Information"
echo "   - Openvpn TCP		: 1194"
echo "   - Openvpn SSL  	: 443"
sleep 1
echo ""
echo ""
echo "3"
sleep 1
echo "2"
sleep 1
echo "1"
sleep 1
echo "Done"
rm /root/instalar1.sh
reboot
