#!/bin/sh
# Copyright (C) 2018-2021 small_5 & Kiddin9
# Copyright (C) 2022-2023 sirpdboy
NAME=bypass
VAR=/tmp/etc/$NAME
FWI=$(uci -q get firewall.$NAME.path ) || FWI=$VAR.include
T_FILE=/etc/$NAME
CRON_FILE=/etc/crontabs/root
SDNS=/tmp/etc/smartdns
DNS_T=$SDNS/smartdns_by.conf
DNS_T_TMP="${DNS_T}.tmp"
CON_T=$SDNS/rules.conf
CON_AD=$T_FILE/ad_smartdns.txt
PID=/tmp/run/smartdns.pid
LOG=/tmp/log/$NAME.log
[ ! -s $LOG ]  && touch $LOG
MDNS=/tmp/etc/mosdns
MDNS_D=/usr/share/bypass/gen_mosdns_default.yaml
MDNS_T=$MDNS/mosdns_by.yaml

ipt=$(command -v iptables-legacy || command -v iptables)
ip6t=$(command -v ip6tables-legacy || command -v ip6tables)

BIN_DIR=/usr/share/$NAME
DNS_FILE=/tmp/dnsmasq.d/dnsmasq-by.conf
DNS_DIR=/tmp/dnsmasq.d/dnsmasq-by.d
O=$DNS_DIR/tmp
CRON="grep -q $BIN_DIR $CRON_FILE && sed -i '/\/share\/bypass/d' $CRON_FILE"
ref=/tmp/resolv.conf.d/resolv.conf.auto;[ -s $ref ] || ref=/tmp/resolv.conf.auto
REF=$(cat $ref 2>/dev/null | grep nameserver | awk '{print$2}')
redir_tcp=0
kcp_enable=0
redir_udp=0
redir_nf=0
dns_flag=0
chinadns_flag=0
local_enable=0
switch_enable=0
switch_server=$1
server_count=0
PS="/bin/busybox ps"

uci_get_by_name() {
	local ret=$(uci get $NAME.$1.$2 2>/dev/null)
	echo ${ret:=$3}
}

uci_get_by_type() {
	local ret=$(uci get $NAME.@$1[0].$2 2>/dev/null)
	echo ${ret:=$3}
}

uci_set_by_name() {
	uci set $NAME.$1.$2=$3 2>/dev/null
	uci commit $NAME
}
GLOBAL_SERVER=$(uci_get_by_type global global_server)
adguardhome=$(uci_get_by_type global adguardhome 0)
gfw_mode=$(uci_get_by_type global gfw_mode 1)
run_mode=$(uci_get_by_type global run_mode router)
SO_SERVER=$(uci_get_by_type socks5_proxy server 0)
[ $SO_SERVER = same ] && SO_SERVER=$GLOBAL_SERVER
[ $(uci_get_by_name $SO_SERVER server) ] || SO_SERVER=
dns_local=$(uci_get_by_type global dns_local alidns_dot)
dns_mode=$(uci_get_by_type global dns_mode 1)
ipv6mode=$(uci_get_by_type global proxy_ipv6_mode 1)
bootstrap_dns=$(uci_get_by_type global bootstrap_dns '114.114.114.114')
socks5_ip=''
gen_log()(

	[ -s $LOG ] && echo -e '\n------------Start------------' >> $LOG
	log "Check network status."
)

log(){
	echo "$(date +'%Y-%m-%d %H:%M:%S') $*" >> $LOG
}

clean_log() {
	[ `cat $LOG  | wc -l ` -gt 500 ] && {
		echo "$(date "+%Y-%m-%d %H:%M:%S") LOG long ,clear log!" >$LOG
	}
}
f_bin(){
	ret=
	case $1 in
	ss) ret=$(which ss-redir);;
	ss-local) ret=$(which ss-local);;
	ss-server) ret=$(which ss-server);;
	ssr) ret=$(which ssr-redir);;
	ssr-local) ret=$(which ssr-local);;
	ssr-server) ret=$(which ssr-server);;
	v2ray) ret=$(which xray) || ret=$(which v2ray);;
	hysteria) ret=$(which hysteria);;
	trojan) ret=$(which trojan-plus);;
	naiveproxy) ret=$(which naive);;
	socks5|tun) ret=$(which redsocks2);;
	esac
	echo $ret
}

v2txray() {
#sed -i "s/option type 'vmess'/option type 'v2ray'\n\toption v2ray_protocol 'vmess'/g" /etc/config/$NAME
#sed -i "s/option type 'vless'/option type 'v2ray'\n\toption v2ray_protocol 'vless'/g" /etc/config/$NAME
sed -i "s/option encrypt_method_v2ray_ss/option encrypt_method_ss/g" /etc/config/$NAME
sed -i "s/option xtls/option tls/g" /etc/config/$NAME
sed -i "/option vless_flow/d" /etc/config/$NAME
sed -i "/option fingerprint 'disable'/d" /etc/config/$NAME

if [[ "$(grep "option uuid" /etc/config/$NAME)" ]]; then
idsum=$(grep -c "config servers" /etc/config/$NAME)
sed -i "s/option uuid/option vmess_id/" /etc/config/$NAME
for i in $(seq 0 $((idsum-1)))
do
	if [ "$(uci -q get $NAME.@servers[$i].type)" == 'vless' ];then
		uci -q set $NAME.@servers[$i].type='v2ray'
		uci -q set $NAME.@servers[$i].v2ray_protocol='vless'
	elif [ "$(uci -q get $NAME.@servers[$i].type)" == 'vmess' ];then
		uci -q set $NAME.@servers[$i].type='v2ray'
		uci -q set $NAME.@servers[$i].v2ray_protocol='vmess'
	fi
done
uci commit $NAME
fi
}

host_ip() {
	local host=$(uci_get_by_name $1 server)
	local ip=$host
	if [ -z "$(echo $host | grep -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}")" ]; then
		if [ "$host" == "${host#*:[0-9a-fA-F]}" ]; then
			ip=$(resolveip -4 -t 3 $host | awk 'NR==1{print}')
			[ -z "$ip" ] && ip=$(wget -q -O- http://119.29.29.29/d?dn=$host | awk -F ';' '{print $1}')
		fi
	fi
	[ -z "$ip" ] || uci_set_by_name $1 ip $ip
	if [ -n "$ip" ] ;then
	  log "Rules      : Get $(uci_get_by_name $1 alias) ip:$ip success!" 
	else
	  log "Rules      : Unable to get server address.Check domain name!"
	  exit 1
	fi
	if [ "$ip" != "$host" ]; then
		grep -q "$host" "$DNS_FILE" 2>"/dev/null" || \
		echo -e "address=/$host/$ip" >> "$DNS_FILE"
	fi
	echo $ip
}

gen_config_file(){
	type=$(uci_get_by_name $1 type)
	rtype=$2
	ssport=$3
	serv_ip=$4
	sport=$(uci_get_by_name $1 server_port)
	pass=$(uci_get_by_name $1 password)
	timeout=$(uci_get_by_name $1 timeout 60)
	case $rtype in
	tcp)
		[ $kcp_enable = 1 ] && hostip=127.0.0.1 || hostip=$server;PROTO=redir;lport=$local_port;fname=retcp;;
	udp)
		hostip=$udp_server;PROTO=redir;lport=$udp_local_port;fname=reudp;;
	nf)
		hostip=$nf_ip;lport=$nf_local_port;fname=nf;;
	socks)
		hostip=$socks5_ip;lport=$socks5_port;PROTO=socks;fname=socks5;;
	esac
	[ $(uci_get_by_name $1 fast_open 0) = 1 ] && fast=true || fast=false;
	[ "$socks5_start" = 1 ] && config_file=$VAR/$type-by-$fname-socks5.json || config_file=$VAR/$type-by-$fname.json
	log_file=$VAR/$type-by-$fname.log
	case $type in
	ss)
		cat <<-EOF >$config_file
			{
			"server":"$hostip",
			"server_port":$sport,
			"local_address":"0.0.0.0",
			"local_port":$lport,
			"password":"$pass",
			"timeout":$timeout,
			"method":"$(uci_get_by_name $1 encrypt_method_ss)",
			"reuse_port":true,
			"fast_open":$fast
			}
		EOF
		plugin=$(uci_get_by_name $1 plugin)
		if which $plugin >/dev/null 2>&1;then
			sed -i "s@$hostip\",@$hostip\",\n\"plugin\":\"$plugin\",\n\"plugin_opts\":\"$(uci_get_by_name $1 plugin_opts)\",@" $config_file
		fi
		;;
	ssr)
		cat <<-EOF >$config_file
			{
			"server":"$hostip",
			"server_port":$sport,
			"local_address":"0.0.0.0",
			"local_port":$lport,
			"password":"$pass",
			"timeout":$timeout,
			"method":"$(uci_get_by_name $1 encrypt_method)",
			"protocol":"$(uci_get_by_name $1 protocol)",
			"protocol_param":"$(uci_get_by_name $1 protocol_param)",
			"obfs":"$(uci_get_by_name $1 obfs)",
			"obfs_param":"$(uci_get_by_name $1 obfs_param)",
			"reuse_port":true,
			"fast_open":$fast
			}
		EOF
		;;
	naiveproxy)
		cat <<-EOF >$config_file
			{
			"listen":"$PROTO://0.0.0.0:$lport",
			"proxy":"https://$(uci_get_by_name $1 username):$pass@$(uci_get_by_name $1 server):$sport",
			"concurrency":"${3:-1}"
			}
		EOF
		;;
	v2ray)
		[ $rtype = udp ] && smode=udp || smode=tcp
		[ $rtype = socks ] && lport=0

		$BIN_DIR/genxrayconfig $1 $smode $lport $ssport $serv_ip >$config_file
		sed -i 's/\\//g' $config_file ;;
 
	hysteria)
		lua $BIN_DIR/gen_config $1 $smode $lport $ssport >$config_file
		;;

	trojan)
		case $rtype in
		tcp|udp|nf) smode=nat;;
		socks) smode=client;;
		esac
		lua $BIN_DIR/gen_config $1 $smode $lport "" $serv_ip >$config_file
		sed -i 's/\\//g' $config_file
		;;
	esac
}


