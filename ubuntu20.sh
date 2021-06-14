#!/bin/bash
rm -rf install*
echo "Installing" > /root/installing.txt
apt-get update -y && apt install screen -y
sudo timedatectl set-timezone Asia/Dubai
timedatectl
apt-get install openvpn easy-rsa -y
apt-get install net-tools screen sudo mysql-client nano fail2ban unzip apache2 build-essential curl build-essential libwrap0-dev libpam0g-dev libdbus-1-dev libreadline-dev libnl-route-3-dev libpcl1-dev libopts25-dev autogen libgnutls28-dev libseccomp-dev libhttp-parser-dev php libapache2-mod-php -y
mkdir -p /etc/openvpn/easy-rsa/keys
mkdir -p /etc/openvpn/login
mkdir -p /etc/openvpn/radius
mkdir -p /var/www/html/stat
touch /etc/openvpn/server.conf
touch /etc/openvpn/server2.conf

/bin/cat <<"EOM" >/etc/openvpn/login/auth_vpn
#!/bin/bash
username=`head -n1 $1 | tail -1`   
password=`head -n2 $1 | tail -1`

HOST='162.250.126.19'
USER='aoyovpnc_voltnetb'
PASS='@@Alaminzed10'
DB='aoyovpnc_voltnetb'

Query="SELECT user_name FROM users WHERE user_name='$username' AND user_encryptedPass=md5('$password') AND is_freeze='0' AND user_duration > 0"
user_name=`mysql -u $USER -p$PASS -D $DB -h $HOST -sN -e "$Query"`
[ "$user_name" != '' ] && [ "$user_name" = "$username" ] && echo "user : $username" && echo 'authentication ok.' && exit 0 || echo 'authentication failed.'; exit 1
EOM



echo 'mode server 
tls-server 
port 1194
proto tcp 
dev tun
keepalive 1 180
resolv-retry infinite 
max-clients 1000
ca /etc/openvpn/easy-rsa/keys/ca.crt 
cert /etc/openvpn/easy-rsa/keys/server.crt 
key /etc/openvpn/easy-rsa/keys/server.key 
dh /etc/openvpn/easy-rsa/keys/dh2048.pem 
client-cert-not-required 
username-as-common-name 
auth-user-pass-verify "/etc/openvpn/login/auth_vpn" via-file # 
tmp-dir "/etc/openvpn/" # 
server 172.20.0.0 255.255.0.0
push "redirect-gateway def1" 
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "sndbuf 393216"
push "rcvbuf 393216"
tun-mtu 1400 
mssfix 1360
verb 3
script-security 2
cipher AES-128-CBC
tcp-nodelay
up /etc/openvpn/update-resolv-conf                                                                                      
down /etc/openvpn/update-resolv-conf
status /var/www/html/stat/tcpstatus.txt
ifconfig-pool-persist /var/www/html/stat/ipp.txt' > /etc/openvpn/server.conf

echo 'mode server 
tls-server 
port 53
proto udp
dev tun
keepalive 1 180
resolv-retry infinite 
max-clients 1000
ca /etc/openvpn/easy-rsa/keys/ca.crt 
cert /etc/openvpn/easy-rsa/keys/server.crt 
key /etc/openvpn/easy-rsa/keys/server.key 
dh /etc/openvpn/easy-rsa/keys/dh2048.pem 
client-cert-not-required 
username-as-common-name 
auth-user-pass-verify "/etc/openvpn/login/auth_vpn" via-file # 
tmp-dir "/etc/openvpn/" # 
server 172.30.0.0 255.255.0.0
push "redirect-gateway def1" 
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "sndbuf 393216"
push "rcvbuf 393216"
tun-mtu 1400 
mssfix 1360
verb 3
cipher AES-128-CBC
tcp-nodelay
script-security 2
up /etc/openvpn/update-resolv-conf                                                                                      
down /etc/openvpn/update-resolv-conf
status /var/www/html/stat/udpstatus.txt
ifconfig-pool-persist /var/www/html/stat/udpipp.txt' > /etc/openvpn/server2.conf

