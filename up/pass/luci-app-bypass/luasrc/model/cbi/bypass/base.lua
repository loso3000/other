local m,s,o
local bypass="bypass"

m=Map(bypass)
m:section(SimpleSection).template="bypass/status"

local server_table={}
luci.model.uci.cursor():foreach(bypass,"servers",function(s)
	if s.alias then
		server_table[s[".name"]]="[%s]:%s"%{string.upper(s.type),s.alias}
	elseif s.server and s.server_port then
		server_table[s[".name"]]="[%s]:%s:%s"%{string.upper(s.type),s.server,s.server_port}
	end
end)

local key_table={}
for key in pairs(server_table) do
	table.insert(key_table,key)
end
table.sort(key_table)

s = m:section(TypedSection, 'global')
s.anonymous=true

s:tab("Main", translate("Main"))

o = s:taboption("Main",ListValue,"global_server",translate("Main Server"))
o:value("", translate("Disable"))
for _,key in pairs(key_table) do o:value(key,server_table[key]) end

o = s:taboption("Main",ListValue,"udp_relay_server",translate("UDP Server"))
o:value("same",translate("Same as Global Server"))
for _,key in pairs(key_table) do o:value(key,server_table[key]) end

o = s:taboption("Main",ListValue,"nf_server",translate("Netflix Server"))
o:value("",translate("Same as Global Server"))
for _,key in pairs(key_table) do o:value(key,server_table[key]) end
o:depends("run_mode","gfw")
o:depends("run_mode","router")
o:depends("run_mode","all")

o = s:taboption("Main",Flag,"nf_proxy",translate("External Proxy Mode"),
translate("Forward Netflix Proxy through Main Proxy"))
for _,key in pairs(key_table) do o:depends("nf_server",key) end

o = s:taboption("Main",ListValue,"threads",translate("Multi Threads Option"))
o:value("0",translate("Auto Threads"))
o:value("1",translate("1 Thread"))
o:value("2",translate("2 Threads"))
o:value("4",translate("4 Threads"))
o:value("8",translate("8 Threads"))
o:value("16",translate("16 Threads"))
o:value("32",translate("32 Threads"))
o:value("64",translate("64 Threads"))
o:value("128",translate("128 Threads"))

o = s:taboption("Main",ListValue,"run_mode",translate("Running Mode"))
o:value("router",translate("Smart Mode"))
o:value("gfw",translate("GFW List Mode"))
o:value("all",translate("Global Mode"))
o:value("oversea",translate("Oversea Mode"))

o = s:taboption("Main",Flag,"gfw_mode",translate("Load GFW List"),
translate("If the domestic DNS does not hijack foreign domain name to domestic IP, No need to be enabled"))
o:depends("run_mode","router")


o = s:taboption("Main",ListValue,"dports",translate("Proxy Ports"))
o:value("1",translate("All Ports"))
o:value("2",translate("Only Common Ports"))

s:tab("DNS", translate("DNS"))
if luci.sys.call("test `grep MemTotal /proc/meminfo | awk '{print $2}'` -gt 233000") == 0 then
o = s:taboption("DNS",Flag,"adguardhome",translate("Used with AdGuardHome"),
translate("Luci-app-adguardhome require"))
if luci.sys.call("test `which AdGuardHome` && test -r /etc/init.d/AdGuardHome") == 0 then
o.default=1
else
o.default=0
end
end

o = s:taboption("DNS",Flag,"ad_smartdns",translate("Enable anti-AD smartdns"))
o.default=0

-- o = s:taboption("DNS",Flag,"dns_overlan",translate("Take over LAN DNS"),
-- translate("Redirect LAN device DNS to router(Do not disable if you Do not understand)"))
-- o.default=0

o = s:taboption("DNS",ListValue,"proxy_ipv6_mode",translate("IPV6 parsing mode"), translate("Choose the appropriate IPV6 parsing method, as the network is complex and not widely used. It is recommended to disable IPV6 parsing when the network is poor"))
o:value(1,translate("Only IPV4 parsing"))
o:value(2,translate("IPv4 and IPv6 dual stack IP automatic optimization"))
o:value(3,translate("Only IPV6 parsing"))
o.default=1

o = s:taboption("DNS",ListValue,"dns_mode_o",translate("Foreign Resolve Dns Mode"))
o:value("doh",translate("Use SmartDNS DoH query"))
o:value("dot",translate("Use SmartDNS DoT query"))
-- o:value("tcp",translate("Use SmartDNS TCP query"))
o.default="doh"

o = s:taboption("DNS",ListValue,"doh_dns_o",translate("Foreign DoH"))
o:value("cloudflare","Cloudflare DoH")
o:value("google",""..translate("Google").." DoH")
o:value("quad9","Quad9 DoH")
o:value("opendns","OpenDNS DoH")
o:value("quad101tw",""..translate("Taiwan").." DoH")
o:value("tiardns",""..translate("Singapore").." DoH")
o:value("tiardnsjp",""..translate("Japan").." DoH")
o:value("blahdnsgermany",""..translate("Germany").." DoH")
o:value("ahadnsny",""..translate("New York").." DoH")
o.default="cloudflare"
o:depends("dns_mode_o","doh")

o = s:taboption("DNS",ListValue,"dot_dns_o",translate("Foreign DoT"))
o:value("cloudflare","Cloudflare DoT")
o:value("google",""..translate("Google").." DoT")
o:value("quad9","Quad9 DoT")
o:value("quad101tw",""..translate("Taiwan").." DoT")
o:value("tiardns",""..translate("Singapore").." DoT")
o:value("tiardnsjp",""..translate("Japan").." DoT")
o:value("blahdnsgermany",""..translate("Germany").." DoT")
o:value("ahadnsny",""..translate("New York").." DoT")
o.default="cloudflare"


o:depends("dns_mode_o","dot")

o = s:taboption("DNS",ListValue,"dns_mode_d",translate("Domestic Resolve Dns Mode"),
translate("If DoH resolution is not normal,use UDP mode and select ISP DNS"))
o:value("doh",translate("Use SmartDNS DoH query"))
o:value("dot",translate("Use SmartDNS DoT query"))
o:value("udp",translate("Use SmartDNS UDP query"))
o.default="doh"

o = s:taboption("DNS",ListValue,"doh_dns_d",translate("Domestic DoH"))
o:value("alidns",""..translate("Ali").." DoH")
o:value("dnspod","Dnspod DoH")
o:value("360DNS","360DNS DoH")
o.default="alidns"
o:depends("dns_mode_d","doh")

o = s:taboption("DNS",ListValue,"dot_dns_d",translate("Domestic DoT"))
o:value("alidns",""..translate("Ali").." DoT")
o:value("dnspod","Dnspod DoT")
o:value("360DNS","360DNS DoT")
o.default="alidns"
o:depends("dns_mode_d","dot")

o = s:taboption("DNS",ListValue,"udp_dns_d",translate("Domestic DNS"))
o:value("isp",translate("ISP DNS"))
o:value("223.5.5.5,223.6.6.6","223.5.5.5,223.6.6.6 ("..translate("Ali").." DNS)")
o:value("119.29.29.29,119.28.28.28","119.29.29.29,119.28.28.28 (Dnspod DNS)")
o:value("114.114.114.114,114.114.115.115","114.114.114.114,114.114.115.115 (114 DNS)")
o:value("101.226.4.6,218.30.118.6","101.226.4.6,218.30.118.6 (360Secure DNS)")
o.default="isp"
o:depends("dns_mode_d","udp")

return m