start_dns()
{
        if [[ "x$dns_mode" = "x1" ]] ;then
	      service_start $(which smartdns) -c $DNS_T 2>/dev/null
	      dns_flag=1
	      case $run_mode in
			gfw)  
			   #service_start $(which chinadns-ng) -l 5337 -c '127.0.0.1#5336' -t '127.0.0.1#5335' -4 china_v4  -p 3 -6 china_v6 -f -n -m $VAR/gfw.list -M $([ $gfw_mode = 1 ] && echo -g $VAR/gfw.list) 
			   #log "ChinaDNS : Start ChinaDNS-NG success!"
			;;
			router)  
			   service_start $(which chinadns-ng) -l 5337 -c '127.0.0.1#5336' -t '127.0.0.1#5335' -4 china_v4  -p 3 -6 china_v6 -f -n $([ $gfw_mode = 1 ] && echo -g $VAR/gfw.list) 
			   log "ChinaDNS : Start ChinaDNS-NG success!"	
			;;
		esac
	 else
	      service_start $(which mosdns) start -c $MDNS_T 2>/dev/null
	      dns_flag=2
		case $run_mode in
			gfw)  
			   #service_start $(which chinadns-ng) -l 5337 -c "${bootstrap_dns}#53" -t '127.0.0.1#5335' -4 china_v4  -p 3 -6 china_v6 -f -n -m $VAR/gfw.list -M $([ $gfw_mode = 1 ] && echo -g $VAR/gfw.list) 
			   #log "ChinaDNS : Start ChinaDNS-NG success!"
			;;
			router)  
			   service_start $(which chinadns-ng) -l 5337 -c "127.0.0.1#5335" -t '127.0.0.1#5335' -4 china_v4  -p 3 -6 china_v6 -f -n $([ $gfw_mode = 1 ] && echo -g $VAR/gfw.list) 
		           log "ChinaDNS : Start ChinaDNS-NG success!"
			;;
		esac
	 fi
	if [[ "$(uci -q get dhcp.@dnsmasq[0].cachesize)" == "0" && $adguardhome == 0 ]]; then
		uci -q set dhcp.@dnsmasq[0].cachesize='1500'
		uci commit dhcp
	fi
}


check_net(){
	if ! curl -so /dev/null -m 3 www.baidu.com;then
		log "Rules     :Wait for network to connect..."
		/etc/init.d/dnsmasq restart
		$BIN_DIR/checknetwork check
		exit 1
	fi
}

get_soip(){
	if [ $SO_SERVER ];then
		if [ "$1" = 1 ];then
			cat $LOG 2>/dev/null | sed -n '$p' | grep -q 'Check network status...' || gen_log
			check_net
			cat $LOG 2>/dev/null | sed -n '$p' | grep -q 'Check network status successful!' || log "Rules      : Check network status successful!"
		fi
		socks5_ip=$(host_ip $SO_SERVER)
	fi
}

