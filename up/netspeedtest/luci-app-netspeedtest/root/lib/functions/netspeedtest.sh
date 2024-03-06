################################################################################
# (netspeedtest) functions.sh
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
#   Copyright (C) 2019-2024 The Sirpdboy Team <herboy2008@gmail.com> 
# . /lib/netspeedtest/functions.sh
################################################################################

# tmp speedtest
TMP_TEST=/var/netspeedtest.tmp
MAX_LOG=200
LOG=/var/log/netspeedtest.log
limit_log() {
	local logf=$1
	local max=$2
	[ ! -f "$logf" ] && return
	sc=${max:-$MAX_LOG}
	local count=$(grep -c "" $logf)
	if [ $count -gt $sc ];then
		let count=count-$sc
		sed -i "1,$count d" $logf
	fi
}

init_log() {
	local logf=$1
	[ ! -f "$logf" ] && echo "" > $logf
}

echone() {
  echo -ne $* >> $LOG
}


git_bin_handle()
{
case $1 in
    1)
	BINSPEEDTEST='/usr/bin/speedtest'
	[ -x "$BINSPEEDTEST" ] && echo "$BINSPEEDTEST --share"
	;;  
    *)
	TMPDIR=/var/netspeedtest
	BINSPEEDTEST=$TMPDIR/speedtest
	[ ! -d $TMPDIR ] && mkdir -p $TMPDIR 2>/dev/null
	if [ -x "$BINSPEEDTEST" ]; then
	    chmod 755 $BINSPEEDTEST  >/dev/null 2>&1
	    echo "$BINSPEEDTEST --accept-gdpr --accept-license --progress=no"
	else
	    ooklaurl=`curl --connect-timeout 5 -m 60  -sSL  'https://www.speedtest.net/apps/cli' | grep 'Download for Linux' | sed 's|<|\n<|g' | sed -n '/Download for Linux/,/<\/div>/p' | sed -En "s|.*<a href=\"([^\"]+)\">x86_64|\1|p" `
	    [ -n "$ooklaurl" ] && curl -sSL $ooklaurl | tar -xvz -C /tmp  >/dev/null 2>&1 || return
	    mv /tmp/speedtest $BINSPEEDTEST >/dev/null 2>&1
	    chmod 755 $BINSPEEDTEST  >/dev/null 2>&1
	    [ -x "$BINSPEEDTEST" ] && echo "$BINSPEEDTEST --accept-gdpr --accept-license --progress=no"
	fi
	;;
    esac
}

speedtest_start(){
case $1 in
    1) 
        speedtest_start_cli $2 ;;  
    *) 
        speedtest_start_ookla $2 ;;  
    esac
}

speedtest_start_ookla(){
    CMD="$1"
    echone "\n  ookla-speedtest测速"
    info=`$CMD > $TMP_TEST ` >/dev/null 2>&1
    echone "\n  info:$info ----------------- "
    echone   "\n  测服信息:`cat  $TMP_TEST | grep 'Server'| cut -c10- | awk -F: '{printf $2$3}'`  线路:`cat  $TMP_TEST | grep 'ISP' | awk -F: '{printf $2}' `  延时：`cat  $TMP_TEST | grep 'Latency' | awk -F: '{printf $2}'  | awk -F '(' '{printf $1}'`"
    echone  "\n  下行速率:`cat  $TMP_TEST  | grep 'Download' |awk -F: '{printf $2}'  | awk -F '(' '{printf $1}'`  --"
    echone  "--  上行速率:`cat  $TMP_TEST  | grep 'Upload' |awk -F: '{printf $2}' | awk -F '(' '{printf $1}'`"
    echone  "\n  测试时间: `date +%Y-%m-%d' '%H:%M:%S`"
    echone  "\n  ————————————————————————————\n"
    echo -ne  $(cat  $TMP_TEST  | grep 'URL' | cut -c15- ) 
}
speedtest_start_cli(){
    CMD=$1
    echone  "\n  python3-speedtest测速"
    info=`$CMD > $TMP_TEST ` >/dev/null 2>&1
    echone   "\n  测服信息:`cat  $TMP_TEST | grep 'Hosted by'| cut -c10- | awk -F: '{printf $1}'`  延时：`cat  $TMP_TEST | grep 'Hosted by' | awk -F: '{printf $2}'`"
    echone  "\n  下行速率:`cat  $TMP_TEST  | grep 'Download:' |awk -F: '{printf $2}' `  --"
    echone  "--  上行速率:`cat  $TMP_TEST  | grep 'Upload:' |awk -F: '{printf $2}' `"
    echone  "\n  测试时间: `date +%Y-%m-%d' '%H:%M:%S`"
    echone  "\n  ————————————————————————————\n"
    echo -ne  $(cat  $TMP_TEST  | grep 'results:' | cut -c16- )
}
