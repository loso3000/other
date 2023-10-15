module("luci.controller.bypass",package.seeall)
local fs=require"nixio.fs"
local http=require"luci.http"
CALL=luci.sys.call
EXEC=luci.sys.exec
function index()
	if not nixio.fs.access("/etc/config/bypass") then
		return
	end
	local e=entry({"admin","services","bypass"},firstchild(),_("Bypass"),1)
	e.dependent=false
	e.acl_depends={ "luci-app-bypass" }
	entry({"admin","services","bypass","base"},cbi("bypass/base"),_("Base Setting"),10).leaf=true
	entry({"admin","services","bypass","servers"},arcombine(cbi("bypass/servers",{autoapply=true}),cbi("bypass/client-config")),_("Severs Nodes"),20).leaf=true
	entry({'admin', 'services','bypass','servers-subscribe'}, cbi('bypass/servers-subscribe', {hideapplybtn = true, hidesavebtn = true, hideresetbtn = true}), _('Subscribe'), 30).leaf = true
	entry({"admin","services","bypass","control"},cbi("bypass/control"),_("Access Control"),40).leaf=true
	entry({"admin","services","bypass","advanced"},cbi("bypass/advanced"),_("Advanced Settings"),60).leaf=true
	if luci.sys.call("which ssr-server >/dev/null")==0 or luci.sys.call("which ss-server >/dev/null")==0 or luci.sys.call("which microsocks >/dev/null")==0 then
	      entry({"admin","services","bypass","server"},arcombine(cbi("bypass/server"),cbi("bypass/server-config")),_("Server"),70).leaf=true
	end
	entry({"admin","services","bypass","log"},form("bypass/log"),_("Log"),80).leaf=true
	entry({"admin","services","bypass","run"},call("act_status"))
	entry({"admin", "services", "bypass", "checknet"}, call("check_net"))
	entry({"admin","services","bypass","subscribe"},call("subscribe"))
	entry({"admin","services","bypass","checkport"},call("check_port"))
	entry({"admin","services","bypass","ping"},call("act_ping"))

	entry({"admin","services","bypass","check"},call("check_status"))
	entry({"admin","services","bypass","getlog"},call("getlog"))
	entry({"admin", "services", "bypass", "connect_status"}, call("connect_status")).leaf = true
	entry({"admin","services","bypass","dellog"},call("dellog"))
end

function subscribe()
	CALL("/usr/bin/lua /usr/share/bypass/subscribe")
	http.prepare_content("application/json")
	http.write_json({ret=1})
end

function act_status()
	local e = {}
	e.tcp = CALL('busybox ps -w | grep by-retcp | grep -v grep  >/dev/null ') == 0
	e.udp = CALL('busybox ps -w | grep by-reudp | grep -v grep  >/dev/null ') == 0
	e.smartdns = CALL("ps -w | grep smartdns | grep -v grep   >/dev/null")==0
	e.chinadns=CALL("ps -w | grep 'chinadns-ng -l 5337 -c 127.0.0.1' | grep -v grep >/dev/null")==0
	http.prepare_content("application/json")
	http.write_json(e)
end

function check_net()
	local r=0
	local u=http.formvalue("url")
	local p
	if CALL("nslookup www."..u..".com >/dev/null 2>&1")==0 then
	if u=="google" then p="/generate_204" else p="" end
		local use_time = EXEC("curl --connect-timeout 3 -o /dev/null -I -skL -w %{time_starttransfer}  http://www."..u..".com"..p)
		if use_time~="0" then
     		 	r=string.format("%.1f", use_time * 1000/2)
			if r=="0" then r="0.1" end
		end
	end
	http.prepare_content("application/json")
	http.write_json({ret=r})
end



function act_ping()
	local e={}
	local domain=http.formvalue("domain")
	local port=http.formvalue("port")
	local dp=EXEC("netstat -unl | grep 5336 >/dev/null && echo -n 5336 || echo -n 53")
	local ip=EXEC("echo "..domain.." | grep -E ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ || nslookup "..domain.." 2>/dev/null | grep Address | awk -F' ' '{print$NF}' | grep -E ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ | sed -n 1p")
	ip=EXEC("echo -n "..ip)
	local iret=luci.sys.call("ipset add ss_spec_wan_ac "..ip.." 2>/dev/null")
	e.ping = luci.sys.exec(string.format("tcping -q -c 1 -i 1 -t 2 -p %s %s 2>&1 | awk -F 'time=' '{print $2}' | awk -F ' ' '{print $1}'",port,ip))

	if (iret==0) then
		luci.sys.call(" ipset del ss_spec_wan_ac " .. ip)
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function check_status()
	sret=luci.sys.call("curl -so /dev/null -m 3 www."..luci.http.formvalue("set")..".com")
	if sret==0 then
		retstring="0"
	else
		retstring="1"
	end
	luci.http.prepare_content("application/json")
	luci.http.write_json({ret=retstring})
end

function check_port()
	local retstring="<br/>"
	local s
	local server_name
	local iret=1
	luci.model.uci.cursor():foreach("bypass","servers",function(s)
		if s.alias then
			server_name=s.alias
		elseif s.server and s.server_port then
			server_name="%s:%s"%{s.server,s.server_port}
		end
		luci.sys.exec(s.server..">>/a")
		local dp=luci.sys.exec("netstat -unl | grep 5336 >/dev/null && echo -n 5336 || echo -n 53")
		local ip=luci.sys.exec("echo "..s.server.." | grep -E \"^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$\" || \\\
		nslookup "..s.server.." 127.0.0.1:"..dp.." 2>/dev/null | grep Address | awk -F' ' '{print$NF}' | grep -E \"^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$\" | sed -n 1p")
		ip=luci.sys.exec("echo -n "..ip)
		iret=luci.sys.call("ipset add ss_spec_wan_ac "..ip.." 2>/dev/null")
		socket=nixio.socket("inet","stream")
		socket:setopt("socket","rcvtimeo",3)
		socket:setopt("socket","sndtimeo",3)
		ret=socket:connect(ip,s.server_port)
		socket:close()
		if tostring(ret)=="true" then
			retstring=retstring.."<font color='green'>["..server_name.."] OK.</font><br/>"
		else
			retstring=retstring.."<font color='red'>["..server_name.."] Error.</font><br/>"
		end
		if  iret==0 then
			luci.sys.call("ipset del ss_spec_wan_ac "..ip)
		end
	end)
	luci.http.prepare_content("application/json")
	luci.http.write_json({ret=retstring})
end

local function http_write_json(content)
	http.prepare_content("application/json")
	http.write_json(content or {code = 1})
end



function getlog()
	logfile="/tmp/log/bypass.log"
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
	fs.writefile("/tmp/log/bypass.log","")
	http.prepare_content("application/json")
	http.write('')
end