rules(){
	server=$(uci_get_by_name $GLOBAL_SERVER server)
	if [ ! $server ];then
		get_soip 1;return 1
	fi
	if ps -w | grep by-retcp | grep -qv grep;then
		log "Rules     :Bypass has Started.";return 1
	fi
	cat $LOG 2>/dev/null | sed -n '$p' | grep -q 'Check network status.\|Download IP/GFW files.' || gen_log
	check_net
	cat $LOG 2>/dev/null | sed -n '$p' | grep -q 'Download IP/GFW files...' || (log "Rules      : Check network status successful!";log "Rules      : Check IP/GFW files...")
	[ ! -d $VAR  ] && mkdir -p $VAR
	[ ! -d /tmp/run ] &&  mkdir -p /tmp/run 
	[ ! -s $VAR/china.txt ] || [ ! -s $VAR/china_v6.txt ] || [ ! -s $VAR/gfw.list ] && {
		if [ ! -s $T_FILE/china.txt ] || [ ! -s $T_FILE/china_v6.txt ] || [ ! -s $T_FILE/gfw.list ] ;then
			log "Rules      : Download IP/GFW files."
			$BIN_DIR/update --f ;exit 0;
		else
			cp -f $T_FILE/*.txt $VAR
			cp -f $T_FILE/gfw.list $VAR
		fi
	}
	log "Rules      : Check IP/GFW files success!"
	kcp_enable=$(uci_get_by_name $GLOBAL_SERVER kcp_enable 0)
	[ $kcp_enable = 1 ] && kcp_server=$server
	UDP_RELAY_SERVER=$(uci_get_by_type global udp_relay_server)
	[ "$UDP_RELAY_SERVER" = same ] && UDP_RELAY_SERVER=$GLOBAL_SERVER
	[ $(uci_get_by_name $UDP_RELAY_SERVER server) ] || UDP_RELAY_SERVER=
	if [ "$(uci_get_by_name $UDP_RELAY_SERVER kcp_enable)" = 1 ];then
		log "UDP Node: Can't use KCPTUN to start as UDP Relay Server!"
		UDP_RELAY_SERVER=
	fi
	NF_SERVER=$(uci_get_by_type global nf_server)
	[ "$NF_SERVER" = $GLOBAL_SERVER ] && NF_SERVER=
	server=$(host_ip $GLOBAL_SERVER)
	
	local_port=$(uci_get_by_name $GLOBAL_SERVER local_port 1234)
	lan_ac_ips=$(uci_get_by_type access_control lan_ac_ips)
	lan_ac_mode=$(uci_get_by_type access_control lan_ac_mode b)
	if [ $GLOBAL_SERVER = "$UDP_RELAY_SERVER" ];then
		UDP=1
		udp_server=$server
		udp_local_port=$local_port
	elif [ $UDP_RELAY_SERVER ];then
		udp_server=$(host_ip $UDP_RELAY_SERVER)
		udp_local_port=$(uci_get_by_name $UDP_RELAY_SERVER local_port 1234)
		UDP=1
	fi

	ttype=$(uci_get_by_name $GLOBAL_SERVER type)
	utype=$(uci_get_by_name $UDP_RELAY_SERVER type)
	if [ "$UDP" = 1 ];then
		[ $ttype = trojan -o $utype = trojan ] && [ $udp_local_port = $local_port ] && let udp_local_port=local_port+1;UDP="-S $udp_server -L $udp_local_port"
	fi

	case $run_mode in
		router)mode=-r;;
		oversea)mode=-c;;
		all)mode=-z;;
	esac

	[ $kcp_enable = 1 ] && kcp_server=$server
	if [ -n "$NF_SERVER" -a $run_mode != oversea ];then
		nf_ip=$(host_ip $NF_SERVER)

		ntype=$(uci_get_by_name $NF_SERVER type)
		nf_local_port=$(uci_get_by_name $NF_SERVER local_port 1234)
		[ $nf_local_port = $local_port ] && let nf_local_port=local_port+1
		[ "$utype" = trojan -o $ntype = trojan ] && [ $nf_local_port = "$udp_local_port" ] && let nf_local_port=nf_local_port+1
		NF=1
	fi
	[ "$NF" = 1 ] && NF="-N $nf_ip -P $nf_local_port"
	get_soip
	log "Rules      : Get all server address successful!"
	if [ -n "$lan_ac_ips" ];then
		case $lan_ac_mode in
			w|W|b|B)local ac_ips="$lan_ac_mode$lan_ac_ips";;
		esac
	fi

	dports=$(uci_get_by_type global dports 1)
	if [ $dports = 2 ];then
		proxyport="-m multiport --dports 22,53,80,143,443,465,587,853,993,995,9418"
	elif [ $dports != 1 ];then
		dports=$(echo $dports | sed 's/，/,/g')
		proxyport="-m multiport --dports $dports"
	fi

	r=1
	while ! $BIN_DIR/by-rules -s "$server" -l "$local_port" -a "$ac_ips" -b "$(uci_get_by_type access_control wan_bp_ips)" -w "$(uci_get_by_type access_control wan_fw_ips)" \
		-p "$(uci_get_by_type access_control lan_fp_ips)" -G "$(uci_get_by_type access_control lan_gm_ips)" -D "$proxyport" $mode $UDP $NF;do
		[ $r -ge 20 ] && log "Rules      : Start iptables rules failed!" && return 1
		let r++;sleep 1
	done
	log "Rules      : Start $run_mode iptables rules success!"
}

start_retcp(){
	rtype=tcp
	if [ $kcp_enable = 1 ];then
		cmd=$(which kcptun-client) || cmd=0
		[ ! $cmd ] && 	log "Main Node: Can't find KCPTUN program, start failed!" && return 1

		[ $($cmd -v 2>/dev/null | grep kcptun | wc -l) = 0 ] && return 1
		kcp_port=$(uci_get_by_name $GLOBAL_SERVER kcp_port)
		server_port=$(uci_get_by_name $GLOBAL_SERVER server_port)
		password=$(uci_get_by_name $GLOBAL_SERVER kcp_password)
		kcp_param=$(uci_get_by_name $GLOBAL_SERVER kcp_param)
		[ "$password" ] && password="--key "${password}
		service_start $cmd -r $kcp_server:$kcp_port -l :$server_port $password $kcp_param
	fi
	threads=$(uci_get_by_type global threads 0)
	[ $threads = 0 ] && threads=$(cat /proc/cpuinfo | grep 'processor' | wc -l)
	cmd=$(f_bin $ttype)
	[ ! $cmd ] && log "Main Node: Can't find $(echo $ttype | tr a-z A-Z) program, start failed!"  && return 1

	redir_tcp=1
	case $ttype in
	ss|ssr)
		gen_config_file $GLOBAL_SERVER $rtype
		redir_tcp=$threads
		for i in $(seq 1 $threads);do
			$cmd -c $config_file >/dev/null 2>&1 &
		done
		[ $ttype = ss ] && name=Shadowsocks || name=ShadowsocksR
		log "Main Node: $name $threads Threads Started!";;
	v2ray)
		if [ $SO_SERVER = $GLOBAL_SERVER ];then
			port=$(uci_get_by_type socks5_proxy local_port 1080)
			socks5_start=1
		else
			port=0
		fi
		gen_config_file $GLOBAL_SERVER $rtype $port $server
		$cmd run -c $config_file >/dev/null 2>&1 &
		log "Main Node: $($cmd -version | head -1 | awk '{print$1,$2}') Started!"
		if [ "$socks5_start" = 1 ];then
			log "Socks5 Node: $($cmd -version | head -1 | awk '{print$1,$2}') $ttype Started!"
		fi
		;;
	hysteria)
		if [ $SO_SERVER = $GLOBAL_SERVER ];then
			port=$(uci_get_by_type socks5_proxy local_port 1080)
			socks5_start=1
		else
			port=0
		fi
		gen_config_file $GLOBAL_SERVER $rtype $port $server

		$cmd -c $config_file >/dev/null 2>&1 &

		log "Main Node: $($cmd -version | head -1 | awk '{print$1,$2}') Started!"
		if [ "$socks5_start" = 1 ];then
			log "Socks5 Node: $($cmd -version | head -1 | awk '{print$1,$2}') $ttype Started!"
		fi;;
	trojan)
		gen_config_file $GLOBAL_SERVER $rtype "" $server
		redir_tcp=$threads
		for i in $(seq 1 $threads);do
			$cmd --config $config_file >/dev/null 2>&1 &
		done
		name=Trojan-Plus
		ver="$($cmd --version 2>&1 | head -1 | awk '{print$3}')"
		log "Main Node: $name (Ver $ver) $threads Threads Started!"
		;;
	naiveproxy)
		gen_config_file $GLOBAL_SERVER $rtype
		$cmd --config $config_file >/dev/null 2>&1 &
		log "Main Node: $($cmd --version | head -1) Threads Started!"
		;;
	socks5)
		redir_tcp=$threads
		$BIN_DIR/genred2config $VAR/redsocks-by-retcp.json socks5 tcp $local_port $server $(uci_get_by_name $GLOBAL_SERVER server_port) \
		$(uci_get_by_name $GLOBAL_SERVER auth_enable 0) $(uci_get_by_name $GLOBAL_SERVER username) $(uci_get_by_name $GLOBAL_SERVER password)
		for i in $(seq 1 $threads);do
			$cmd -c $VAR/redsocks-by-retcp.json >/dev/null 2>&1
		done
		log "Main Node: Socks5 $threads Threads Started!"
		;;
	tun)
		redir_tcp=$threads
		$BIN_DIR/genred2config $VAR/redsocks-by-retcp.json vpn $(uci_get_by_name $GLOBAL_SERVER iface br-lan) $local_port
		for i in $(seq 1 $threads);do
			$cmd -c $VAR/redsocks-by-retcp.json >/dev/null 2>&1
		done
		log "Main Node: Network Tunnel $threads Threads Started!"
		;;
	esac
	log "Main Node: Main Server $(uci_get_by_name $GLOBAL_SERVER alias)  Started!"
}

start_reudp(){
	rtype=udp
	cmd=$(f_bin $utype)
	[ ! $cmd ] && log "UDP Node: Can't find $(echo $utype | tr a-z A-Z) program, start failed!" && return 1

	redir_udp=1
	case $utype in
	ss|ssr)
		gen_config_file $UDP_RELAY_SERVER $rtype
		$cmd -c $config_file -U >/dev/null 2>&1 &
		[ $utype = ss ] && name=Shadowsocks || name=ShadowsocksR
		log "UDP Node: $name  $utype Started!"
		;;
	v2ray)
		$BIN_DIR/genxrayconfig $UDP_RELAY_SERVER $rtype $local_port $port $server >$config_file
		#gen_config_file $UDP_RELAY_SERVER $rtype 0 $udp_server
		$cmd  run -c $config_file >/dev/null 2>&1 &
		log "UDP Node: $($cmd -version | head -1 | awk '{print$1,$2}') $utype Started!"	;;
	trojan)
		gen_config_file $UDP_RELAY_SERVER $rtype "" $udp_server
		$cmd --config $config_file >/dev/null 2>&1 &
		name=Trojan-Plus
		ver="$($cmd --version 2>&1 | head -1 | awk '{print$3}')"
		log "UDP Node: $name (Ver $ver) $utype Started!"
		;;
	naiveproxy)
		gen_config_file $UDP_RELAY_SERVER $rtype
		redir_udp=0
		log "$($cmd --version | head -1) UDP Relay $utype not supported!"
		;;

	hysteria)
	
		gen_config_file $UDP_RELAY_SERVER $rtype 0 $udp_server
		$cmd -c $config_file >/dev/null 2>&1
		log "UDP Node: $($cmd -version | head -1 | awk '{print$1,$2}') $utype Started!"
		;;
	socks5)
		$BIN_DIR/genred2config $VAR/redsocks-by-reudp.json socks5 udp $udp_local_port $udp_server \
		$(uci_get_by_name $UDP_RELAY_SERVER server_port) $(uci_get_by_name $UDP_RELAY_SERVER auth_enable 0) $(uci_get_by_name $UDP_RELAY_SERVER username) $(uci_get_by_name $UDP_RELAY_SERVER password)
		$cmd --config $VAR/redsocks-by-reudp.json >/dev/null 2>&1
		log "UDP Node: Socks5 Started!"
		;;
	tun)
		redir_udp=0
		log "Network Tunnel UDP Relay $utype not supported!"
		;;
	esac
	log "UDP Node: UDP Server $(uci_get_by_name  $UDP_RELAY_SERVER alias)  Started!"
}

start_renf(){
	rtype=nf
	cmd=$(f_bin $ntype)
	[ ! $cmd ] && log "NF Shunt : Can't find $(echo $ntype | tr a-z A-Z) program, start failed!" && return 1
	redir_nf=1
	case $ntype in
	ss|ssr)
		gen_config_file $NF_SERVER $rtype
		$cmd -c $config_file >/dev/null 2>&1 &
		[ $ntype = ss ] && name=Shadowsocks || name=ShadowsocksR
		log "NF  Shunt : $name $ntype Started!"
		;;
	v2ray)
		gen_config_file $NF_SERVER $rtype 0 $nf_ip
		$cmd run -c $config_file >/dev/null 2>&1 &
		log "NF  Shunt : $($cmd -version | head -1 | awk '{print$1,$2}') $ntype Started!"
		;;
	hysteria)
		gen_config_file $NF_SERVER $rtype 0 $nf_ip
		$cmd -c $config_file >/dev/null 2>&1 &
		log "NF  Shunt : $($cmd -version | head -1 | awk '{print$1,$2}') $ntype Started!"
		;;
	trojan)
		gen_config_file $NF_SERVER $rtype "" $nf_ip
		$cmd --config $config_file >/dev/null 2>&1 &
		[ $ntype = trojan ] && {
			name=Trojan-Plus
			ver="$($cmd --version 2>&1 | head -1 | awk '{print$3}')"
		}
		log "NF  Shunt : $name (Ver $ver) $ntype Started!"
		;;
	naiveproxy)
		gen_config_file $NF_SERVER $rtype
		$cmd --config $config_file >/dev/null 2>&1 &
		log "NF  Shunt : $($cmd --version | head -1) $ntype Started!"
		;;
	socks5)
		$BIN_DIR/genred2config $VAR/redsocks-by-nf.json socks5 tcp $nf_local_port $nf_ip $(uci_get_by_name $NF_SERVER server_port) \
		$(uci_get_by_name $NF_SERVER auth_enable 0) $(uci_get_by_name $NF_SERVER username) $(uci_get_by_name $NF_SERVER password)
		$cmd -c $VAR/redsocks-by-nf.json >/dev/null 2>&1
		log "NF  Shunt : $ntype Started!"
		;;
	tun)
		$BIN_DIR/genred2config $VAR/redsocks-by-nf.json vpn $(uci_get_by_name $NF_SERVER iface "br-lan") $nf_local_port
		$cmd -c $VAR/redsocks-by-nf.json >/dev/null 2>&1
		log "NF  Shunt : Network Tunnel REDIRECT $ntype Started!"
		;;
	esac
	log "NF  Shunt : NF Server $(uci_get_by_name $NF_SERVER alias) $ntype Started!"
}

start_local(){
	rtype=socks
	[ $SO_SERVER = 0 -o "$socks5_start" = 1 ] && return
	type=$(uci_get_by_name $SO_SERVER type)
	[ $type = ss -o $type = ssr ] && cmd=$(f_bin $type-local) || cmd=$(f_bin $type)
	if [ ! -x $cmd ];then
		log "Socks5 Node: Can't find $(echo $type | tr a-z A-Z) program, start failed!";return 1
	fi
	socks5_port=$(uci_get_by_type socks5_proxy local_port 1080)
	local_enable=1
	[ ! -d $VAR ] && mkdir -p $VAR
	case $type in
	ss|ssr)
		gen_config_file $SO_SERVER $rtype
		$cmd -c $config_file -u >/dev/null 2>&1 &
		[ $type = ss ] && name=Shadowsocks || name=ShadowsocksR
		log "Socks5 Node: $name $type Started!"
		;;
	v2ray)
		gen_config_file $SO_SERVER $rtype $socks5_port $socks5_ip
		$cmd run -c $config_file >/dev/null 2>&1 &
		log "Socks5 Node: $($cmd -version | head -1 | awk '{print$1,$2}') $type Started!"
		;;
	hysteria)
		gen_config_file $SO_SERVER $rtype $socks5_port $socks5_ip
		$cmd -c $config_file >/dev/null 2>&1 &
		log "Socks5 Node: $($cmd -version | head -1 | awk '{print$1,$2}') $type Started!"
		;;
	trojan)
		gen_config_file $SO_SERVER $rtype "" $socks5_ip
		$cmd --config $config_file >/dev/null 2>&1 &
		[ $type = trojan ] && {
			name=Trojan-Plus
			ver="$($cmd --version 2>&1 | head -1 | awk '{print$3}')"
		}
		log "Socks5 Node: $name (Ver $ver) $type Started!"
		;;
	naiveproxy)
		gen_config_file $SO_SERVER $rtype
		$cmd --config $config_file >/dev/null 2>&1 &
		log "Socks5 Node: $($cmd --version | head -1) $type Started!"
		;;
	esac
	ipset add ss_spec_wan_ac $socks5_ip >/dev/null 2>&1 &
	log "Socks5 Node: Socks5 Server $(uci_get_by_name $SO_SERVER alias) Started!"
}


smartdns_append()
{
	echo "$*" >> $DNS_T_TMP
}

get_dns(){  #$1:name/dnslnk  $2:dns/dnsip
    case $1 in
		cloudflare_doh)dnslnk="https://1.1.1.1/dns-query";dnsip="1.1.1.1";;
		cloudflare2_doh)dnslnk="https://162.159.36.1/dns-query";dnsip="162.159.36.1";;
		google_doh)dnslnk="https://8.8.4.4/dns-query";dnsip="8.8.4.4";;
		google2_doh)dnslnk="https://8.8.8.8/dns-query";dnsip="8.8.8.8";;
		quad9_doh)dnslnk="https://9.9.9.9/dns-query";dnsip="9.9.9.9";;
		quad92_doh)dnslnk="https://149.112.112.112/dns-query";dnsip="149.112.112.112";;
		opendns_doh)dnslnk="https://146.112.41.2/dns-query";dnsip="208.67.222.222";;
		quad101tw_doh)dnslnk="https://101.101.101.101/dns-query";dnsip="101.101.101.101";;
		tiardns_doh)dnslnk="https://172.67.173.59/dns-query";dnsip="172.67.173.59" ;;
		tiardns2_doh)dnslnk="https://174.138.29.175/dns-query";dnsip="174.138.29.175" ;;
		tiardnsjp_doh)dnslnk="https://104.21.30.162/dns-query";dnsip="104.21.30.162";;
		tiardnsjp2_doh)dnslnk="https://172.104.93.80/dns-query";dnsip="172.104.93.80";;
		blahdnsgermany_doh)dnslnk="https://78.46.244.143/dns-query";dnsip="78.46.244.143";;
		blahdnsgermany2_doh)dnslnk="https://doh-de.blahdns.com/dns-query";dnsip="159.69.198.101";;
		ahadnsny_doh)dnslnk="https://185.213.26.187/dns-query";dnsip="185.213.26.187";;
		cloudflare_dot)dnslnk="tls://1.1.1.1:853";dnsip="1.1.1.1";;
		cloudflare2_dot)dnslnk="tls://1.0.0.1:853";dnsip="1.0.0.1";;
		google_dot)dnslnk="tls://dns.google:853";dnsip="8.8.4.4";;
		google2_dot)dnslnk="tls://8.8.8.8:853";dnsip="8.8.8.8";;
		quad9_dot)dnslnk="tls://dns.quad9.net:853";dnsip="9.9.9.9";;
		quad92_dot)dnslnk="tls://149.112.112.112:853";dnsip="149.112.112.112";;
		quad101tw_dot)dnslnk="tls://dns.twnic.tw:853";dnsip="101.101.101.101";;
		quad101tw2_dot)dnslnk="tls://101.102.103.104:853";dnsip="101.102.103.104";;
		tiardns_dot)dnslnk="tls://174.138.29.175:853,tls://dot.tiar.app:853";dnsip="174.138.29.175 174.138.21.128" ;;
		tiardnsjp_dot)dnslnk="tls://172.104.93.80:853,tls://jp.tiar.app:853";dnsip="172.104.93.80 104.21.30.162";;
		blahdnsgermany_dot)dnslnk="tls://78.46.244.143:853,tls://dot-de.blahdns.com:853";dnsip="78.46.244.143 159.69.198.101";;
		ahadnsny_dot)dnslnk="tls://185.213.26.187:853,tls://dot.ny.ahadns.net:853";dnsip="185.213.26.187";;
		cloudflare_tcp)dnslnk="tcp://1.1.1.1";dnsip="1.1.1.1";;
		cloudflare2_tcp)dnslnk="tcp://1.0.0.1";dnsip="1.0.0.1";;
		google_tcp)dnslnk="tcp://8.8.4.4";dnsip="8.8.4.4";;
		google2_tcp)dnslnk="tcp://8.8.8.8";dnsip="8.8.8.8";;
		quad9_tcp)dnslnk="tcp://9.9.9.9";dnsip="9.9.9.9";;
		quad92_tcp)dnslnk="tcp://149.112.112.112";dnsip="149.112.112.112";;
		opendns_tcp)dnslnk="tcp://208.67.222.222";dnsip="208.67.222.222";;
		opendns2_tcp)dnslnk="tcp://208.67.220.220";dnsip="208.67.220.220";;
		alidns_doh)dnslnk="https://223.5.5.5/dns-query";dnsip="223.5.5.5";;
		alidns2_doh)dnslnk="https://223.6.6.6/dns-query";dnsip="223.6.6.6";;
		dnspod_doh)dnslnk="https://175.24.219.66/dns-query";dnsip="175.24.219.66";;
		dnspod2_doh)dnslnk="https://162.14.21.178/dns-query";dnsip="162.14.21.178";;
		360dns_doh)dnslnk="https://101.198.191.4/dns-query";dnsip="101.226.4.6";;
		360dns2_doh)dnslnk="https://doh.360.cn/dns-query";dnsip="101.198.191.4";;	
		alidns_dot)dnslnk="tls://223.5.5.5:853,tls://223.6.6.6:853,tls://dns.alidns.com:853";dnsip="223.5.5.5 223.6.6.6";;
		dnspod_dot)dnslnk="tls://1.12.12.12:853,tls://dot.pub:853";dnsip="119.29.29.29 1.12.12.12";;
		360dns_dot)dnslnk="tls://23.6.48.18:853,tls://180.163.249.75:853,tls://dot.360.cn:853";dnsip="101.226.4.6 123.6.48.18";;
		alidns_tcp)dnslnk="tcp://223.5.5.5";dnsip="223.5.5.5";;
		dnspod_tcp)dnslnk="tcp://119.29.29.29";dnsip="119.29.29.29";;
		360dns_tcp)dnslnk="tcp://101.226.4.6";dnsip="101.226.4.6";;
		alidns2_tcp)dnslnk="tcp://223.6.6.6";dnsip="223.6.6.6";;
		dnspod2_tcp)dnslnk="tcp://119.28.28.28";dnsip="119.28.28.28";;
		360dns2_tcp)dnslnk="tcp://123.6.48.18";dnsip="123.6.48.18";;
		114dns_tcp)dnslnk="tcp://114.114.114.114";dnsip="114.114.114.114";;
		114dns2_tcp)dnslnk="tcp://114.114.115.115";dnsip="114.114.115.115";;
		baidu_tcp)dnslnk="tcp://180.76.76.76";dnsip="180.76.76.76";;
		isp)
			isp_dns=$REF
			[ ! "$isp_dns" ] && log "SmartDNS : Get isp Domestic DNS failed!" && return 1
			dnsip=$(echo $isp_dns | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | grep -v 0.0.0.0 | grep -v 127.0.0.1)
			dnslnk=$dnsip;;
		*)
			dnslnk=$(echo $1 | sed -e 's/，/,/g' -e 's/。/./g' -e 's/：/:/g' -e 's/,/\n/g')
			dnsip=$(echo $dnslnk |  awk -F/ '{print $3}')
			dnsip=$(echo $dnsip | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" | grep -v 0.0.0.0 | grep -v 127.0.0.1)
			if [ -z "$dnsip" ];then
				dnsip="223.5.5.5,223.6.6.6,2400:3200::1,2400:3200:baba::1"
			fi
			;;
		esac
		if [ "$2" == "dns" ];then 
			   echo $dnsip
		else
			   echo $dnslnk
		fi
}

gen_smartdns(){ 
	killall -q -9 smartdns
	killall -q -9 mosdns
	
	mkdir -p /tmp/run /tmp/dnsmasq.d $SDNS $DNS_DIR
	cat >$DNS_T_TMP <<-EOF
		speed-check-mode tcp:443,tcp:80,ping
		cache-persist yes
		cache-checkpoint-time 120
		force-qtype-SOA 65
		prefetch-domain yes
		serve-expired yes
		cache-size 32768
		log-level fatal
		log-file $LOG
		max-reply-ip-num 3
		cache-file /tmp/bysmartdns.cache
	EOF
	case $ipv6mode in
		1)
		        smartdns_append "force-AAAA-SOA no"
			smartdns_append "dualstack-ip-selection yes"
			smartdns_append "dualstack-ip-selection-threshold 100"
			BINDIPV6=" "
			;;
		 *)
			smartdns_append "dualstack-ip-selection no"
			smartdns_append "dualstack-ip-selection-threshold 20"
			smartdns_append "dualstack-ip-allow-force-AAAA no"
			BINDIPV6=" -force-aaaa-soa -no-dualstack-selection -no-rule-soa"
			;;
	 	esac
	smartdns_append "bind [::]:5335 -group a -no-speed-check -no-cache ${BINDIPV6}"
	smartdns_append "bind-tcp [::]:5335 -group a -no-speed-check -no-cache ${BINDIPV6}"
	smartdns_append "bind [::]:5336 -group e "
	smartdns_append "bind-tcp [::]:5336 -group e "
	
	case $run_mode in
		all)port=5335;;
		gfw|oversea)port=5336;;
		*)port=5337;;
	esac
	cat >$DNS_FILE <<-EOF
		no-resolv
		no-poll
		server=127.0.0.1#$port
	EOF
	if [ $run_mode = oversea ];then
		awk '!/^$/&&!/^#/{printf("server=/%s/'"127.0.0.1#5335"'\n",$0)}' $T_FILE/oversea.list >$DNS_DIR/oversea.conf
		awk '!/^$/&&!/^#/{printf("ipset=/%s/'"oversea"'\n",$0)}' $T_FILE/oversea.list >>$DNS_DIR/oversea.conf
	else
		[ $run_mode != gfw ] && echo -e "server=/msftconnecttest.com/127.0.0.1#5336\nserver=/msftncsi.com/127.0.0.1#5336" >> $DNS_FILE

		if [ $run_mode != all ];then
			cp -f $T_FILE/black.list $O
			awk '!/^$/&&!/^#/{printf("server=/%s/'"127.0.0.1#5335"'\n",$0)}' $O >$DNS_DIR/black.conf
			if [ $run_mode = gfw ];then
				cp -f $VAR/gfw.list $O
				awk '!/^$/&&!/^#/{printf("server=/%s/'"127.0.0.1#5335"'\n",$0)}' $O >>$DNS_DIR/black.conf
				smartdns_append "domain-set -name gfw-domain-rule-list -file $VAR/gfw.list"   #gfw
				smartdns_append "domain-rules /domain-set:gfw-domain-rule-list/  -nameserver a -dualstack-ip-selection no -address #6 -ipset blacklist"
			fi

		fi

	fi


    dns_remote=$(uci_get_by_type global dns_remote cloudflare_doh)
    for remote in $dns_remote;do
	dnsname=$(get_dns $remote)
	dns=$(get_dns $remote dns)
	for i in $dns;do
		case $run_mode in
			gfw|oversea) ipset add blacklist $i 2>/dev/null;;
			*) ipset del ss_spec_wan_ac $i 2>/dev/null || ipset add ss_spec_wan_ac $i nomatch 2>/dev/null;;
		esac
	done
	 remote_=`echo $remote | grep -o '_.*' `
	 case $remote_ in
		_doh) 
		        echo  $dnsname | sed 's/,/\n/g' | sed -e 's/^/server-https /g' -e 's/$/ -group a  -exclude-default-group/g' >> $DNS_T_TMP
			for i in $dns;do echo "server-tcp $i -group b -exclude-default-group" >>$DNS_T_TMP;done
		        dnsname_dom=$(echo $dnsname | sed 's/,/\n/g' | awk '-F[/:]' '{print$4}' | grep -Ev "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" | grep -Ev "\[[0-9]")
			if [ "$dnsname_dom" ];then
			   #for i in $dns;do smartdns_append "server-tcp $i -group b -exclude-default-group";done
			   for i in $dnsname;do smartdns_append "server $i -group b -exclude-default-group";done
			   for dom in $dnsname_dom;do 
				case $run_mode in
					router|all)smartdns_append "nameserver /$dom/b";;
					*)smartdns_append "domain-rules /$dom/ -nameserver b -ipset blacklist";;
				esac
				[ $run_mode = oversea ] && echo "server=/$dom/127.0.0.1#5335" >>$DNS_DIR/oversea.conf
				[ $run_mode = gfw ] && echo "server=/$dom/127.0.0.1#5335" >>$DNS_DIR/black.conf
			   done
			fi;;
		_dot)
			echo $dnsname | sed 's/,/\n/g' | sed -e 's/^/server-tls /g' -e 's/$/ -group a  -exclude-default-group/g' >> $DNS_T_TMP
			for i in $dns;do echo "server-tcp $i -group b -exclude-default-group" >>$DNS_T_TMP;done
		        dnsname_dom=$(echo $dnsname | sed 's/,/\n/g' | awk '-F[/:]' '{print$4}' | grep -Ev "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" | grep -Ev "\[[0-9]")
			if [ "$dnsname_dom" ];then
			   #for i in $dns;do smartdns_append "server-tcp $i -group b -exclude-default-group";done
			   for i in $dnsname;do smartdns_append "server $i -group b -exclude-default-group";done
			   for dom in $dnsname_dom;do
				case $run_mode in
					router|all)smartdns_append "nameserver /$dom/b";;
					*)smartdns_append "domain-rules /$dom/ -nameserver b -ipset blacklist";;
				esac
				[ $run_mode = oversea ] && echo "server=/$dom/127.0.0.1#5335" >>$DNS_DIR/oversea.conf
				[ $run_mode = gfw ] && echo "server=/$dom/127.0.0.1#5335" >>$DNS_DIR/black.conf
			   done
			fi;;
		*)
			for i in $dns;do smartdns_append "server-tcp $i -group a -exclude-default-group";done
		;;
	esac
	# for i in $dns;do smartdns_append "server $i -group b";done
	log "SmartDNS : start in $dnsname Remote DNS Resolution!"
    done
    echo -e "nameserver /dnsleaktest.com/a\nnameserver /whrq.net/a\nnameserver /speedtest.net/a\nnameserver /ooklaserver.net/a\nnameserver /in-addr.arpa/a\nnameserver /browserleaks.com/a\nnameserver /expressvpn.com/a\nnameserver /ipleak.net/a\nnameserver /whoer.net/a " >> $DNS_T_TMP
    dns_pollution=$(uci_get_by_type global dns_pollution 0)
    [ x$dns_pollution = 'x1' ] && dns_local=$(uci_get_by_type global dns_remote cloudflare_doh) || dns_local=$(uci_get_by_type global dns_local alidns_dot)
    for local in $dns_local;do
	dnsname=$(get_dns $local)
	dns=$(get_dns $local dns)
	 local_=`echo $local | grep -o '_.*' `
	 case $local_ in
		_doh) 
			 echo $dnsname | sed 's/,/\n/g' | sed -e 's/^/server-https /g' -e 's/$/ -group e  -exclude-default-group/g'  >> $DNS_T_TMP
			 for i in $dns;do smartdns_append "server-tcp $i -group f -exclude-default-group -whitelist-ip";done
			 dnsname_dom=$(echo $dnsname | sed 's/,/\n/g' | awk '-F[/:]' '{print$4}' | grep -Ev "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" | grep -Ev "\[[0-9]")
			 if [ "$dnsname_dom" ];then
				#for i in $dns;do smartdns_append server $i -group f -exclude-default-group;done
				for i in $dnsname;do smartdns_append server $i -group f -exclude-default-group;done
				for i in $dnsname_dom;do smartdns_append "domain-rules /$i/ -nameserver f -ipset ss_spec_wan_ac"
					[ $run_mode = all ] && echo "server=/$i/127.0.0.1#5336" >$DNS_DIR/white.conf
				done
			fi;;
		_dot)
			echo $dnsname | sed 's/,/\n/g' | sed -e 's/^/server-tls /g' -e 's/$/ -group e  -exclude-default-group/g'  >> $DNS_T_TMP
			for i in $dns;do smartdns_append "server-tcp $i -group f -exclude-default-group -whitelist-ip";done
			dnsname_dom=$(echo $dnsname | sed 's/,/\n/g' | awk '-F[/:]' '{print$4}' | grep -Ev "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$" | grep -Ev "\[[0-9]")
			if [ "$dnsname_dom" ];then
				#for i in $dns;do smartdns_append "server $i -group f -exclude-default-group";done
				for i in $dnsname;do smartdns_append "server $i -group f -exclude-default-group";done
				for i in $dnsname_dom;do smartdns_append "domain-rules /$i/ -nameserver f -ipset ss_spec_wan_ac"
					[ $run_mode = all ] && echo "server=/$i/127.0.0.1#5336" >$DNS_DIR/white.conf
				done
			fi;;
		*)
			for i in $dns;do smartdns_append "server $i -group e ";done;;
	 esac
	for i in $dns;do ipset add ss_spec_wan_ac $i 2>/dev/null;done
	log "SmartDNS : start in $dnsname Local DNS Resolution!"
    done

    smartdns_append "nameserver /in-addr.arpa/e"
    if [ "$NF" ];then
	dns_nf=$(uci_get_by_type global nf_dns google_dot)
	for dnsnf in $dns_nf;do
	   dnsname=$(get_dns $dnsnf)
	   dns=$(get_dns $dnsnf dns)
	   for i in $dns;do ipset add netflix $i 2>/dev/null;done
	   dnsnf_=`echo $dnsnf | grep -o '_.*' `
	   case $dnsnf_ in
	 	_doh) 
		        echo $dnsname | sed 's/,/\n/g' | sed -e 's/^/server-https /g' -e 's/$/ -group h  -exclude-default-group/g'  >> $DNS_T_TMP
			dnsname_dom=$(echo $dnsname | sed 's/,/\n/g' | awk -F[/:] '{print$4}' | grep -Ev "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$")
			if [ "$dnsname_dom" ];then
				for i in $dnsname;do smartdns_append "server-tcp $i -group i -exclude-default-group";done
				for i in $dnsname_dom;do smartdns_append "domain-rules /$i/ -nameserver i -ipset netflix"
				[ -s $DNS_DIR/black.conf ] && sed -i -e "/\/$i/d" -e "/\.$i/d" $DNS_DIR/black.conf
				done
			fi;;
		_dot)
		        echo $dnsname | sed 's/,/\n/g' | sed -e 's/^/server-tls /g' -e 's/$/ -group h  -exclude-default-group/g'  >> $DNS_T_TMP
			dnsname_dom=$(echo $dnsname | sed 's/,/\n/g' | awk -F[/:] '{print$4}' | grep -Ev "^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$")
			if [ "$dnsname_dom" ];then
				for i in $dnsname;do smartdns_append "server-tcp $i -group i -exclude-default-group";done
				for i in $dnsname_dom;do smartdns_append "domain-rules /$i/ -nameserver i -ipset netflix"
				[ -s $DNS_DIR/black.conf ] && sed -i -e "/\/$i/d" -e "/\.$i/d" $DNS_DIR/black.conf
				done
			fi;;
		*)
			for i in $dns;do smartdns_append "server $i -group h -exclude-default-group";done;;
	    esac
	    log "SmartDNS : start in $dnsname netflix DNS Resolution!"
	done
    fi
        
	
	[ "$bootstrap_dns" ] && {
	for i in $bootstrap_dns;do smartdns_append "server $i -bootstrap-dns";done 
	log "SmartDNS : start in $bootstrap_dns Bootstrap DNS Resolution!"
	}

	if [ $run_mode != oversea ];then

		if [ -s $DNS_DIR/black.conf ];then
			echo "$(sort -u $DNS_DIR/black.conf)" >$DNS_DIR/black.conf
			sed -e 's/.*=/ipset /g' -e 's/127.0.0.1#5335/blacklist/g' $DNS_DIR/black.conf >$CON_T
		else
			rm -f $DNS_DIR/black.conf
		fi

		if [ -n "$NF" ];then
			cp -f $T_FILE/netflix.list $O
			D=$(cat $O)
			for i in $D;do
				sed -i -e "/\/$i\//d" -e "/\.$i\//d" $DNS_DIR/black.conf 2>/dev/null
				sed -i -e "/\/$i\//d" -e "/\.$i\//d" $CON_T 2>/dev/null
				echo "domain-rules /$i/ -nameserver c -ipset netflix" >>$CON_T
			done
			if [ $run_mode = gfw ];then
				awk '!/^$/&&!/^#/{printf("server=/%s/'"127.0.0.1#5335"'\n",$0)}' $O >>$DNS_DIR/black.conf
			fi
		fi

		if [ -s $T_FILE/white.list ];then
			cp -f $T_FILE/white.list $O
			sed -i "s/\r//g" $O
			D=$(cat $O)
			for i in $D;do
				sed -i -e "/\/$i\//d" -e "/\.$i\//d" $DNS_DIR/black.conf 2>/dev/null
				sed -i -e "/\/$i\//d" -e "/\.$i\//d" $CON_T 2>/dev/null
			done
			awk '!/^$/&&!/^#/{printf("server=/%s/'"127.0.0.1#5336"'\n",$0)}' $O >>$DNS_DIR/white.conf
			awk '!/^$/&&!/^#/{printf("ipset /%s/'"ss_spec_wan_ac"'\n",$0)}' $O >>$CON_T
		fi
		if [ -s $T_FILE/domains_cn.txt ];then
			cp -f $T_FILE/domains_cn.txt $VAR/domains_cn.txt
			sed -i "s/\r//g" $O
			awk '!/^$/&&!/^#/{printf("server=/%s/'"127.0.0.1#5336"'\n",$0)}' $O >>$DNS_DIR/white.conf
			# awk '!/^$/&&!/^#/{printf("ipset /%s/'"ss_spec_wan_ac"'\n",$0)}' $O >>$CON_T
			echo "domain-set -name domains-cn-rule-list -file $VAR/domains_cn.txt" >>$DNS_T_TMP
			echo "domain-rules /domain-set:domains-cn-rule-list/  -nameserver f -dualstack-ip-selection no -address #6 -ipset ss_spec_wan_ac" >>$DNS_T_TMP
		fi
	fi
	
	[ -s $CON_T ] && echo "conf-file $CON_T" >>$DNS_T_TMP
	# no AD 
	ad_list=$(uci -q get bypass.@global[0].ad_list)
	[[ $ad_list = 1  && -s $T_FILE/ad_list.txt ]] && {
	   cp -f $T_FILE/ad_list.txt $O
	   if [ -f "$O" ]; then
			for line in $(cat $T_FILE/black.list); do sed -i "/$line/d" $O; done
			for line in $(cat $T_FILE/white.list); do sed -i "/$line/d" $O; done
			for line in $(cat $T_FILE/domain-block.list); do sed -i "/$line/d" $O; done
	   fi
	   cat  $O | sed '/^$/d' | sed '/#/d' | sed "/.*/s/.*/address=\/&\//" >$DNS_DIR/ad_list.txt
	   cat  $O | grep -v "^#" | awk '{print "address /"$2"/#"}' > $VAR/ad_list.txt
	   smartdns_append "conf-file $VAR/ad_list.txt"
	}
	rm -f $O
	[ $(find $DNS_DIR -name \* -exec cat {} \; 2>/dev/null | wc -l) = 0 ] && rm -rf $DNS_DIR
	echo "conf-dir=${DNS_DIR}" >$DNS_FILE
	[ $run_mode = router ] && chinadns_flag=1
	mv -f $DNS_T_TMP $DNS_T
	start_dns

	/etc/init.d/dnsmasq restart >/dev/null 2>&1
	$BIN_DIR/by-preload $run_mode
}