cat << EOF > /etc/openvpn/easy-rsa/keys/ca.crt
-----BEGIN CERTIFICATE-----
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
xN1AdMMt3GXa
-----END CERTIFICATE-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/server.crt
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 1 (0x1)
        Signature Algorithm: sha1WithRSAEncryption
        Issuer: C=KS, ST=Riyadh, L=Riyadh, O=Al-amin, OU=saudiconnect, CN=Al-amin/name=Al-amin/emailAddress=saudiconnect24@gmail.com
        Validity
            Not Before: Jun 11 14:11:54 2021 GMT
            Not After : Jun  9 14:11:54 2031 GMT
        Subject: C=KS, ST=Riyadh, L=Riyadh, O=Al-amin, OU=saudiconnect, CN=server/name=Al-amin/emailAddress=saudiconnect24@gmail.com
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                RSA Public-Key: (4096 bit)
                Modulus:
                    00:ba:8f:ea:f3:db:dd:9a:26:d7:a1:a9:e5:79:56:
                    0e:82:ff:a8:9a:1f:9e:79:f4:52:a1:02:f8:a2:28:
                    08:97:8f:66:e5:2c:0c:1d:8e:fc:10:7f:05:b6:c0:
                    5a:5c:17:46:34:d1:0a:1e:2b:26:bb:5e:65:ef:e1:
                    7b:c5:a4:e6:22:e2:99:5c:12:bd:3a:59:a2:01:81:
                    d5:a6:09:96:33:d9:49:78:2e:6f:a1:0e:b7:5f:7b:
                    9a:f6:3e:f9:d6:5b:6a:53:50:cb:73:b6:f2:15:aa:
                    68:dd:10:0c:1e:e2:6d:ea:b1:3f:4c:d4:1d:00:bd:
                    19:81:f2:e1:ef:9f:78:2e:66:78:94:91:13:c0:e2:
                    d3:ba:6b:f9:1b:e6:21:3d:b7:57:4e:34:d0:4d:76:
                    bc:f5:b5:cf:03:d9:a5:73:a0:84:77:f2:d3:8c:87:
                    9b:27:1a:27:33:2c:c0:2c:65:c0:88:54:06:07:6a:
                    69:e0:26:2c:a4:94:e2:6a:f0:81:d3:51:c7:27:b5:
                    95:8b:e0:70:4b:19:ae:ef:b1:e0:66:7e:81:49:e1:
                    d4:c8:72:eb:1b:e2:12:40:23:0c:49:82:c9:6f:59:
                    e8:80:93:50:6f:e6:5a:e6:ff:af:12:9a:0d:de:5e:
                    1e:d7:8a:0d:ce:8c:18:73:b3:ab:65:be:4e:05:1c:
                    36:96:2e:9d:85:d6:fa:f9:5a:e0:2d:50:92:0a:9c:
                    64:b7:94:25:6e:32:68:af:aa:05:68:2a:42:2e:f2:
                    8f:f4:3f:72:b3:57:fc:9d:89:76:e9:62:ad:88:c1:
                    1b:9f:00:3b:16:01:be:a4:9e:9d:bc:85:0b:2d:2f:
                    d3:cd:14:70:4b:a5:4b:56:d7:b9:fb:15:f4:bb:cf:
                    52:ca:96:1a:5d:48:09:13:26:0a:00:3a:4e:5d:13:
                    a2:01:2c:07:8b:fe:27:f9:43:59:01:e1:e8:54:49:
                    af:6c:2d:e8:52:31:2f:ad:e6:dd:1b:9d:17:b2:dc:
                    d0:d3:ae:81:67:7c:ef:18:34:6a:ae:d0:e5:5c:10:
                    60:de:64:18:ff:8f:87:7a:52:48:cf:fb:76:83:98:
                    fd:74:df:c4:b9:3f:45:b2:28:49:9e:49:5e:ef:79:
                    63:c0:c9:a7:7c:da:a4:9b:fd:66:82:5f:0b:e9:7a:
                    ff:c2:c2:c4:ab:c1:d0:f9:db:9a:3a:cb:e7:58:46:
                    ec:c4:83:0a:78:8e:88:70:60:b3:5b:74:9d:09:6b:
                    07:eb:cf:f2:29:fd:20:d4:1c:4e:01:14:c1:a6:b6:
                    0a:74:d2:c4:eb:5c:c2:36:8e:a9:b9:f3:6f:72:a4:
                    c5:08:20:35:b1:80:c6:4b:f2:00:3e:16:40:4a:02:
                    b7:dd:07
                Exponent: 65537 (0x10001)
        X509v3 extensions:
            X509v3 Basic Constraints: 
                CA:FALSE
            Netscape Cert Type: 
                SSL Server
            Netscape Comment: 
                Easy-RSA Generated Server Certificate
            X509v3 Subject Key Identifier: 
                DF:C0:5D:5A:A9:EA:03:88:C5:51:85:7D:8A:BF:00:E1:A7:97:37:73
            X509v3 Authority Key Identifier: 
                keyid:CA:39:AF:DF:46:59:2C:34:88:95:B9:04:B4:27:8B:37:6B:4D:90:9B
                DirName:/C=KS/ST=Riyadh/L=Riyadh/O=Al-amin/OU=saudiconnect/CN=Al-amin/name=Al-amin/emailAddress=saudiconnect24@gmail.com
                serial:37:C9:37:E8:38:F2:46:14:C0:E8:F4:E2:16:26:46:24:D4:D7:6D:B8

            X509v3 Extended Key Usage: 
                TLS Web Server Authentication
            X509v3 Key Usage: 
                Digital Signature, Key Encipherment
    Signature Algorithm: sha1WithRSAEncryption
         8a:17:2e:8f:4f:55:1e:d4:5f:02:44:96:53:04:b2:d6:c9:71:
         d2:4b:18:6d:8b:9e:80:3b:15:ac:5b:25:d1:88:b7:40:db:4a:
         01:d8:24:4e:a4:e3:91:c7:f0:44:8a:00:2a:0a:4d:19:63:41:
         4f:bc:fa:34:89:f1:75:84:01:be:28:a7:c3:ba:af:82:0d:32:
         f9:c6:38:bf:4e:bb:fe:ce:ed:a6:42:c4:e4:fa:ad:f4:ef:08:
         65:a9:c6:c5:66:f4:07:c2:4d:b9:8b:23:8d:81:3e:34:1c:97:
         4f:7f:62:4b:8c:8a:04:d8:29:cb:18:d2:f3:9d:e7:b5:4d:0b:
         0f:e5:2e:14:58:20:aa:38:1c:95:90:12:4e:de:b5:1a:94:68:
         38:2a:11:c2:54:ba:6d:cf:94:5e:67:e6:44:cd:c8:d5:cf:75:
         d1:f7:7f:d8:b4:ac:1e:57:44:1a:d8:0f:fa:eb:d1:4c:14:4a:
         ae:1a:ea:eb:80:46:83:2b:bc:b3:bb:e5:2a:5c:a2:80:6a:c3:
         e7:01:b0:87:20:a7:2e:4b:c9:e1:6e:f1:bb:62:2a:b0:5b:1c:
         c0:81:dc:0f:d3:ab:71:e8:a6:1b:21:c6:74:7f:78:58:27:f7:
         35:4c:79:92:64:37:e1:2c:73:5a:2a:13:e4:13:5f:9f:4f:3a:
         4f:be:6f:41:df:5e:6e:fc:f7:32:9c:02:f2:1f:68:23:51:29:
         f5:22:67:9e:0c:5a:f0:21:de:19:77:f5:b6:8b:34:0c:dc:7f:
         b9:a3:1f:f8:a0:7c:e0:0b:f3:3b:81:60:19:45:bc:d8:34:84:
         94:31:be:94:27:7f:99:90:1d:ef:11:7e:db:9d:c8:73:f6:b7:
         91:00:1d:36:33:ea:c6:3a:bd:3e:1c:6d:9b:2f:31:50:56:a5:
         18:7d:ad:dc:27:54:2d:98:87:8e:cd:c5:2f:49:b6:31:eb:41:
         37:cf:e4:8d:69:04:a2:6b:0d:c9:2d:ce:34:b8:60:b4:a0:26:
         58:bd:db:df:c9:ea:40:07:ef:94:e0:3e:c5:23:10:e1:08:ba:
         55:19:74:4f:8b:b8:2e:1c:f7:93:04:85:7f:a3:6b:54:76:a9:
         5f:83:84:49:6b:2e:52:32:37:17:91:f7:9e:81:a2:ea:03:f8:
         d0:7d:a1:23:eb:a4:ba:f1:49:5c:d8:2d:c1:2e:de:67:c9:0a:
         8b:03:bf:3f:03:40:c7:f3:75:ee:f9:c3:bc:c6:81:68:49:a4:
         cb:6e:b9:3a:e5:b8:ab:27:c7:37:02:a3:ff:ae:ae:d2:41:6c:
         81:54:8a:a5:c9:fc:3c:cd:7e:9d:96:13:6f:15:96:15:97:1e:
         31:cc:d2:67:cb:a4:9c:6b
