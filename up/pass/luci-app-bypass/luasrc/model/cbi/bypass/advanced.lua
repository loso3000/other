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


---- gfwlist URL
o = s:option(ListValue, "gfwlist_url", translate("GFW domains(gfwlist) Update URL"))
o:value("https://fastly.jsdelivr.net/gh/YW5vbnltb3Vz/domain-list-community@release/gfwlist.txt", translate("v2fly/domain-list-community"))
o:value("https://fastly.jsdelivr.net/gh/Loyalsoldier/v2ray-rules-dat@release/gfw.txt", translate("Loyalsoldier/v2ray-rules-dat"))
o:value("https://fastly.jsdelivr.net/gh/Loukky/gfwlist-by-loukky/gfwlist.txt", translate("Loukky/gfwlist-by-loukky"))
o:value("https://fastly.jsdelivr.net/gh/gfwlist/gfwlist/gfwlist.txt", translate("gfwlist/gfwlist"))
o:value("https://fastly.jsdelivr.net/gh/sirpdboy/iplist@main/gfwlist.txt", translate("sirpdboy/gfwlist"))
o:value("https://supes.top/bypass/gfwlist.txt", translate("supes/gfwlist"))
o.default = "https://fastly.jsdelivr.net/gh/sirpdboy/iplist@main/gfwlist.txt"

----chnroute  URL
o = s:option(ListValue, "chnroute_url", translate("China IPs(chnroute) Update URL"))
o:value("https://ispip.clang.cn/all_cn.txt", translate("Clang.CN"))
o:value("https://ispip.clang.cn/all_cn_cidr.txt", translate("Clang.CN.CIDR"))
o:value("https://fastly.jsdelivr.net/gh/soffchen/GeoIP2-CN@release/CN-ip-cidr.txt", translate("soffchen/GeoIP2-CN"))
o:value("https://fastly.jsdelivr.net/gh/Hackl0us/GeoIP2-CN@release/CN-ip-cidr.txt", translate("Hackl0us/GeoIP2-CN"))
o:value("https://fastly.jsdelivr.net/gh/sirpdboy/iplist@main/all_cn.txt", translate("sirpdboy/all_cn"))
o:value("https://supes.top/bypass/all_cn.txt", translate("supes/all_cn"))
o.default = "https://fastly.jsdelivr.net/gh/sirpdboy/iplist@main/all_cn.txt"

----chnroute6 URL
o = s:option(ListValue, "chnroute6_url", translate("China IPv6s(chnroute6) Update URL"))
o:value("https://ispip.clang.cn/all_cn_ipv6.txt", translate("Clang.CN.IPv6"))
o:value("https://fastly.jsdelivr.net/gh/sirpdboy/iplist@main/all_cn_ipv6.txt", translate("sirpdboy/all_cn_ipv6"))
o.default = "https://ispip.clang.cn/all_cn_ipv6.txt"

o = s:option(Button, "UpdateRule", translate("Update All Rule List"))
o.inputstyle = "apply"
function o.write(t, n)
    luci.sys.call("/usr/share/bypass/update  > /dev/null 2>&1 &")
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