mget_dns(){ #$1 name  $2 dns
	if [ "$2" == "dns" ];then 
		for i in $1;do echo $(get_dns $i $2);done
	else
		for i in $1;do echo $(get_dns $i);done
	fi

}

add_dns_ipset() { #$1 ip  $2dns
if [ "$2" == "dns" ];then 
	dns=$(echo $1 | awk -F/ '{print $3}')
	[ "$dns" ] ||  dns=${1%:*}
	[ "$dns" ] || return
	case $run_mode in
	gfw|oversea) ipset add blacklist ${dns%:*} 2>/dev/null;;
	*) ipset del ss_spec_wan_ac ${dns%:*} 2>/dev/null || ipset add ss_spec_wan_ac ${dns%:*} nomatch 2>/dev/null;;
        esac
else
	case $run_mode in
	router|all)smartdns_append "nameserver /$1/$2";;
	*)smartdns_append "domain-rules /$1/ -nameserver $2 -ipset blacklist";;
	esac
fi
}


gen_mosdns(){
   TMPDIR=$(mktemp -d) || exit 1
   
   mkdir -p /tmp/run /tmp/dnsmasq.d $DNS_DIR $MDNS 

   killall -q -9 smartdns
   killall -q -9 mosdns
	case $run_mode in
		all)port=5335;;
		gfw|oversea)port=5335;;
		*)port=5337;;
	esac
	cat >$DNS_FILE <<-EOF
		no-resolv
		no-poll
		server=127.0.0.1#$port
	EOF

   # Remote DNS
   dns_remote=`mget_dns "$(uci_get_by_type global dns_remote cloudflare_doh)" `
   remote_dns=$(for i in  $dns_remote; do
                                add_dns_ipset $i dns
				log "MosDNS : start in $i Remote DNS Resolution!"
				echo "        - addr: $i"
				echo "          bootstrap: ${bootstrap_dns}"
				echo "          enable_pipeline: true"
				echo "          max_conns: 2"
			done)

   #local DNS IPSET
   dns_local=`mget_dns "$(uci_get_by_type global dns_local alidns_dot)" `
   local_dns=$(for i in $dns_local; do
				echo "        - addr: $i"
				echo "          bootstrap: ${bootstrap_dns}"
				echo "          enable_pipeline: true"
				echo "          max_conns: 2"
			done)

    sed "s,DNS_PORT,5335,g" $MDNS_D > $MDNS_T
    # DNS
    echo "${local_dns}" > $TMPDIR/local_dns.txt
    echo "${remote_dns}" > $TMPDIR/remote_dns.txt
    sed -i -e '/- addr: local_dns/{r '$TMPDIR/local_dns.txt -e';d};/- addr: remote_dns/{r '$TMPDIR/remote_dns.txt -e';d}' $MDNS_T

    # DNS pollution
    dns_pollution=$(uci_get_by_type global dns_pollution 0)
    if [ x$dns_pollution = 'x1' ] ;then 
          sed -i "s/POLLUTION/query_is_remote/g" $MDNS_T
	  for i in  $dns_remote; do log "MosDNS : start in $i Local DNS Resolution!" ;done
    else
	  sed -i "s/POLLUTION/query_is_local_ip/g"  $MDNS_T
	  for i in  $dns_local; do log "MosDNS : start in $i Local DNS Resolution!" ;done
    fi
    [ "x$ipv6mode" == "x1" ] && sed -i "s/IPV6MODE/remote_sequence_IPv6/g" $MDNS_T || sed -i "s/IPV6MODE/remote_sequence/g" $MDNS_T
	if [ $run_mode = oversea ];then
		awk '!/^$/&&!/^#/{printf("server=/%s/'"127.0.0.1#5335"'\n",$0)}' $T_FILE/oversea.list >$DNS_DIR/oversea.conf
		awk '!/^$/&&!/^#/{printf("ipset=/%s/'"oversea"'\n",$0)}' $T_FILE/oversea.list >>$DNS_DIR/oversea.conf
	else
		[ $run_mode != gfw ] && echo -e "server=/msftconnecttest.com/127.0.0.1#5335\nserver=/msftncsi.com/127.0.0.1#5335" >> $DNS_FILE
		if [ $run_mode != all ];then
			cp -f $T_FILE/black.list $O
			awk '!/^$/&&!/^#/{printf("server=/%s/'"127.0.0.1#5335"'\n",$0)}' $O >$DNS_DIR/black.conf
			if [ $run_mode = gfw ];then
				cp -f $VAR/gfw.list $O
				awk '!/^$/&&!/^#/{printf("server=/%s/'"127.0.0.1#5335"'\n",$0)}' $O >>$DNS_DIR/black.conf
			fi
		fi

		if [ -s $DNS_DIR/black.conf ];then
			echo "$(sort -u $DNS_DIR/black.conf)" >$DNS_DIR/black.conf
		else
			rm -f $DNS_DIR/black.conf
		fi
		if [ -n "$NF" ];then
			cp -f $T_FILE/netflix.list $O
			D=$(cat $O)
			for i in $D;do
				sed -i -e "/\/$i\//d" -e "/\.$i\//d" $DNS_DIR/black.conf 2>/dev/null
			done
			if [ $run_mode = gfw ];then
				awk '!/^$/&&!/^#/{printf("server=/%s/'"127.0.0.1#5335"'\n",$0)}' $O >>$DNS_DIR/black.conf
			fi
		fi
		if [ -s $T_FILE/white.list ];then
			cp -f $T_FILE/white.list $O
			sed -i "s/\r//g" $O
			D=$(cat $O)
			for i in $D;do
				sed -i -e "/\/$i\//d" -e "/\.$i\//d" $DNS_DIR/black.conf 2>/dev/null
			done
			awk '!/^$/&&!/^#/{printf("server=/%s/'"127.0.0.1#5335"'\n",$0)}' $O >>$DNS_DIR/white.conf
		fi
		if [ -s $T_FILE/domains_cn.txt ];then
			cp -f $T_FILE/domains_cn.txt $O
			sed -i "s/\r//g" $O
			awk '!/^$/&&!/^#/{printf("server=/%s/'"127.0.0.1#5335"'\n",$0)}' $O >>$DNS_DIR/white.conf
		fi
	fi
	log "MosDNS : start in $bootstrap_dns Bootstrap DNS Resolution!"
	[ $(find $DNS_DIR -name \* -exec cat {} \; 2>/dev/null | wc -l) = 0 ] && rm -rf $DNS_DIR
	echo "conf-dir=${DNS_DIR}" >$DNS_FILE
	rm -rf $TMPDIR $O
	[ $run_mode = router ] && chinadns_flag=1
	start_dns
	/etc/init.d/dnsmasq restart >/dev/null 2>&1
	$BIN_DIR/by-preload $run_mode
}


