local m,s,o
local bypass="bypass"
local uci=luci.model.uci.cursor()
local server_count=0
local SYS=require"luci.sys"

function url(...)
    local url = string.format("admin/services/%s", bypass)
    local args = { ... }
    for i, v in pairs(args) do
        if v ~= "" then
            url = url .. "/" .. v
        end
    end
    return require "luci.dispatcher".build_url(url)
end
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

o=s:option(Flag,"monitor_enable",translate("Enable Process Deamon"))
o.default=1

o=s:option(Flag,"enable_switch",translate("Enable Auto Switch"))
o.default=1

o=s:option(Value,"switch_time",translate("Switch check cycly(second)"))
o.datatype="uinteger"
o.default=300
o:depends("enable_switch",1)

o=s:option(Value,"switch_timeout",translate("Check timout(second)"))
o.datatype="uinteger"
o.default=5
o:depends("enable_switch",1)

o=s:option(Value,"switch_try_count",translate("Check Try Count"))
o.datatype="uinteger"
o.default=3
o:depends("enable_switch",1)

-- [[ Rule Settings ]]--
s = m:section(TypedSection, "global_rules", translate("Rule status"))
s.anonymous = true

----ad_smartdns URL
o = s:option(Value, "ad_smartdns_url", translate("Smartdns anti-AD Update URL"))
o:value("https://anti-ad.net/anti-ad-for-smartdns.conf", translate("privacy-protection-tools/anti-AD"))
o:value("https://fastly.jsdelivr.net/gh/sirpdboy/iplist@release/ad_smartdns.txt", translate("sirpdboy/ad_smartdns"))
o.default = "https://fastly.jsdelivr.net/gh/sirpdboy/iplist@release/ad_smartdns.txt"
---- gfwlist URL
o = s:option(Value, "gfwlist_url", translate("GFW domains Update URL"))
o:value("https://fastly.jsdelivr.net/gh/YW5vbnltb3Vz/domain-list-community@release/gfwlist.txt", translate("v2fly/domain-list-community"))
o:value("https://fastly.jsdelivr.net/gh/Loukky/gfwlist-by-loukky/gfwlist.txt", translate("Loukky/gfwlist-by-loukky"))
o:value("https://fastly.jsdelivr.net/gh/gfwlist/gfwlist/gfwlist.txt", translate("gfwlist/gfwlist"))
o:value("https://fastly.jsdelivr.net/gh/sirpdboy/iplist@release/gfwlist.txt", translate("sirpdboy/gfwlist"))
o:value("https://supes.top/bypass/gfwlist.txt", translate("supes/gfwlist"))
o.default = "https://fastly.jsdelivr.net/gh/sirpdboy/iplist@release/gfwlist.txt"


----chnroute  URL
o = s:option(Value, "chnroute_url", translate("China IPv4 Update URL"))
o:value("https://ispip.clang.cn/all_cn.txt", translate("Clang.CN"))
o:value("https://ispip.clang.cn/all_cn_cidr.txt", translate("Clang.CN.CIDR"))
o:value("https://fastly.jsdelivr.net/gh/Loyalsoldier/geoip@release/text/cn.txt", translate("Loyalsoldier/geoip-CN"))
o:value("https://fastly.jsdelivr.net/gh/gaoyifan/china-operator-ip@ip-lists/china.txt", translate("gaoyifan/china-cn"))
o:value("https://fastly.jsdelivr.net/gh/soffchen/GeoIP2-CN@release/CN-ip-cidr.txt", translate("soffchen/GeoIP2-CN"))
o:value("https://fastly.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/CN-ip-cidr.txt", translate("Hackl0us/GeoIP2-CN"))
o:value("https://fastly.jsdelivr.net/gh/sirpdboy/iplist@release/all_cn.txt", translate("sirpdboy/all_cn"))
o:value("https://supes.top/bypass/all_cn.txt", translate("supes/all_cn"))
o.default = "https://fastly.jsdelivr.net/gh/sirpdboy/iplist@release/all_cn.txt"

----chnroute6 URL
o = s:option(Value, "chnroute6_url", translate("China IPv6 Update URL"))
o:value("https://ispip.clang.cn/all_cn_ipv6.txt", translate("Clang.CN.IPv6"))
o:value("https://fastly.jsdelivr.net/gh/gaoyifan/china-operator-ip@ip-lists/china6.txt", translate("gaoyifan/china-ipv6"))
o:value("https://fastly.jsdelivr.net/gh/sirpdboy/iplist@release/all_cn_ipv6.txt", translate("sirpdboy/all_cn_ipv6"))
o.default = "https://fastly.jsdelivr.net/gh/sirpdboy/iplist@release/all_cn_ipv6.txt"
o = s:option(Button, "UpdateRule", translate("Update All Rule List"))
o.inputstyle = "apply"
function o.write(t, n)
    luci.sys.call("/usr/share/bypass/update")
    luci.http.redirect(url("log"))
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