-----BEGIN CERTIFICATE-----
MIIHSTCCBTGgAwIBAgIBATANBgkqhkiG9w0BAQUFADCBpTELMAkGA1UEBhMCS1Mx
DzANBgNVBAgTBlJpeWFkaDEPMA0GA1UEBxMGUml5YWRoMRAwDgYDVQQKEwdBbC1h
bWluMRUwEwYDVQQLEwxzYXVkaWNvbm5lY3QxEDAOBgNVBAMTB0FsLWFtaW4xEDAO
BgNVBCkTB0FsLWFtaW4xJzAlBgkqhkiG9w0BCQEWGHNhdWRpY29ubmVjdDI0QGdt
YWlsLmNvbTAeFw0yMTA2MTExNDExNTRaFw0zMTA2MDkxNDExNTRaMIGkMQswCQYD
VQQGEwJLUzEPMA0GA1UECBMGUml5YWRoMQ8wDQYDVQQHEwZSaXlhZGgxEDAOBgNV
BAoTB0FsLWFtaW4xFTATBgNVBAsTDHNhdWRpY29ubmVjdDEPMA0GA1UEAxMGc2Vy
dmVyMRAwDgYDVQQpEwdBbC1hbWluMScwJQYJKoZIhvcNAQkBFhhzYXVkaWNvbm5l
Y3QyNEBnbWFpbC5jb20wggIiMA0GCSqGSIb3DQEBAQUAA4ICDwAwggIKAoICAQC6
j+rz292aJtehqeV5Vg6C/6iaH5559FKhAviiKAiXj2blLAwdjvwQfwW2wFpcF0Y0
0QoeKya7XmXv4XvFpOYi4plcEr06WaIBgdWmCZYz2Ul4Lm+hDrdfe5r2PvnWW2pT
UMtztvIVqmjdEAwe4m3qsT9M1B0AvRmB8uHvn3guZniUkRPA4tO6a/kb5iE9t1dO
NNBNdrz1tc8D2aVzoIR38tOMh5snGiczLMAsZcCIVAYHamngJiyklOJq8IHTUccn
tZWL4HBLGa7vseBmfoFJ4dTIcusb4hJAIwxJgslvWeiAk1Bv5lrm/68Smg3eXh7X
ig3OjBhzs6tlvk4FHDaWLp2F1vr5WuAtUJIKnGS3lCVuMmivqgVoKkIu8o/0P3Kz
V/ydiXbpYq2IwRufADsWAb6knp28hQstL9PNFHBLpUtW17n7FfS7z1LKlhpdSAkT
JgoAOk5dE6IBLAeL/if5Q1kB4ehUSa9sLehSMS+t5t0bnRey3NDTroFnfO8YNGqu
0OVcEGDeZBj/j4d6UkjP+3aDmP1038S5P0WyKEmeSV7veWPAyad82qSb/WaCXwvp
ev/CwsSrwdD525o6y+dYRuzEgwp4johwYLNbdJ0Jawfrz/Ip/SDUHE4BFMGmtgp0
0sTrXMI2jqm5829ypMUIIDWxgMZL8gA+FkBKArfdBwIDAQABo4IBgTCCAX0wCQYD
VR0TBAIwADARBglghkgBhvhCAQEEBAMCBkAwNAYJYIZIAYb4QgENBCcWJUVhc3kt
UlNBIEdlbmVyYXRlZCBTZXJ2ZXIgQ2VydGlmaWNhdGUwHQYDVR0OBBYEFN/AXVqp
6gOIxVGFfYq/AOGnlzdzMIHlBgNVHSMEgd0wgdqAFMo5r99GWSw0iJW5BLQnizdr
TZCboYGrpIGoMIGlMQswCQYDVQQGEwJLUzEPMA0GA1UECBMGUml5YWRoMQ8wDQYD
VQQHEwZSaXlhZGgxEDAOBgNVBAoTB0FsLWFtaW4xFTATBgNVBAsTDHNhdWRpY29u
bmVjdDEQMA4GA1UEAxMHQWwtYW1pbjEQMA4GA1UEKRMHQWwtYW1pbjEnMCUGCSqG
SIb3DQEJARYYc2F1ZGljb25uZWN0MjRAZ21haWwuY29tghQ3yTfoOPJGFMDo9OIW
JkYk1NdtuDATBgNVHSUEDDAKBggrBgEFBQcDATALBgNVHQ8EBAMCBaAwDQYJKoZI
hvcNAQEFBQADggIBAIoXLo9PVR7UXwJEllMEstbJcdJLGG2LnoA7FaxbJdGIt0Db
SgHYJE6k45HH8ESKACoKTRljQU+8+jSJ8XWEAb4op8O6r4INMvnGOL9Ou/7O7aZC
xOT6rfTvCGWpxsVm9AfCTbmLI42BPjQcl09/YkuMigTYKcsY0vOd57VNCw/lLhRY
IKo4HJWQEk7etRqUaDgqEcJUum3PlF5n5kTNyNXPddH3f9i0rB5XRBrYD/rr0UwU
Sq4a6uuARoMrvLO75SpcooBqw+cBsIcgpy5LyeFu8btiKrBbHMCB3A/Tq3Hophsh
xnR/eFgn9zVMeZJkN+Esc1oqE+QTX59POk++b0HfXm789zKcAvIfaCNRKfUiZ54M
WvAh3hl39baLNAzcf7mjH/igfOAL8zuBYBlFvNg0hJQxvpQnf5mQHe8RftudyHP2
t5EAHTYz6sY6vT4cbZsvMVBWpRh9rdwnVC2Yh47NxS9JtjHrQTfP5I1pBKJrDckt
zjS4YLSgJli929/J6kAH75TgPsUjEOEIulUZdE+LuC4c95MEhX+ja1R2qV+DhElr
LlIyNxeR956BouoD+NB9oSPrpLrxSVzYLcEu3mfJCosDvz8DQMfzde75w7zGgWhJ
pMtuuTrluKsnxzcCo/+urtJBbIFUiqXJ/DzNfp2WE28VlhWXHjHM0mfLpJxr
-----END CERTIFICATE-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/server.key
-----BEGIN PRIVATE KEY-----
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
2enkrpBa08g0xiA2VwtWHAkTtxg6uA==
-----END PRIVATE KEY-----
EOF