start_switch(){
	if [ $(uci_get_by_type global enable_switch 0) = 1 -a -z "$switch_server" ];then
		service_start $BIN_DIR/by-switch start
		switch_enable=1
	fi
}

add_cron(){
	if [ $(uci_get_by_type server_subscribe auto_update 0) = 1 ];then
		if ! grep -wq "$(uci_get_by_type server_subscribe auto_update_time 6) \* \* \* .*$BIN_DIR" $CRON_FILE;then
			eval $CRON
			echo "0 $(uci_get_by_type server_subscribe auto_update_time 6) * * * $BIN_DIR/update" >>$CRON_FILE
			echo "5 $(uci_get_by_type server_subscribe auto_update_time 6) * * * $BIN_DIR/subscribe" >>$CRON_FILE
			/etc/init.d/cron restart
		fi
	fi
}

gen_service_file(){
	[ $(uci_get_by_name $1 fast_open 0) = 1 ] && fast=true || fast=false
	if [ $2 = ss ];then
		cat <<-EOF >$3
			{
			"server":"0.0.0.0",
			"server_port":$port,
			"password":"$pass",
			"timeout":$timeout,
			"method":"$(uci_get_by_name $1 encrypt_method_ss)",
			"fast_open":$fast
			}
		EOF
		plugin=$(uci_get_by_name $1 plugin 0)
		if which $plugin >/dev/null 2>&1;then
			sed -i "s@0.0.0.0\",@0.0.0.0\",\n\"plugin\":\"$plugin\",\n\"plugin_opts\":\"$(uci_get_by_name $1 plugin_opts)\",@" $3
		fi
	else
		cat <<-EOF >$3
			{
			"server":"0.0.0.0",
			"server_port":$port,
			"password":"$pass",
			"timeout":$timeout,
			"method":"$(uci_get_by_name $1 encrypt_method)",
			"protocol":"$(uci_get_by_name $1 protocol)",
			"protocol_param":"$(uci_get_by_name $1 protocol_param)",
			"obfs":"$(uci_get_by_name $1 obfs)",
			"obfs_param":"$(uci_get_by_name $1 obfs_param)",
			"fast_open":$fast
			}
		EOF
	fi
}

