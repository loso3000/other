module("luci.controller.bypass",package.seeall)
function index()
	if not nixio.fs.access("/etc/config/bypass") then
		call("act_reset")
	end
	local e=entry({"admin","services","bypass"},firstchild(),_("Bypass"),1)
	e.dependent=false
	e.acl_depends={ "luci-app-bypass" }
	entry({"admin","services","bypass","base"},cbi("bypass/base"),_("Base Setting"),10).leaf=true
	entry({"admin","services","bypass","servers"},arcombine(cbi("bypass/servers",{autoapply=true}),cbi("bypass/client-config")),_("Servers Nodes"),20).leaf=true
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
	entry({"admin","services","bypass","getlog"},call("getlog")).leaf = true
	entry({"admin", "services", "bypass", "connect_status"}, call("connect_status")).leaf = true
	entry({"admin", "services", "bypass", "reset"}, call("act_reset"))
	entry({"admin", "services", "bypass", "restart"}, call("act_restart"))
	entry({"admin","services","bypass","dellog"},call("dellog")).leaf = true
	--[[Backup]]
	entry({"admin", "services", "bypass", "backup"}, call("create_backup")).leaf = true
end

function subscribe()
	luci.sys.call("/usr/bin/lua /usr/share/bypass/subscribe")
	luci.http.prepare_content("application/json")
	luci.http.write_json({ret=1})
end

function act_status()
	local e = {}
	e.tcp = luci.sys.call('busybox ps -w | grep by-retcp | grep -v grep  >/dev/null ') == 0
	e.udp = luci.sys.call('busybox ps -w | grep by-reudp | grep -v grep  >/dev/null ') == 0
	e.nf = luci.sys.call('busybox ps -w | grep by-nf | grep -v grep  >/dev/null ') == 0
	e.sdns = luci.sys.call("busybox ps -w | grep 'smartdns_by' | grep -v grep >/dev/null ")==0
	e.mdns = luci.sys.call("busybox  ps -w | grep 'mosdns_by'  | grep -v grep   >/dev/null ")==0
	e.chinadns=luci.sys.call("busybox ps -w | grep 'chinadns-ng -l 5337' | grep -v grep >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(e)
end

function check_net()
	local r=0
	local u=luci.http.formvalue("url")
	local p

	if luci.sys.call("nslookup www."..u..".com >/dev/null 2>&1")==0 then
	        if u=="google" then p="/generate_204" else p="" end
		local use_time = luci.sys.exec("curl --connect-timeout 3 -silent -o /dev/null -I -skL -w %{time_starttransfer}  https://www."..u..".com"..p)
		if use_time~="0" then
     		 	r=string.format("%.1f", use_time * 1000/2)
			if r=="0" then r="0.1" end
		end
	end

	luci.http.prepare_content("application/json")
	luci.http.write_json({ret=r})
end



function act_ping()
	local e={}
	local domain=luci.http.formvalue("domain")
	local port=luci.http.formvalue("port")
	local dp=luci.sys.exec("netstat -unl | grep 5336 >/dev/null && echo -n 5336 || echo -n 53")
	local ip=luci.sys.exec("echo "..domain.." | grep -E ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ || nslookup "..domain.." 2>/dev/null | grep Address | awk -F' ' '{print$NF}' | grep -E ^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}$ | sed -n 1p")
	ip=luci.sys.exec("echo -n "..ip)
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
			retstring = retstring .. "<font><b style='color:green'>[" .. server_name .. "] OK.</b></font><br />"
		else
			retstring = retstring .. "<font><b style='color:red'>[" .. server_name .. "] Error.</b></font><br />"
		end
		if  iret==0 then
			luci.sys.call("ipset del ss_spec_wan_ac "..ip)
		end
	end)
	luci.http.prepare_content("application/json")
	luci.http.write_json({ret=retstring})
end

local function http_write_json(content)
	luci.http.prepare_content("application/json")
	luci.http.write_json(content or {code = 1})
end


function act_reset()
	luci.sys.call("/etc/init.d/bypass reset >/dev/null 2>&1")
	luci.http.redirect(luci.dispatcher.build_url("admin", "services", "bypass"))
end


function act_restart()
	luci.sys.call("/etc/init.d/bypass restart &")
	luci.http.redirect(luci.dispatcher.build_url("admin", "services", "bypass"))
end

function getlog()
	luci.http.write(luci.sys.exec("[ -f '/var/log/bypass.log' ] && cat /var/log/bypass.log"))

end

function dellog()

	luci.sys.call("echo '' > /var/log/bypass.log")
end
function create_backup()
	local backup_files = {
		"/etc/config/bypass",
		"/etc/bypass/*"
	}
	local date = os.date("%Y%m%d")
	local tar_file = "/tmp/bypass-" .. date .. "-backup.tar.gz"
	nixio.fs.remove(tar_file)
	local cmd = "tar -czf " .. tar_file .. " " .. table.concat(backup_files, " ")
	luci.sys.call(cmd)
	luci.http.header("Content-Disposition", "attachment; filename=bypass-" .. date .. "-backup.tar.gz")
	luci.http.header("X-Backup-Filename", "bypass-" .. date .. "-backup.tar.gz")
	luci.http.prepare_content("application/octet-stream")
	luci.http.write(nixio.fs.readfile(tar_file))
	nixio.fs.remove(tar_file)
end
