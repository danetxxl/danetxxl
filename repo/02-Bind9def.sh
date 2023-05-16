# !/bin/bash
#
# VERSION: 1.3
clear
#
# INSTALL
#
apt-get update
apt-get install -y bind9
#
# ZONAS Directa
#
	echo -- Sufijo DNS --
	echo -- "Tunombre.local" --
		read suf
	echo -- Tipo de dns --
	echo -- slave or master --
		read tip
	echo -- Nombre del archivo --
	echo -- "db.tunombre.local" --
		read dir

if [ $tip = master ];
then
#1
echo "zone \"$suf\" {
	type $tip;
	file \"/etc/bind/$dir\";
};" >> /etc/bind/named.conf.local
#
else
#2
echo -- Direcion ip del master --
read ip
echo "zone \"$suf\" {
	type $tip;
	file \"/var/cache/bind/$dir\"
	masters { $ip;};
};" >> /etc/bind/named.conf.local
#
fi
#
#ZONA INVERSA
#
        echo -- Sufijo DNS --
        echo -- "xxx.xxx.xxx.in-addr.arpa" --
                read suf1
        echo -- Tipo de dns --
        echo -- slave or master --
                read tip1
        echo -- Nombre del archivo --
	echo -- "db.xxx.xxx.xxx.in-addr.arpa" --
                read dir1

if [ $tip = master ];
then
#1
echo "zone \"$suf1\" {
	type $tip1;
	file \"/etc/bind/$dir1\";
};" >> /etc/bind/named.conf.local
#
else
#2
echo -- Direccion ip del master --
read ip1
echo "zone \"$surf1\" {
	type $tip1;
	file \"/etc/bind/$dir1\";
	masters { $ip1;};
};" >> /etc/bind/named.conf.local
#
fi
#
# RESOLUCION 1
#
if [ $tip = master ];
then
clear
#1
echo -- Indique el tiempo de vida o TTL --
echo -- 604800 --
read time
echo ';BIND data file for direct zone
;
$TTL '"$time" > /etc/bind/$dir
#
#2
echo -- Correo electronico de administracion --
echo -- Sin @ y en su lugar un . --
read cor
echo -- Numero de serie --
echo -- 1 --
read serie
echo -- Tiempo de refrescado --
echo -- 604800 --
read refresh
echo -- Tiempo de reintento --
echo -- 86400 --
read rentry
echo -- Tiempo de expiracion --
echo -- 2419200 --
read expir
echo -- Tiempo de negative cache TTL --
echo -- 3600 --
read nttl
echo -- Ip del servidor --
read ipm
echo "@ IN SOA $(hostname).$suf. $cor (
	$serie ;Serial
	$refresh ;Refresh
	$rentry ;Rentry
	$expir ;Expire
	$nttl) ;Negative Cache TTL
;
@	   IN NS $(hostname).$suf.
@          IN A $ipm
$(hostname) IN A $ipm" >> /etc/bind/$dir
#
#3
con=0
echo -- Cuantos registros A extra va ha haber --
read res
while [ $con -ne $res ]
do
echo -- Nombre de la maquina --
read name
echo -- Ip de la maquina --
read ipm1
echo "$name IN A $ipm1" >> /etc/bind/$dir
con=$(($con + 1))
done
#
#4
con1=0
echo -- Cuantos registros cname va ha haber --
read res1
while [ $con1 -ne $res1 ]
do
echo -- Alias de la maquina --
read cname
echo -- Maquina del alias --
read alim
echo "$cname IN CNAME $alim.$suf." >> /etc/bind/$dir
con1=$(($con1 + 1))
done
#
#Registros MX
con4=0
echo -- Cuantos registris MX va ha haber --
read res4
while [ $con4 -ne $res4 ]
do
	echo -- Ip del MX --
	echo -- @ para el propio servidor --
	read mx
	echo -- Prioridad del MX --
	echo -- 10 --
	read prio
	echo -- FQDN del MX --
	read fqdnmx
	block=$(echo -e "$mx IN MX $prio $fqdnmx.")
	echo "$block" >> /etc/bind/$dir
	$(($con4 ++))
done
#
fi
#
# RESOLUCION 2
#
if [ $tip1 = master ];
then
#1
echo ';BIND data file for inverse zone
;
$TTL '"$time" > /etc/bind/$dir1
#
#2
echo -- Ultimo octeto de la Ip del servidor --
read digip
echo "@ IN SOA $suf1. $cor (
        $serie ;Serial
        $refresh ;Refresh
        $rentry ;Rentry
        $expir ;Expire
        $nttl) ;Negative Cache TTL
;
@          IN NS  $(hostname).$suf.
$digip     IN PTR $(hostname).$suf.
$digip     IN PTR $suf." >> /etc/bind/$dir1
#
#3
con2=0
echo -- Cuantos registros PTR extra va ha haber --
read res2
while [ $con2 -ne $res2 ]
do
echo -- Ultimo octeto del la ip de la maquina --
read digip1
echo -- Nombre de la maquina --
read maq
echo "$digip1 IN PTR $maq.$suf." >> /etc/bind/$dir1
con2=$(($con2 + 1))
done
#
fi
#
#Renvio
#
con3=0
echo -- Cuantos renviadores va ha haber --
read res3
if [ $res3 -ne 0 ]
then
echo "options {
		directory \"/var/cache/bind\";

		// If there is a firewall between you and nameservers you want
		// to talk to, you may need to fix the firewall to allow multiple
		// ports to talk.  See http://www.kb.cert.org/vuls/id/800113

		// If your ISP provided one or more IP addresses for stable 
		// nameservers, you probably want to use them as forwarders.  
		// Uncomment the following block, and insert the addresses replacing 
		// the all-0's placeholder.

		forwarders {" > /etc/bind/named.conf.options
fi
while [ $con3 -ne $res3 ]
do
echo -- Direccion ip del renviador --
echo -- 8.8.8.8 --
read renvi
echo "			$renvi;" >> /etc/bind/named.conf.options
con3=$(($con3 + 1))
done
if [ $res3 -ne 0 ]
then
echo "		};

		//========================================================================
		// If BIND logs error messages about the root key being expired,
		// you will need to update your keys.  See https://www.isc.org/bind-keys
		//========================================================================

		dnssec-validation auto;

		listen-on-v6 { any; };
};" >> /etc/bind/named.conf.options
fi
#
#Reinicio
#
service bind9 restart

#
#STATUS
#
service bind9 status