run_server(){
	[ $(uci_get_by_name $1 enable 0) = 0 ] && return 1
	let server_count=server_count+1
	[ $server_count = 1 ] && iptables-save -t filter | grep BY-SERVER-RULE >/dev/null || iptables -N BY-SERVER-RULE && iptables -t filter -I INPUT -j BY-SERVER-RULE
	type=$(uci_get_by_name $1 type ssr)
	[ $type = ss -o $type = ssr ] && cmd=$(f_bin $type-server) || cmd=$(which microsocks)
	[ ! $cmd ] && log "By server: Can't find $cmd program, start failed!" && return 1
	port=$(uci_get_by_name $1 server_port)
	pass=$(uci_get_by_name $1 password)
	name=by-server_$server_count
	case $type in
	ss|ssr)
		timeout=$(uci_get_by_name $1 timeout 60)
		gen_service_file $1 $type $VAR/$name.json
		$cmd -c $VAR/$name.json -u >/dev/null 2>&1 &
		[ $type = ss ] && name=Shadowsocks || name=ShadowsocksR
		log "By server: $name Server$server_count Started!"
		;;
	*)
		if [ $(uci_get_by_name $1 auth_enable 0) = 1 ];then
			username=$(uci_get_by_name $1 username)
			if [ "$username" ];then
				param="$([ $(uci_get_by_name $1 auth_once 0) = 1 ] && echo -1) -u $username -P $pass"
			else
				log "By server: Socks5 User and pass must be used together!"
				return 1
			fi
		fi
		$cmd -p $port $param $name >/dev/null 2>&1 &
		log "By server: Socks5 Server$server_count Started!"
		;;
	esac
	iptables -t filter -A BY-SERVER-RULE -p tcp --dport $port -j ACCEPT
	iptables -t filter -A BY-SERVER-RULE -p udp --dport $port -j ACCEPT
}

