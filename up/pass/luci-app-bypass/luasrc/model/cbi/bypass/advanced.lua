local m,s,o
local bypass="bypass"
local uci=luci.model.uci.cursor()
local server_count=0
local SYS=require"luci.sys"

local server_table={}
luci.model.uci.cursor():foreach("bypass","servers",function(s)
	if (s.type=="ss" and not nixio.fs.access("/usr/bin/ss-local")) or (s.type=="ssr" and not nixio.fs.access("/usr/bin/ssr-local")) or s.type=="socks5" or s.type=="tun" then
		return
	end
	if s.alias then
		server_table[s[".name"]]="[%s]:%s"%{string.upper(s.type),s.alias}
	elseif s.server and s.server_port then
		server_table[s[".name"]]="[%s]:%s:%s"%{string.upper(s.type),s.server,s.server_port}
	end
end)

local key_table={}
for key,_ in pairs(server_table) do
    table.insert(key_table,key)
end

table.sort(key_table)

m=Map("bypass")

s=m:section(TypedSection,"global",translate("Server failsafe auto swith settings"))
s.anonymous=true

o=s:option(Flag,"ad_list",translate("Enable DNS anti-AD"))
o.default=0

o=s:option(Flag,"monitor_enable",translate("Enable Process Deamon"))
o.default=1

o=s:option(Flag,"enable_switch",translate("Enable Auto Switch"))
o.default=1

o=s:option(Value,"start_delay",translate("Start Run Delay(second)"))
o.datatype="uinteger"
o.default=30

o=s:option(Value,"switch_time",translate("Switch check cycly(second)"))
o.datatype="uinteger"
o.default=120
o:depends("enable_switch",1)

o=s:option(Value,"switch_timeout",translate("Check timout(second)"))
o.datatype="uinteger"
o.default=5
o:depends("enable_switch",1)

o=s:option(Value,"switch_try_count",translate("Check Try Count"))
o.datatype="uinteger"
o.default=3
o:depends("enable_switch",1)

o = s:option(Button, "Reset", translate("Reset to defaults"))
o.inputstyle = "reload"
o.write = function()
	luci.sys.call("/etc/init.d/bypass reset")
	luci.http.redirect(luci.dispatcher.build_url("admin", "services", "bypass", "servers"))
end

-- [[ Rule Settings ]]--
s = m:section(TypedSection, "global_rules", translate("Rule status"))
s.anonymous = true

----ad_list URL
o = s:option(Value, "ad_url", translate("anti-AD Update URL"))
o:value("https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-domains.txt", translate("privacy-protection-tools/anti-ad-github"))
o:value("https://anti-ad.net/domains.txt", translate("privacy-protection-tools/anti-AD"))
o:value("https://github.com/sirpdboy/iplist/releases/latest/download/ad_list.txt", translate("sirpdboy/ad_list"))
o.default = "https://raw.githubusercontent.com/privacy-protection-tools/anti-AD/master/anti-ad-domains.txt"

---- gfwlist URL
o = s:option(Value, "gfwlist_url", translate("GFW domains Update URL"))
o:value("https://fastly.jsdelivr.net/gh/YW5vbnltb3Vz/domain-list-community@release/gfwlist.txt", translate("v2fly/domain-list-community"))
o:value("https://fastly.jsdelivr.net/gh/Loukky/gfwlist-by-loukky/gfwlist.txt", translate("Loukky/gfwlist-by-loukky"))
o:value("https://fastly.jsdelivr.net/gh/gfwlist/gfwlist/gfwlist.txt", translate("gfwlist/gfwlist"))
o:value("https://github.com/sirpdboy/iplist/releases/latest/download/gfwlist.txt", translate("sirpdboy/gfwlist"))
o:value("https://openwrt.ai/bypass/gfwlist.txt", translate("supes/gfwlist"))
o.default = "https://fastly.jsdelivr.net/gh/YW5vbnltb3Vz/domain-list-community@release/gfwlist.txt"

----chnroute  URL
o = s:option(Value, "chnroute_url", translate("China IPv4 Update URL"))
o:value("https://ispip.clang.cn/all_cn.txt", translate("Clang.CN"))
o:value("https://ispip.clang.cn/all_cn_cidr.txt", translate("Clang.CN.CIDR"))
o:value("https://fastly.jsdelivr.net/gh/Loyalsoldier/geoip@release/text/cn.txt", translate("Loyalsoldier/geoip-CN"))
o:value("https://fastly.jsdelivr.net/gh/gaoyifan/china-operator-ip@ip-lists/china.txt", translate("gaoyifan/china-cn"))
o:value("https://fastly.jsdelivr.net/gh/soffchen/GeoIP2-CN@release/CN-ip-cidr.txt", translate("soffchen/GeoIP2-CN"))
o:value("https://fastly.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/CN-ip-cidr.txt", translate("Hackl0us/GeoIP2-CN"))
o:value("https://github.com/sirpdboy/iplist/releases/latest/download/all_cn.txt", translate("sirpdboy/all_cn"))
o:value("https://openwrt.ai/bypass/all_cn.txt", translate("supes/all_cn"))
o.default = "https://ispip.clang.cn/all_cn.txt"

----chnroute6 URL
o = s:option(Value, "chnroute6_url", translate("China IPv6 Update URL"))
o:value("https://ispip.clang.cn/all_cn_ipv6.txt", translate("Clang.CN.IPv6"))
o:value("https://fastly.jsdelivr.net/gh/gaoyifan/china-operator-ip@ip-lists/china6.txt", translate("gaoyifan/china-ipv6"))
o:value("https://github.com/sirpdboy/iplist/releases/latest/download/all_cn_ipv6.txt", translate("sirpdboy/all_cn_ipv6"))
o.default = "https://ispip.clang.cn/all_cn_ipv6.txt"

----domains URL
o = s:option(Value, "domains_url", translate("China Domains Update URL"))
o:value("https://fastly.jsdelivr.net/gh/yubanmeiqin9048/domain@release/accelerated-domains.china.txt", translate("yubanmeiqin9048/domains.china"))
o:value("https://github.com/sirpdboy/iplist/releases/latest/download/domains_cn.txt", translate("sirpdboy/domains_cn"))
o.default = "https://fastly.jsdelivr.net/gh/yubanmeiqin9048/domain@release/accelerated-domains.china.txt"

o = s:option(Button, "UpdateRule", translate("Update All Rule List"))
o.inputstyle = "apply"
o.write = function()
    luci.sys.call("bash /usr/share/bypass/update")
    luci.http.redirect(luci.dispatcher.build_url("admin", "services", "bypass", "log"))
end

s=m:section(TypedSection,"socks5_proxy",translate("Global SOCKS5 Server"))
s.anonymous=true

o=s:option(ListValue,"server",translate("Server"))
o:value("",translate("Disable"))
o:value("same",translate("Same as Global Server"))
for _,key in pairs(key_table) do o:value(key,server_table[key]) end

o=s:option(Value,"local_port",translate("Local Port"))
o.datatype="port"
o.placeholder=1080

return m