cat << EOF > /etc/openvpn/easy-rsa/keys/dh2048.pem
-----BEGIN DH PARAMETERS-----
MIIBCAKCAQEAxZ7IivANSuFPUxMyk3MbogNkz00VL9WOGHmyVKMZdzJgGkG8SJqL
CduS4P1XfjKoPAaaCn/nN7uMxtKH3RlXBoXE8RJr2FynM/QM19JARAJk9Q30JwbE
EinMAMYyScV8aahifUJlkR0IUCxAbmGfBAcN7bwXjSeORu6J4W12a4Nt//4LAfsX
QM7r2cHAgKGT4OfNc6plxGhyaUB3gJKIalZCh1q8kAcVzXCMYcTi4hCYGPNyEZ/s
CPkWVfraWa2IY8lMOiz63drMxdE/Y7ofWdhV29ptHn4gw/gMQ9BaXJCttxpKMXvr
gnEWkqb/UZqG6TFzpckxruG+QuoFaE0NwwIBAg==
-----END DH PARAMETERS-----
EOF

chmod +x /etc/openvpn/login/auth_vpn
chmod 755 /etc/openvpn/server.conf
chmod 755 /etc/openvpn/server2.conf
chmod 755 /etc/openvpn/login/auth_vpn
touch /var/www/html/stat/udpstatus.txt
touch /var/www/html/stat/tcpstatus.txt
chmod 755 /var/www/html/stat/*


sudo touch /etc/apt/sources.list.d/trusty_sources.list
echo "deb http://us.archive.ubuntu.com/ubuntu/ trusty main universe" | sudo tee --append /etc/apt/sources.list.d/trusty_sources.list > /dev/null
sudo apt update -y

sudo apt install -y squid3=3.3.8-1ubuntu6 squid=3.3.8-1ubuntu6 squid3-common=3.3.8-1ubuntu6
/bin/cat <<"EOM" >/etc/init.d/squid3
#! /bin/sh
#
# squid		Startup script for the SQUID HTTP proxy-cache.
#
# Version:	@(#)squid.rc  1.0  07-Jul-2006  luigi@debian.org
#
### BEGIN INIT INFO
# Provides:          squid
# Required-Start:    $network $remote_fs $syslog
# Required-Stop:     $network $remote_fs $syslog
# Should-Start:      $named
# Should-Stop:       $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Squid HTTP Proxy version 3.x
### END INIT INFO

NAME=squid3
DESC="Squid HTTP Proxy"
DAEMON=/usr/sbin/squid3
PIDFILE=/var/run/$NAME.pid
CONFIG=/etc/squid3/squid.conf
SQUID_ARGS="-YC -f $CONFIG"

[ ! -f /etc/default/squid ] || . /etc/default/squid

. /lib/lsb/init-functions

PATH=/bin:/usr/bin:/sbin:/usr/sbin

[ -x $DAEMON ] || exit 0

ulimit -n 65535

find_cache_dir () {
	w=" 	" # space tab
        res=`$DAEMON -k parse -f $CONFIG 2>&1 |
		grep "Processing:" |
		sed s/.*Processing:\ // |
		sed -ne '
			s/^['"$w"']*'$1'['"$w"']\+[^'"$w"']\+['"$w"']\+\([^'"$w"']\+\).*$/\1/p;
			t end;
			d;
			:end q'`
        [ -n "$res" ] || res=$2
        echo "$res"
}

grepconf () {
	w=" 	" # space tab
        res=`$DAEMON -k parse -f $CONFIG 2>&1 |
		grep "Processing:" |
		sed s/.*Processing:\ // |
		sed -ne '
			s/^['"$w"']*'$1'['"$w"']\+\([^'"$w"']\+\).*$/\1/p;
			t end;
			d;
			:end q'`
	[ -n "$res" ] || res=$2
	echo "$res"
}

create_run_dir () {
	run_dir=/var/run/squid3
	usr=`grepconf cache_effective_user proxy`
	grp=`grepconf cache_effective_group proxy`

	if [ "$(dpkg-statoverride --list $run_dir)" = "" ] &&
	   [ ! -e $run_dir ] ; then
		mkdir -p $run_dir
	  	chown $usr:$grp $run_dir
		[ -x /sbin/restorecon ] && restorecon $run_dir
	fi
}

start () {
	cache_dir=`find_cache_dir cache_dir`
	cache_type=`grepconf cache_dir`
	run_dir=/var/run/squid3

	#
	# Create run dir (needed for several workers on SMP)
	#
	create_run_dir

	#
	# Create spool dirs if they don't exist.
	#
	if test -d "$cache_dir" -a ! -d "$cache_dir/00"
	then
		log_warning_msg "Creating $DESC cache structure"
		$DAEMON -z -f $CONFIG
		[ -x /sbin/restorecon ] && restorecon -R $cache_dir
	fi

	umask 027
	ulimit -n 65535
	cd $run_dir
	start-stop-daemon --quiet --start \
		--pidfile $PIDFILE \
		--exec $DAEMON -- $SQUID_ARGS < /dev/null
	return $?
}

stop () {
	PID=`cat $PIDFILE 2>/dev/null`
	start-stop-daemon --stop --quiet --pidfile $PIDFILE --exec $DAEMON
	#
	#	Now we have to wait until squid has _really_ stopped.
	#
	sleep 2
	if test -n "$PID" && kill -0 $PID 2>/dev/null
	then
		log_action_begin_msg " Waiting"
		cnt=0
		while kill -0 $PID 2>/dev/null
		do
			cnt=`expr $cnt + 1`
			if [ $cnt -gt 24 ]
			then
				log_action_end_msg 1
				return 1
			fi
			sleep 5
			log_action_cont_msg ""
		done
		log_action_end_msg 0
		return 0
	else
		return 0
	fi
}

cfg_pidfile=`grepconf pid_filename`
if test "${cfg_pidfile:-none}" != "none" -a "$cfg_pidfile" != "$PIDFILE"
then
	log_warning_msg "squid.conf pid_filename overrides init script"
	PIDFILE="$cfg_pidfile"
fi

case "$1" in
    start)
	res=`$DAEMON -k parse -f $CONFIG 2>&1 | grep -o "FATAL: .*"`
	if test -n "$res";
	then
		log_failure_msg "$res"
		exit 3
	else
		log_daemon_msg "Starting $DESC" "$NAME"
		if start ; then
			log_end_msg $?
		else
			log_end_msg $?
		fi
	fi
	;;
    stop)
	log_daemon_msg "Stopping $DESC" "$NAME"
	if stop ; then
		log_end_msg $?
	else
		log_end_msg $?
	fi
	;;
    reload|force-reload)
	res=`$DAEMON -k parse -f $CONFIG 2>&1 | grep -o "FATAL: .*"`
	if test -n "$res";
	then
		log_failure_msg "$res"
		exit 3
	else
		log_action_msg "Reloading $DESC configuration files"
	  	start-stop-daemon --stop --signal 1 \
			--pidfile $PIDFILE --quiet --exec $DAEMON
		log_action_end_msg 0
	fi
	;;
    restart)
	res=`$DAEMON -k parse -f $CONFIG 2>&1 | grep -o "FATAL: .*"`
	if test -n "$res";
	then
		log_failure_msg "$res"
		exit 3
	else
		log_daemon_msg "Restarting $DESC" "$NAME"
		stop
		if start ; then
			log_end_msg $?
		else
			log_end_msg $?
		fi
	fi
	;;
    status)
	status_of_proc -p $PIDFILE $DAEMON $NAME && exit 0 || exit 3
	;;
    *)
	echo "Usage: /etc/init.d/$NAME {start|stop|reload|force-reload|restart|status}"
	exit 3
	;;
esac

exit 0
EOM

sudo chmod +x /etc/init.d/squid3
sudo update-rc.d squid3 defaults

echo "http_port 8080
acl to_vpn dst `curl ipinfo.io/ip`
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
http_access deny all"| sudo tee /etc/squid/squid.conf

apt-get install stunnel4 -y
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
/bin/cat <<"EOM" > /etc/stunnel/stunnel.pem
-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAsOdx7BIpOtL1xMXLAFppFvStFtn39VZlV2j+45Nm6MVhBxAT
NMQKbS1x10ajZfeBLDbSEa+cKPNHwyJDCPjVTGLlJVn/7ACOdVz9Xh264EpKQxWq
A4DWzvvVvxbngvQktIzHcTNEfJ9jPSYts0/hUQkmobAjdJc9RjnKs2Kvlqtew4Ed
iwYNbG+Jcuy9VgkaPrzwkyCYAc405EsRUez3fqCWtBVfz982tr6yggKQbq0b/9nR
bZHJNgYbMdEXJbIle/2CQsX+MW5BG0d+ikJJpdhUZfEjAq2xHpMOOZB5CJ4jMWMW
ND8FWv6pBKxtha7X57Yc6nJRAg+cBC94uVAUewIDAQABAoIBAASR5gqAKZqAaqLr
rSPUMhTKu1H0zYgD9Fg+uR7t5uGqf6gsDSL20YIig2dZRs1SiH6459JXJASWzErJ
LswjiXcQsvS1D3xsQ0Ha5hyxTeuPX7296Idwo5vzO4FVOSPT5MLZRCmzdlh10Z15
yAJy1NJAF0RkBXZ0lbujsI3Txc9xkODWwfJ9kH49A60HTxEX+uPsIqynbR3O2lGw
dHqRiT33+jzbjoGJ5ARSAxRM5AK/QxXntcx1SaT2La0T0BEqwnhvyuOnsKwlnRd2
9j0+iHDTE0rc0H329Wp0XabnE5/dilQK/gMc/vSHZZCUvzIH0VijK+szb3EarVjL
qygop7ECgYEA2SIEWWw1OSL5OGMwjzgT2Zva/TfjSfFMAcPv/pOJiw80g8BLJzZW
GhKg+a+ABpOBC+zTWk+tn2D63a1nC/Kfsvc/nTeIr6aH1OCofaECg/jKChEs623y
g83VEsVMWWIV8Yaj2yBHiZrY9RcdyvOsMmP6sSmeSaj/IZXHc1PV4RMCgYEA0JH3
u51z/P4VGdzuN25lJqSKw02dgn/N7+gjtGJzLZs9eEncKQK35ztSldhpY/T86Qlg
7ycaIVOiWtA/iBpMt+UF+RZXarFDrw1mpYxwqTG9rWI1ROvCrhWm1LQePcAPzQYH
pwbPZvSQcYy8Lu19rNrnCWjr0qUa/qtXi9lVU/kCgYApR0FCasLXgOGWKa0ynPuR
FAMWvog0J25Gq6Q1ZoDwccyO+4CODNNjk4UM0qNpHKOcy8IGWj1snjgy6mM7rz1S
/ZQXZFZU5jjObIM7lt9ujV6DeW5rt3QyQHAwaFeyamY3i1wdLU7MRybVuTZNvfNP
hRhEk9/mqv0Nuna3Ywm3BwKBgCoEriby8pIOUgvy0V8Dc4dUcMwlz8yhmMhzOPY3
O0L92mVoY90zOf9wmROtFJZZnbYI+KlVdFMweS3YdGQkAD6v+gMTeCr7aUpT5dEG
ORAtACx084xd/st5ezGw08LW9Zf1VgdVPOVd8deeZa8Ck2YGd7MSmyfFsWmK9Uks
UJ9pAoGBAInXwGORoyBSZ7yfhdGh2iBI6cvu75dTcxxnZ1/QCkz1+HG5GgSGqqc5
HoieaibgnC9yq53+SRGzjzz14NXlgJPlvhbGb/tjtdK5WHyZMF6rwHaZ1LGA8arJ
/oeUX2iAHN209ftFLh8AaSYDffpGsml0EeZCMjNDD3rcdUz+psW4
-----END RSA PRIVATE KEY-----
-----BEGIN CERTIFICATE-----
MIIEGzCCAwOgAwIBAgIUXss5tCURNxhtU6bDZPdgVjDK1c8wDQYJKoZIhvcNAQEL
BQAwgZwxCzAJBgNVBAYTAktTMQ8wDQYDVQQIDAZSaXlhZGgxDzANBgNVBAcMBlJp
eWFkaDEQMA4GA1UECgwHQWwtYW1pbjEXMBUGA1UECwwOc2F1ZGljb25uZWN0MjQx
FzAVBgNVBAMMDnNhdWRpY29ubmVjdDI0MScwJQYJKoZIhvcNAQkBFhhzYXVkaWNv
bm5lY3QyNEBnbWFpbC5jb20wHhcNMjEwNjExMTQzNjExWhcNMjQwNjEwMTQzNjEx
WjCBnDELMAkGA1UEBhMCS1MxDzANBgNVBAgMBlJpeWFkaDEPMA0GA1UEBwwGUml5
YWRoMRAwDgYDVQQKDAdBbC1hbWluMRcwFQYDVQQLDA5zYXVkaWNvbm5lY3QyNDEX
MBUGA1UEAwwOc2F1ZGljb25uZWN0MjQxJzAlBgkqhkiG9w0BCQEWGHNhdWRpY29u
bmVjdDI0QGdtYWlsLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEB
ALDncewSKTrS9cTFywBaaRb0rRbZ9/VWZVdo/uOTZujFYQcQEzTECm0tcddGo2X3
gSw20hGvnCjzR8MiQwj41Uxi5SVZ/+wAjnVc/V4duuBKSkMVqgOA1s771b8W54L0
JLSMx3EzRHyfYz0mLbNP4VEJJqGwI3SXPUY5yrNir5arXsOBHYsGDWxviXLsvVYJ
Gj688JMgmAHONORLEVHs936glrQVX8/fNra+soICkG6tG//Z0W2RyTYGGzHRFyWy
JXv9gkLF/jFuQRtHfopCSaXYVGXxIwKtsR6TDjmQeQieIzFjFjQ/BVr+qQSsbYWu
1+e2HOpyUQIPnAQveLlQFHsCAwEAAaNTMFEwHQYDVR0OBBYEFMg4k78uMVHhO/vy
09OB1uMrvfBsMB8GA1UdIwQYMBaAFMg4k78uMVHhO/vy09OB1uMrvfBsMA8GA1Ud
EwEB/wQFMAMBAf8wDQYJKoZIhvcNAQELBQADggEBAED4y9atrJkf+NhDbfrUkRc2
BxGZc1v/L9uTCAuu5tv90Ee34FmFzL/rrndi4StKfEl9hITpm6beg+ij5zDPnL1e
8nOvxDxG/GZVILw0wdlyLcN9dFx0LZvBo7KBpcBYNj8ZS3RraYrcNItjxy3bFAmf
uVGoVfSIwLsFckE2dbNAEZFIEe6diAPQcJ8lJL3gSKRmWH8XMI9xxP16YVbPSnzS
EMSYEiLKMwH5K85eknrSKKN5ps0Ms17Gg5gDqk83P5Vl+Xp9Jw/beAfUBzwkVw9w
ETA4+u4tiaFWPqKtv9LDtAp0D/XFzKsX7H/3aR78Xp43EQslFPM9c6PblzaAJH4=
-----END CERTIFICATE-----
EOM

echo 'cert=/etc/stunnel/stunnel.pem
socket = a:SO_REUSEADDR=1
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
client = no

[openvpn]
accept = 443
connect = 127.0.0.1:1194'| sudo tee /etc/stunnel/stunnel.conf

apt-get install netcat lsof php php-mysqli php-mysql php-gd php-mbstring python -y
cat << \socksopenvpn > /usr/local/sbin/proxy.py
#!/usr/bin/env python3
# encoding: utf-8
# SocksProxy By: Ykcir Ogotip Caayon
import socket, threading, thread, select, signal, sys, time
from os import system
system("clear")
#conexao
IP = '0.0.0.0'
try:
   PORT = int(sys.argv[1])
except:
   PORT = 8000
PASS = ''
BUFLEN = 8196 * 8
TIMEOUT = 60
MSG = 'StrongHoldVPN'
DEFAULT_HOST = '0.0.0.0:1194'
RESPONSE = "HTTP/1.1 200 " + str(MSG) + "\r\n\r\n"

class Server(threading.Thread):
    def __init__(self, host, port):
        threading.Thread.__init__(self)
        self.running = False
        self.host = host
        self.port = port
        self.threads = []
	self.threadsLock = threading.Lock()
	self.logLock = threading.Lock()

    def run(self):
        self.soc = socket.socket(socket.AF_INET)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.soc.settimeout(2)
        self.soc.bind((self.host, self.port))
        self.soc.listen(0)
        self.running = True

        try:                    
            while self.running:
                try:
                    c, addr = self.soc.accept()
                    c.setblocking(1)
                except socket.timeout:
                    continue
                
                conn = ConnectionHandler(c, self, addr)
                conn.start();
                self.addConn(conn)
        finally:
            self.running = False
            self.soc.close()
            
    def printLog(self, log):
        self.logLock.acquire()
        print log
        self.logLock.release()
	
    def addConn(self, conn):
        try:
            self.threadsLock.acquire()
            if self.running:
                self.threads.append(conn)
        finally:
            self.threadsLock.release()
                    
    def removeConn(self, conn):
        try:
            self.threadsLock.acquire()
            self.threads.remove(conn)
        finally:
            self.threadsLock.release()
                
    def close(self):
        try:
            self.running = False
            self.threadsLock.acquire()
            
            threads = list(self.threads)
            for c in threads:
                c.close()
        finally:
            self.threadsLock.release()
			

class ConnectionHandler(threading.Thread):
    def __init__(self, socClient, server, addr):
        threading.Thread.__init__(self)
        self.clientClosed = False
        self.targetClosed = True
        self.client = socClient
        self.client_buffer = ''
        self.server = server
        self.log = 'Conexao: ' + str(addr)

    def close(self):
        try:
            if not self.clientClosed:
                self.client.shutdown(socket.SHUT_RDWR)
                self.client.close()
        except:
            pass
        finally:
            self.clientClosed = True
            
        try:
            if not self.targetClosed:
                self.target.shutdown(socket.SHUT_RDWR)
                self.target.close()
        except:
            pass
        finally:
            self.targetClosed = True

    def run(self):
        try:
            self.client_buffer = self.client.recv(BUFLEN)
        
            hostPort = self.findHeader(self.client_buffer, 'X-Real-Host')
            
            if hostPort == '':
                hostPort = DEFAULT_HOST

            split = self.findHeader(self.client_buffer, 'X-Split')

            if split != '':
                self.client.recv(BUFLEN)
            
            if hostPort != '':
                passwd = self.findHeader(self.client_buffer, 'X-Pass')
				
                if len(PASS) != 0 and passwd == PASS:
                    self.method_CONNECT(hostPort)
                elif len(PASS) != 0 and passwd != PASS:
                    self.client.send('HTTP/1.1 400 WrongPass!\r\n\r\n')
                if hostPort.startswith(IP):
                    self.method_CONNECT(hostPort)
                else:
                   self.client.send('HTTP/1.1 403 Forbidden!\r\n\r\n')
            else:
                print '- No X-Real-Host!'
                self.client.send('HTTP/1.1 400 NoXRealHost!\r\n\r\n')

        except Exception as e:
            self.log += ' - error: ' + e.strerror
            self.server.printLog(self.log)
	    pass
        finally:
            self.close()
            self.server.removeConn(self)

    def findHeader(self, head, header):
        aux = head.find(header + ': ')
    
        if aux == -1:
            return ''

        aux = head.find(':', aux)
        head = head[aux+2:]
        aux = head.find('\r\n')

        if aux == -1:
            return ''

        return head[:aux];

    def connect_target(self, host):
        i = host.find(':')
        if i != -1:
            port = int(host[i+1:])
            host = host[:i]
        else:
            if self.method=='CONNECT':
                port = 1194
            else:
                port = 22

        (soc_family, soc_type, proto, _, address) = socket.getaddrinfo(host, port)[0]

        self.target = socket.socket(soc_family, soc_type, proto)
        self.targetClosed = False
        self.target.connect(address)

    def method_CONNECT(self, path):
    	self.log += ' - CONNECT ' + path
        self.connect_target(path)
        self.client.sendall(RESPONSE)
        self.client_buffer = ''
        self.server.printLog(self.log)
        self.doCONNECT()
                    
    def doCONNECT(self):
        socs = [self.client, self.target]
        count = 0
        error = False
        while True:
            count += 1
            (recv, _, err) = select.select(socs, [], socs, 3)
            if err:
                error = True
            if recv:
                for in_ in recv:
		    try:
                        data = in_.recv(BUFLEN)
                        if data:
			    if in_ is self.target:
				self.client.send(data)
                            else:
                                while data:
                                    byte = self.target.send(data)
                                    data = data[byte:]

                            count = 0
			else:
			    break
		    except:
                        error = True
                        break
            if count == TIMEOUT:
                error = True

            if error:
                break



def main(host=IP, port=PORT):
    print "\033[0;34mâ”"*8,"\033[1;32m PROXY SOCKS","\033[0;34mâ”"*8,"\n"
    print "\033[1;33mIP:\033[1;32m " + IP
    print "\033[1;33mPORTA:\033[1;32m " + str(PORT) + "\n"
    print "\033[0;34mâ”"*10,"\033[1;32m StrongHold","\033[0;34mâ”\033[1;37m"*11,"\n"
    server = Server(IP, PORT)
    server.start()
    while True:
        try:
            time.sleep(2)
        except KeyboardInterrupt:
            print '\nClosing...'
            server.close()
            break
if __name__ == '__main__':
    main()
socksopenvpn


cat << \autostart > /root/auto
#!/bin/bash
if nc -z localhost 80; then
    echo "SocksProxy running"
else
    echo "Starting Port 80"
    screen -dmS proxy2 python /usr/local/sbin/proxy.py 80
fi

if nc -z localhost 443; then
    echo "SocksProxy running"
else
    echo "Starting Port 443"
    service stunnel4 restart
fi
autostart

chmod +x /root/auto
/root/auto;
crontab -r
echo "SHELL=/bin/bash
* * * * * /bin/bash /root/auto >/dev/null 2>&1" | crontab -

/bin/cat <<"EOM" >/var/www/html/client.ovpn
client
dev tun
proto tcp
port 1194
remote X.X.X.X
cipher none
auth none
auth-user-pass
ping-timer-rem
redirect-gateway def1
setenv CLIENT_CERT 0
verb 3
<ca>
-----BEGIN CERTIFICATE-----
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
xN1AdMMt3GXa
-----END CERTIFICATE-----
</ca>
EOM


sed -i 's/Listen 80/Listen 81/g' /etc/apache2/ports.conf
service apache2 restart
update-rc.d stunnel4 enable
service stunnel4 restart
update-rc.d openvpn enable
update-rc.d apache2 enable
service apache2 restart
service openvpn restart
cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak
update-rc.d squid enable
echo 'root:@@Alaminbdx' | sudo chpasswd
reboot