gen_serv_include(){
	[ -s $FWI ] || echo '#!/bin/sh' >$FWI
	extract_rules(){
		echo "*filter"
		iptables-save -t filter | grep BY-SERVER-RULE | sed -e "s/^-A INPUT/-I INPUT/"
		echo 'COMMIT'
	}
	cat <<-EOF >>$FWI
		iptables-save -c | grep -v "BY-SERVER-RULE" | iptables-restore -c
		iptables-restore -n <<-EOT
		$(extract_rules)
		EOT
	EOF
}

start_server(){
	[ $(uci_get_by_type server_global enable_server 0) = 0 ] && return
	[ ! -d $VAR ] && mkdir -p $VAR
	config_load $NAME
	config_foreach run_server server_config
	gen_serv_include
}

start_monitor(){
	if [ $(uci_get_by_type global monitor_enable 0) = 1 ];then
		let total=redir_tcp+kcp_enable+redir_udp+redir_nf+dns_flag+chinadns_flag+local_enable+server_count+switch_enable
		[ $total -gt 0 ] && service_start $BIN_DIR/by-monitor $redir_tcp $kcp_enable $redir_udp $redir_nf $dns_flag $chinadns_flag $local_enable $server_count
	fi
}

start(){
	ulimit -n 65535
	if [ -n "$switch_server" ];then
		GLOBAL_SERVER=$switch_server
		switch_enable=1
	fi
	v2txray
	if rules;then
		if start_retcp;then
			[ -n "$UDP_RELAY_SERVER" ] && start_reudp
			[ -n "$NF" ] && start_renf
			[ "x$dns_mode" = "x1" ] && gen_smartdns || gen_mosdns
			start_switch
			add_cron
		fi
	fi
	[ "$SO_SERVER" -a "$socks5_start" != 1 ] && start_local
	start_server 
	start_monitor
	adbin="$(uci -q get AdGuardHome.AdGuardHome.binpath)"
	if [[ -x /etc/init.d/AdGuardHome && -x "$adbin" ]]; then
		if [[ $adguardhome == 1 && -n "$GLOBAL_SERVER" ]]; then
			if [[ ! "$(netstat -tunlp | grep 53 | grep -i AdGuardHome)" ]]; then
				uci -q del dhcp.@dnsmasq[0].dns_redirect
				sed -i "/dhcp_option '6/d" /etc/config/dhcp
				uci -q add_list dhcp.lan.dhcp_option="6,$(uci -q get network.lan.ipaddr)"
				uci commit dhcp
				adgconf="$(uci -q get AdGuardHome.AdGuardHome.configpath)"
				masqport="$(grep "  port:.*" $adgconf | cut -f 4 -d " ")"
				[ -s $adgconf ] && adgc="$(cat $adgconf | tr '\n' '\r' | sed -e "s/upstream_dns:.*upstream_dns_file/upstream_dns:\n  - 127.0.0.1:$masqport\n  upstream_dns_file/" | tr '\r' '\n')"
				[ ` uci -q get AdGuardHome.AdGuardHome.redirectold ` ] || uci -q set AdGuardHome.AdGuardHome.redirectold="$(uci -q get AdGuardHome.AdGuardHome.redirect)"
				[ -n "$adgc" ] && echo "${adgc}" >$adgconf
				uci -q set AdGuardHome.AdGuardHome.enabled='1'
				uci -q set AdGuardHome.AdGuardHome.redirect='exchange'
				uci commit AdGuardHome
				(sleep 3; /etc/init.d/AdGuardHome restart >/dev/null 2>&1) &
			fi
		elif [ ` uci -q get AdGuardHome.AdGuardHome.redirectold ` ]; then
				uci -q set AdGuardHome.AdGuardHome.enabled='0'
				uci -q set AdGuardHome.AdGuardHome.redirect ="$(uci -q get AdGuardHome.AdGuardHome.redirectold)"
				uci -q del AdGuardHome.AdGuardHome.redirectold
				uci commit AdGuardHome
				/etc/init.d/AdGuardHome stop >/dev/null 2>&1 &
		fi
	elif [ $adguardhome == 1 ]; then
		log "Please ensure that Luci app adguardhome and ADG main program exist in the system!"
	fi
	clean_log 

}

