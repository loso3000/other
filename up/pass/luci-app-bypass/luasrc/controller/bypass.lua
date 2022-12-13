module("luci.controller.bypass",package.seeall)
local fs=require"nixio.fs"
local http=require"luci.http"
CALL=luci.sys.call
EXEC=luci.sys.exec
function index()
	if not nixio.fs.access("/etc/config/bypass") then 
		return
	end
	local e=entry({"admin","services","bypass"},firstchild(),_("Bypass"),2)
	e.dependent=false
	e.acl_depends={"luci-app-bypass"}
	entry({"admin","services","bypass","base"},cbi("bypass/base"),_("Base Setting"),1).leaf=true
	entry({"admin","services","bypass","servers"},arcombine(cbi("bypass/servers",{autoapply = true}),cbi("bypass/client-config")),_("Severs Nodes"),2).leaf=true
	entry({"admin","services","bypass","shunt"},cbi("bypass/shunt"),_("Shunt Setting"),3).leaf=true
	entry({"admin","services","bypass","control"},cbi("bypass/control"),_("Access Control"),4).leaf=true
	entry({"admin","services","bypass","domain"},cbi("bypass/domain"),_("Domain List"),5).leaf=true
	entry({"admin","services","bypass","advanced"},cbi("bypass/advanced"),_("Advanced Settings"),6).leaf=true
	if luci.sys.call("which ssr-server >/dev/null")==0 or luci.sys.call("which ss-server >/dev/null")==0 or luci.sys.call("which microsocks >/dev/null")==0 then
		entry({"admin","services","bypass","server"},arcombine(cbi("bypass/server"),cbi("bypass/server-config")),_("Server"),7).leaf=true
	end
	entry({"admin","services","bypass","log"},form("bypass/log"),_("Log"),8).leaf=true
	entry({"admin", "services", "bypass", "run"}, call("act_status"))
	entry({"admin", "services", "bypass", "checknet"}, call("check_net"))
	entry({"admin","services","bypass","refresh"},call("refresh"))
	entry({"admin","services","bypass","subscribe"},call("subscribe"))
	entry({"admin","services","bypass","ping"},call("ping"))
	entry({"admin","services","bypass","getlog"},call("getlog"))
	entry({"admin","services","bypass","dellog"},call("dellog"))
end

function subscribe()
	CALL("/usr/bin/lua /usr/share/bypass/subscribe")
	http.prepare_content("application/json")
	http.write_json({ret=1})
end
function act_status()
	local e = {}
	e.tcp = CALL('busybox ps -w | grep bypass-tcp | grep -v grep  >/dev/null ') == 0
	e.udp = CALL('busybox ps -w | grep bypass-udp | grep -v grep  >/dev/null ') == 0
	e.smartdns = CALL("pidof smartdns >/dev/null")==0

	e.chinadns=CALL("pidof chinadns-ng >/dev/null")==0
	http.prepare_content("application/json")
	http.write_json(e)
end

function check_net()
	local r=0
	local u=http.formvalue("url")
	local p
	if CALL("nslookup www."..u..".com >/dev/null 2>&1")==0 then
	if u=="google" then p="/generate_204" else p="" end
		local use_time = EXEC("curl --connect-timeout 3 -o /dev/null -I -skL -w %{time_starttransfer}  https://www."..u..".com"..p)
		if use_time~="0" then
     		 	r=string.format("%.1f", use_time * 1000/2)
			if r=="0" then r="0.1" end
		end
	end
	http.prepare_content("application/json")
	http.write_json({ret=r})
end



function checksrv()
	local r="<br/>"
	local s,n
	luci.model.uci.cursor():foreach("bypass","servers",function(s)
		if s.alias then
			n=s.alias
		elseif s.server and s.server_port then
			n="%s:%s"%{s.server,s.server_port}
		end
		local dp=EXEC("netstat -unl | grep 5336 >/dev/null && echo -n 5336 || echo -n 53")
		local ip=EXEC("echo "..s.server.." | grep -E ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ || \\\
		nslookup "..s.server.." 127.0.0.1:"..dp.." 2>/dev/null | grep Address | awk -F' ' '{print$NF}' | grep -E ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ | sed -n 1p")
		ip=EXEC("echo -n "..ip)
		local iret=CALL("ipset add over_wan_ac "..ip.." 2>/dev/null")
		local t=EXEC(string.format("tcping -q -c 1 -i 1 -t 2 -p %s %s 2>&1 | awk -F 'time=' '{print $2}' | awk -F ' ' '{print $1}'",s.server_port,ip))
		if t~='' then
			if tonumber(t)<100 then
				col='#2dce89'
			elseif tonumber(t)<200 then
				col='#fb9a05'
			else
				col='#fb6340'
			end
			r=r..'<font color="'..col..'">['..string.upper(s.type)..'] ['..n..'] '..t..' ms</font><br/>'
		else
			r=r..'<font color="red">['..string.upper(s.type)..'] ['..n..'] ERROR</font><br/>'
		end
		if iret==0 then CALL("ipset del over_wan_ac "..ip) end
	end)
	http.prepare_content("application/json")
	http.write_json({ret=r})
end

function ping()
	local e={}
	local domain=http.formvalue("domain")
	local port=http.formvalue("port")
	local dp=EXEC("netstat -unl | grep 5336 >/dev/null && echo -n 5336 || echo -n 53")
	local ip=EXEC("echo "..domain.." | grep -E ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ || \\\
	nslookup "..domain.." 2>/dev/null | grep Address | awk -F' ' '{print$NF}' | grep -E ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ | sed -n 1p")
	ip=EXEC("echo -n "..ip)
	local iret=CALL("ipset add over_wan_ac "..ip.." 2>/dev/null")
	e.ping=EXEC(string.format("tcping -q -c 1 -i 1 -t 2 -p %s %s 2>&1 | awk -F 'time=' '{print $2}' | awk -F ' ' '{print $1}'",port,ip))

	if (iret==0) then
		CALL("ipset del over_wan_ac "..ip)
	end
	http.prepare_content("application/json")
	http.write_json(e)
end

function getlog()
	logfile="/tmp/bypass.log"
	if not fs.access(logfile) then
		http.write("")
		return
	end
	local f=io.open(logfile,"r")
	local a=f:read("*a") or ""
	f:close()
	a=string.gsub(a,"\n$","")
	http.prepare_content("text/plain; charset=utf-8")
	http.write(a)
end

function dellog()
	fs.writefile("/tmp/bypass.log","")
	http.prepare_content("application/json")
	http.write('')
end
