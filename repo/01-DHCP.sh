#!/bin/bash
#
#VERSION 2.0
clear
#
#INSTALAR
#
#apt-get update
#apt-get install isc-dhcp-server
#
#CONFIGURACION1
#
echo -- Interfaz por la cual escuchara las peticiones --
echo -- Nombre de tarjeta de red --
read int
echo -- Tiempo de concesion --
read cos
echo -- Tiempo de concesion maximo --
read cosm
echo "# dhcpd.conf
#
# Sample configuration file for ISC dhcpd
#
# Attention: If /etc/ltsp/dhcpd.conf exists, that will be used as
# configuration file instead of this file.
#

# option definitions common to all supported networks...
#option domain-name \"example.org\";
#option domain-name-servers ns1.example.org, ns2.example.org;

default-lease-time $cos;
max-lease-time $cosm;

# The ddns-updates-style parameter controls whether or not the server will
# attempt to do a DNS update when a lease is confirmed. We default to the
# behavior of the version 2 packages ('none', since DHCP v2 didn't
# have support for DDNS.)
ddns-update-style none;
# If this DHCP server is the official DHCP server for the local
# network, the authoritative directive should be uncommented.
#authoritative;

# Use this to send dhcp log messages to a different log file (you also
# have to hack syslog.conf to complete the redirection).
#log-facility local7;

# No service will be given on this subnet, but declaring it helps the
# DHCP server to understand the network topology.
" > /etc/dhcp/dhcpd.conf
#
#CONFIGURACION2
#
con=0
echo -- Cuantas redes va a configurar --
read res
while [ $con -ne $res ]
do
echo -- Subred a configurar --
echo -- Direccion de red --
read sub
echo -- Mascara de subred --
read mas
echo -- Rango de concesiones --
echo -- xxx.xxx.xxx.xxx xxx.xxx.xxx.xxx --
read ccs
echo -- Direccion de broadcast --
read bro
echo -- Gateway --
read gw
echo -- DNSs --
echo -- "xxx.xxx.xxx.xxx, xxx.xxx.xxx.xxx"
read dns
echo "subnet $sub netmask $mas {
 range $ccs;
 option broadcast-address $bro;
 option routers $gw;
 option domain-name-servers $dns;
" >> /etc/dhcp/dhcpd.conf

con1=0
echo -- Cuantas reservas pose esta red --
read res1

while [ $con1 -ne $res1 ]
do
echo -- MAC del dispositivo de la reserva --
echo -- xx:xx:xx:xx:xx:xx --
read mac
echo -- Nombre de la reserva --
read re
echo -- IP a reservar --
read ip
echo " host $re {
   hardware ethernet $mac;
   fixed-address $ip;
 }
" >> /etc/dhcp/dhcpd.conf
con1=$((con1 + 1))
done

echo "}

#This is a very basic subnet declaration.

#subnet 10.254.239.0 netmask 255.255.255.224 {
#  range 10.254.239.10 10.254.239.20;
#  option routers rtr-239-0-1.example.org, rtr-239-0-2.example.org;
#}

# This declaration allows BOOTP clients to get dynamic addresses,
# which we don't really recommend.

#subnet 10.254.239.32 netmask 255.255.255.224 {
#  range dynamic-bootp 10.254.239.40 10.254.239.60;
#  option broadcast-address 10.254.239.31;
#  option routers rtr-239-32-1.example.org;
#}

# A slightly different configuration for an internal subnet.
#subnet 10.5.5.0 netmask 255.255.255.224 {
#  range 10.5.5.26 10.5.5.30;
#  option domain-name-servers ns1.internal.example.org;
#  option domain-name \"internal.example.org\";
#  option subnet-mask 255.255.255.224;
#  option routers 10.5.5.1;
#  option broadcast-address 10.5.5.31;
#  default-lease-time 600;
#  max-lease-time 7200;
#}

# Hosts which require special configuration options can be listed in
# host statements.   If no address is specified, the address will be
# allocated dynamically (if possible), but the host-specific information
# will still come from the host declaration.

#host passacaglia {
#  hardware ethernet 0:0:c0:5d:bd:95;
#  filename \"vmunix.passacaglia\";
#  server-name \"toccata.example.com\";
#}

# Fixed IP addresses can also be specified for hosts.   These addresses
# should not also be listed as being available for dynamic assignment.
# Hosts for which fixed IP addresses have been specified can boot using
# BOOTP or DHCP.   Hosts for which no fixed address is specified can only
# be booted with DHCP, unless there is an address range on the subnet
# to which a BOOTP client is connected which has the dynamic-bootp flag
# set.
#host fantasia {
#  hardware ethernet 08:00:07:26:c0:a5;
#  fixed-address fantasia.example.com;
#}

# You can declare a class of clients and then do address allocation
# based on that.   The example below shows a case where all clients
# in a certain class get addresses on the 10.17.224/24 subnet, and all
# other clients get addresses on the 10.0.29/24 subnet.

#class "foo" {
#  match if substring (option vendor-class-identifier, 0, 4) = \"SUNW\";
#}

#shared-network 224-29 {
#  subnet 10.17.224.0 netmask 255.255.255.0 {
#    option routers rtr-224.example.org;
#  }
#  subnet 10.0.29.0 netmask 255.255.255.0 {
#    option routers rtr-29.example.org;
#  }
#  pool {
#    allow members of \"foo\";
#    range 10.17.224.10 10.17.224.250;
#  }
#  pool {
#    deny members of \"foo\";
#    range 10.0.29.10 10.0.29.230;
#  }
#}" >> /etc/dhcp/dhcpd.conf
con=$((con + 1))
done

echo "# Default for isc-dhcp-server (sourced by /etc/init.d/isc-dhcp-server)

# Path to dhcpd´s config file (default: /etc/dhcp/dhcpd.conf) .
#DHCPDv4_CONF=/etc/dhcp/dhcpd.conf
#DHCPDv6_CONF=/etc/dhcp/dhcpd6.conf

# Path to dhcpd's PID file (default: /var/run/dhcpd.pid) .
#DHCPDv4_PID=/var/run/dhcpd.pid
#DHCPDv6_PID=/var/run/dhcpd6.pid

# Additional options to start dhcpd with.
#	Don't use options -cf or -pf here; use DHCP_CONF/ DHCPD_PID instead
#OPTIONS=""

# On what interfaces should the DHCP server (dhcpd) server DHCO request?
#	Separate multiple interfaces with spaces, e.g. \"eth0 eth1\".
INTERFACESv4=\"$int\"
INTERFACESv6=\"\"" > /etc/default/isc-dhcp-server

#
#REINICIAR SERVICIO
#
service isc-dhcp-server restart