stop(){
	kill -9 $(ps -w | grep by-rules | grep -v grep | awk '{print$1}') 2>/dev/null
	kill -9 $(ps -w | grep gfw.b64 | grep -v grep | awk '{print$1}') 2>/dev/null
	kill -9 $(ps -w | grep $BIN_DIR/checknetwork | grep -v grep | awk '{print$1}') 2>/dev/null
	kill -9 $(ps -w | grep $BIN_DIR/update | grep -v grep | awk '{print$1}') 2>/dev/null

	[ $switch_server ] || kill -9 $(ps -w | grep by-switch | grep -v grep | awk '{print$1}') 2>/dev/null
	kill -9 $(ps -w | grep by-monitor | grep -v grep | awk '{print$1}') 2>/dev/null
	kill -9 $(ps -w | grep by-preload | grep -v grep | awk '{print$1}') 2>/dev/null
	kill -9 $(ps -w | grep $VAR | grep -v grep | awk '{print$1}') 2>/dev/null
	killall -q -9 smartdns chinadns-ng kcptun-client xray-plugin microsocks mosdns
	$BIN_DIR/by-rules -f
	[ $(iptables -nL | grep BY-SERVER-RULE | wc -l) = 0 ] || (iptables -F BY-SERVER-RULE && iptables -X BY-SERVER-RULE;while iptables -D INPUT -j BY-SERVER-RULE 2>/dev/null;do :;done)
	rm -rf $DNS_DIR $VAR $DNS_FILE $CON_T /tmp/lock/$NAME-update.lock $MDNS
	[ -z "$GLOBAL_SERVER" ] && grep -q $NAME $CRON_FILE && sed -i '/$NAME/d' $CRON_FILE && /etc/init.d/cron restart
	if [ -z "$GLOBAL_SERVER" ];then
		if [[ -f /etc/init.d/AdGuardHome && ` uci -q get AdGuardHome.AdGuardHome.redirectold ` ]]; then
			/etc/init.d/AdGuardHome stop >/dev/null 2>&1 &
		fi
		rm -rf $SDNS $PID
		/etc/init.d/dnsmasq restart >/dev/null 2>&1
		if [ -z "$GLOBAL_SERVER" ];then
			rm -rf $LOG
		fi
	elif [ -s $DNS_T ];then
		cat > $DNS_T_TMP <<-EOF
			speed-check-mode none
			cache-persist no
			cache-size 0
			log-level fatal
			log-file $LOG
			bind :5335
			bind :5336
			bind :5337
		EOF
		if [ $dns_local = alidns_dot ];then
			dns_d_l="223.5.5.5 223.6.6.6"
			for i in $dns_d_l;do smartdns_append "server-https https://$i/dns-query";done
		else
			dns_d_l=$REF
			if [ -z "$dns_d_l" ];then
				log "SmartDNS : Get Domestic DNS failed!"
				exit 1
			fi
			dns_d_l=$(echo $dns_d_l | sed -e 's/，/,/g' -e 's/。/./g' -e 's/：/:/g' -e 's/,/\n/g')
			for i in $dns_d_l;do smartdns_append "server $i";done
		fi
		mv -f $DNS_T_TMP $DNS_T
		$(which smartdns) -c $DNS_T
		r=1
		while ! ps -w | grep smartdns | grep -v grep >/dev/null;do
			[ $r -ge 10 ] && return 1 || let r++
			sleep 1
		done
	fi

}

arg1=$1
shift
case $arg1 in
elog)
	log $*
	;;
stop)
	stop
	;;
start)
	start
	;;
esac