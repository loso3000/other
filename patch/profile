Sysinfo() {
[ -z "${TARGET_PROFILE}" ] && local TARGET_PROFILE=$(jsonfilter -e '@.model.id' < /etc/board.json | tr ',' '_')
local DISTRIB_ARCH=$(cat /etc/openwrt_release | grep "DISTRIB_ARCH=" |awk -F "'" '{print $2}')
if grep -Eq "x86" "/etc/openwrt_release" ; then
	[ -d /sys/firmware/efi ] && DISTRIB_ARCH= "${DISTRIB_ARCH} - UEFI" || DISTRIB_ARCH="${DISTRIB_ARCH} - BIOS"
else
	DISTRIB_ARCH=${DISTRIB_ARCH}	
fi
local IP_Address=$(ifconfig -a | grep inet | grep -v 127.0.0.1 | grep -v inet6 | awk '{print $2}' | tr -d "addr:" | awk 'NR==1')
local Overlay_Available="$(df -h | grep ":/overlay" | awk '{print $4}' | awk 'NR==1')"
local Tmp_Available="$(df -h | grep "/tmp" | awk '{print $4}' | awk 'NR==1')"
local TEMP=$(sensors 2>/dev/null | grep 'Core 0' | awk '{print $3}')
cat <<EOF
$(echo -e "${Yellow}$(uname -n)/${TARGET_PROFILE}")
$(echo -e "${Green}TARGET Info:	${DISTRIB_ARCH}${White}")
FIRWare Ver:	$(uname -rs)$([ -n "${TEMP}" ] && echo -e "${TEMP}")
$(echo -e "${Red}IP  Address:	${IP_Address}${White}")
OverlaySIZE:	${Overlay_Available} / ${Tmp_Available}

EOF
}

White="\e[0m"
Yellow="\e[33m"
Red="\e[31m"
Blue="\e[34m"
Grey="\e[36m"
Green="\e[32m"
Div="${Grey}|${White}"

clear
[ -e /tmp/.failsafe ] && export FAILSAFE=1
[ -f /etc/banner ] && echo -e "${Skyb}$(cat /etc/banner)${White}"
[ -n "$FAILSAFE" ] && cat /etc/banner.failsafe

Sysinfo

fgrep -sq '/ overlay ro,' /proc/mounts && {
	echo -e "${Red}Your JFFS2-partition seems full and overlayfs is mounted read-only."
	echo -e "Please try to remove files from /overlay/upper/... and reboot!${}"
}

export PATH="/usr/sbin:/usr/bin:/sbin:/bin"
export HOME=$(grep -e "^${USER:-root}:" /etc/passwd | cut -d ":" -f 6)
export HOME=${HOME:-/root}
export CONFIG=/etc/config
if [ -n "${TARGET_PROFILE}" ]
then
	export PS1='\u@\h[${TARGET_PROFILE}]:\w\$ '
else
	export PS1='\u@\h:\w\$ '
fi
export ENV=/etc/shinit

case "$TERM" in
	xterm*|rxvt*)
		export PS1='\[\e]0;\u@\h: \w\a\]'$PS1
		;;
esac

[ -n "$FAILSAFE" ] || {
	for FILE in /etc/profile.d/*.sh; do
		[ -e "$FILE" ] && . "$FILE"
	done
	unset FILE
}

if ( grep -qs '^root::' /etc/shadow && \
     [ -z "$FAILSAFE" ] )
then
cat << EOF
================== WARNING! ====================
There is no root password defined on this device!
Use the "passwd" command to set up a new password
in order to prevent unauthorized SSH logins.
------------------------------------------------
EOF
fi
alias reload='. /etc/profile'
alias shutdown='sync && poweroff'
alias dh='df -h'
alias ls='ls --color=auto'
alias l='ls -CF'
alias cls='clear'
alias syslog='cat $(uci get system.@system[0].log_file) 2> /dev/null'
alias ramfree='sync && echo 3 > /proc/sys/vm/drop_caches'
alias top='top -d 1'
