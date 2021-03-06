#!/bin/sh

### BEGIN INIT INFO
# Provides:          firewall.sh
# Required-Start:    $syslog $network
# Required-Stop:     $syslog $network
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Start firewall daemon at boot time
# Description:       Personalised Firewall scrip.
### END INIT INFO

# information (install sans github)
# 1 - créer le fichier sous /etc/init.d/firewall
# 2 - donner les droits :
#		$ sudo chmod +x /etc/init.d/firewall
# 3	- tester le firewall avec la commande :
#		$ sudo /etc/init.d/firewall
# 4 - Indiquer d'exécuter le script au démarrage
#		$ sudo update-rc.d firewall defaults 20
# 5 - Démarrage du firewall
#       $ sudo service firewall start

# information avec github
# $ sudo wget --no-check-certificate -O /etc/init.d/firewall.sh https://raw.github.com/honeyshell/firewall_mars/firewall.sh
# $ sudo chmod a+x /etc/init.d/firewall.sh
# $ sudo update-rc.d firewall.sh defaults 20
# $ sudo service firewall start

# lire les logs avec journalctl -xn

# BEGIN NO-FIREWALL Permet d'enlever completement le firewall
# iptables -F
# iptables -X
# iptables -t nat -F
# iptables -t nat -X
# iptables -t mangle -F
# iptables -t mangle -X
# iptables -P INPUT ACCEPT
# iptables -P FORWARD ACCEPT
# iptables -P OUTPUT ACCEPT
# END NO-FIREWALL

# NOTE
# trouver les ports des services
# i.e.: grep sane /etc/services
# commande pour reloader le firewall
# sudo service firewall.sh stop && sudo systemctl daemon-reload && sudo service firewall.sh start


# On efface les règles précédentes pour partir sur de bonnes bases
iptables -t filter -F
iptables -t filter -X

# On bloque par défaut tout le trafic
iptables -t filter -P INPUT DROP
iptables -t filter -P FORWARD DROP
iptables -t filter -P OUTPUT DROP

# On ne ferme pas les connexions déjà établies
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# On autorise le loopback
iptables -t filter -A INPUT -i lo -j ACCEPT
iptables -t filter -A OUTPUT -o lo -j ACCEPT

# ICMP (Ping)
iptables -t filter -A INPUT -p icmp -j ACCEPT
iptables -t filter -A OUTPUT -p icmp -j ACCEPT

# SSH / HTTPS
iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT

# SSH pour les machines locales
iptables -t filter -A INPUT -p tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp -s 192.168.1.0/24 --dport 22 -j ACCEPT

# Transmission WebUI
iptables -t filter -A OUTPUT -p tcp --dport 6001 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 6001 -j ACCEPT

# DNS
iptables -t filter -A OUTPUT -p tcp -s 192.168.1.0/24 --dport 53 -j ACCEPT
iptables -t filter -A OUTPUT -p udp -s 192.168.1.0/24 --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p tcp -s 192.168.1.0/24 --dport 53 -j ACCEPT
iptables -t filter -A INPUT -p udp -s 192.168.1.0/24 --dport 53 -j ACCEPT

# SERVER WEB APACHE
iptables -t filter -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -t filter -A INPUT -p tcp --dport 8443 -j ACCEPT

# SAMBA
# Ajouter -s 192.168.1.0/24 pour mettre en réseau local
iptables -t filter -A INPUT -p tcp -s 192.168.1.0/24 --dport 137:139 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp -s 192.168.1.0/24 --dport 137:139 -j ACCEPT
iptables -t filter -A INPUT -p udp -s 192.168.1.0/24 --dport 137:139 -j ACCEPT
iptables -t filter -A OUTPUT -p udp -s 192.168.1.0/24 --dport 137:139 -j ACCEPT
iptables -t filter -A INPUT -p tcp -s 192.168.1.0/24 --dport 445 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp -s 192.168.1.0/24 --dport 445 -j ACCEPT

# Ports à ouvrir pour les partages Windows via SAMBA
#LDAP
iptables -t filter -A INPUT -p tcp -s 192.168.1.0/24 --dport 389 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp -s 192.168.1.0/24 --dport 389 -j ACCEPT
#NETBIOS
iptables -t filter -A INPUT -p tcp -s 192.168.1.0/24 --dport 445 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp -s 192.168.1.0/24 --dport 445 -j ACCEPT
#SWAT
iptables -t filter -A INPUT -p tcp -s 192.168.1.0/24 --dport 901 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp -s 192.168.1.0/24 --dport 901 -j ACCEPT

