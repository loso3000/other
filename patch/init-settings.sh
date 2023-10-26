#!/bin/bash

# sed -i 's/string ListenIP.*/string ListenIP 0.0.0.0/g' /usr/libexec/softethervpn/vpn_server.config
uci -q set fstab.@global[0].check_fs=1
if ! ifname=$(uci -q get network.wan.ifname 2>/dev/null) ; then
      	 ifname=$(uci -q get network.lan.ifname 2>/dev/null) 
fi
ifname2=$(echo $ifname | sed -r 's/([a-z]{1,})([0-9]{1,}).*/\1\ \2/'  | awk -F ' '  '{print $1}')
a=$(ip address | grep ^[0-9] | awk -F: '{print $2}' | sed "s/ //g" | grep $ifname2 | grep -v "@" | grep -v "\." | awk -F '@' {'print $1'} | awk '{ if ( length($0) <5 ) print $0}')
# a=$(ip address | awk -F ': ' '/eth[0-9]+/ {print $2}' | awk -F '@' {'print $1'})
b=$(echo "$a" | wc -l)
	[ ${b} -gt 1 ] && {
	  lannet=""
	  for i in $(seq 1 $b)
	  do
		[ "$(uci -q get network.wan.ifname)" = "$(echo "$a" | sed -n ${i}p)" ] || lannet="${lannet} $(echo "$a" | sed -n ${i}p)"
	  done
	  uci -q set network.lan.ifname="${lannet}"
	}
uci commit network
uci commit fstab
uci set luci.main.mediaurlbase='/luci-static/kucat'
uci commit luci
uci set dhcp.@dnsmasq[0].port='53'
uci commit dhcp
sed -i '/coremark/d' /etc/crontabs/root
mv /etc/seccomp/umdns.json /etc/seccomp/umdns.1json
/etc/init.d/umdns restart
# sed -i "s/releases\/18.06.9/snapshots/g" /etc/opkg/distfeeds.conf
# ipv6
# sed -i 's/^[^#].*option ula/#&/' /etc/config/network
ntpd -n -q -p 1.lede.pool.ntp.org
exit 0