# Ouverture port 110 pour pop3 vers gmail
iptables -t filter -A INPUT  -p tcp --dport 110 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 110 -j ACCEPT
iptables -t filter -A INPUT  -p tcp --dport 995 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 995 -j ACCEPT

# FTP
# iptables -t filter -A OUTPUT -p tcp --dport 20:21 -j ACCEPT
# iptables -t filter -A INPUT -p tcp --dport 20:21 -j ACCEPT

# FTP POUR OVH
# iptables -t filter -A OUTPUT -p tcp --dport 20:21 -j ACCEPT
# modprobe ip_conntrack_ftp
# iptables -t filter -A INPUT -p tcp --dport 20:21 -j ACCEPT
# iptables -t filter -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Mail SMTP
# iptables -t filter -A INPUT -p tcp --dport 25 -j ACCEPT
# iptables -t filter -A OUTPUT -p tcp --dport 25 -j ACCEPT

# Mail POP3
iptables -t filter -A INPUT -p tcp --dport 110 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp --dport 110 -j ACCEPT

# Mail POP3S:995
# iptables -t filter -A INPUT -p tcp --dport 995 -j ACCEPT
# iptables -t filter -A OUTPUT -p tcp --dport 995 -j ACCEPT

# Monit
# iptables -t filter -A INPUT -p tcp --dport 1337 -j ACCEPT

# Mail IMAP
# iptables -t filter -A INPUT -p tcp --dport 143 -j ACCEPT
# iptables -t filter -A OUTPUT -p tcp --dport 143 -j ACCEPT

# NTP (horloge du serveur)
iptables -t filter -A OUTPUT -p udp --dport 123 -j ACCEPT

# RPS OVH
# Si vous utilisez un serveur RPS d'OVH, le disque iSCSI
# nécessite un accès réseau qui rend obligatoire une règle
# supplémentaire au début des filtres. Sans cela, votre serveur
# deviendra inutilisable :
# iptables -A OUTPUT -p tcp --dport 3260 -m state --state NEW,ESTABLISHED -j ACCEPT

# CUPS : détection de l'imprimante sur le réseau
iptables -t filter -A INPUT -p udp -s 192.168.1.0/24 --dport 5353 -j ACCEPT
iptables -t filter -A OUTPUT -p udp -s 192.168.1.0/24 --dport 5353 -j ACCEPT
# CUPS
iptables -A INPUT  -p udp  --source 631  -m state --state NEW  -j ACCEPT
iptables -A INPUT  -p tcp  --destination-port 631  -m state --state NEW  -j ACCEPT
iptables -A INPUT  -p udp  --destination-port 631  -m state --state NEW  -j ACCEPT
iptables -A INPUT  -p icmp --icmp-type echo-request  -j ACCEPT
iptables -A INPUT  -p icmp --icmp-type echo-reply  -j ACCEPT
iptables -A INPUT  -p icmp --icmp-type destination-unreachable  -j ACCEPT
iptables -A INPUT  -p icmp --icmp-type source-quench -j ACCEPT
iptables -A INPUT  -p icmp --icmp-type time-exceeded -j ACCEPT
iptables -A INPUT  -p icmp --icmp-type parameter-problem -j ACCEPT

# SANE SCANNER : détection du scanner sur le réseau
iptables -t filter -A INPUT -p tcp -s 192.168.1.0/24 --dport 6566 -j ACCEPT
iptables -t filter -A INPUT -p tcp -s 192.168.1.0/24 --dport 10000:10100 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp -s 192.168.1.0/24 --dport 6566 -j ACCEPT
iptables -t filter -A OUTPUT -p tcp -s 192.168.1.0/24 --dport 10000:10100 -j ACCEPT

# Flood ou déni de service
iptables -A FORWARD -p tcp --syn -m limit --limit 1/second -j ACCEPT
iptables -A FORWARD -p udp -m limit --limit 1/second -j ACCEPT
iptables -A FORWARD -p icmp --icmp-type echo-request -m limit --limit 1/second -j ACCEPT
