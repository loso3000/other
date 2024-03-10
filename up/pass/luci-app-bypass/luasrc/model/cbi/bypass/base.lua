local m,s,o
local bypass="bypass"
local function is_bin(e)
	return luci.sys.exec('type -t -p "%s"' % e) ~= "" and true or false
end

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

o = s:taboption("Main", Flag, "enabled", translate("Enable Service[Master Switch]"))
o.rmempty = false

o = s:taboption("Main",ListValue,"global_server",translate("Main Server"))
o:value("", translate("Disable"))
for _,key in pairs(key_table) do o:value(key,server_table[key]) end

o = s:taboption("Main",ListValue,"udp_relay_server",translate("UDP Server"))
o:value("", translate("Disable"))
o:value("same",translate("Same as Global Server"))
for _,key in pairs(key_table) do o:value(key,server_table[key]) end

o = s:taboption("Main",ListValue,"nf_server",translate("Netflix Server"))
o:value("", translate("Disable"))
o:value("same",translate("Same as Global Server"))
for _,key in pairs(key_table) do o:value(key,server_table[key]) end
o:depends("run_mode","gfw")
o:depends("run_mode","router")
o:depends("run_mode","all")

o = s:taboption("Main",DynamicList,"nf_dns",translate("Netflix Query DNS"))
o:value("cloudflare_doh","Cloudflare DNS DoH(1.1.1.1)")
o:value("cloudflare2_doh","Cloudflare DNS DoH(162.159.36.1)")
o:value("google_doh",""..translate("Google").." DNS DoH(8.8.4.4)")
o:value("google2_doh",""..translate("Google").." DNS DoH(8.8.8.8)")
o:value("quad9_doh","Quad9 DNS DoH(9.9.9.9)")
o:value("quad92_doh","Quad9 DNS DoH(149.112.112.112)")
o:value("cloudflare_tcp","Cloudflare DNS Tcp(1.1.1.1)")
o:value("cloudflare2_tcp","Cloudflare DNS Tcp(1.0.0.1)")
o:value("google_tcp",""..translate("Google").." DNS Tcp(8.8.4.4)")
o:value("google2_tcp",""..translate("Google").." DNS Tcp(8.8.8.8)")
o:value("quad9_tcp","Quad9 DNS Tcp(9.9.9.9)")
o:value("quad92_tcp","Quad9 DNS Tcp(149.112.112.112)")
o:value("opendns_tcp","OpenDNS DNS Tcp(208.67.222.222)")
o:value("opendns2_tcp","OpenDNS DNS Tcp(208.67.220.220)")
o.default="cloudflare2_doh"
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

o = s:taboption("Main",Value,"dports",translate("Proxy Ports"),
translate("Custom format is 22,53,80,143,443,465,587,853,993,995,9418"))
o:value("",translate("All Ports"))
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

o = s:taboption("DNS",ListValue,"dns_mode",translate("DNS Query Method"))
o:value(1, translate("Use SmartDNS query"))
if is_bin("mosdns") then
o:value(2, translate("Use MOSDNS query"))
end

o = s:taboption("DNS",Flag,"proxy_ipv6_mode",translate("IPV6 parsing"), translate("Use DNS to return IPv6 records"))
o.default=0

o = s:taboption("DNS",Flag,"dns_hijack",translate("Take over LAN DNS"),
translate("Redirect LAN device DNS to router(Do not disable if you do not understand)"))
o.default=1

o = s:taboption("DNS",Flag,"dns_pollution",translate("Preventing DNS pollution"))
o.default=0

o = s:taboption("DNS",DynamicList,"dns_remote",translate("Remote Query DNS"))
o:value("cloudflare_doh","Cloudflare DNS DoH(1.1.1.1)")
o:value("cloudflare2_doh","Cloudflare DNS DoH(162.159.36.1)")
o:value("cloudflare3_doh","Cloudflare DNS DoH(dns.cloudflare.com)")
o:value("google_doh",""..translate("Google").." DNS DoH(8.8.4.4)")
o:value("google2_doh",""..translate("Google").." DNS DoH(8.8.8.8)")
o:value("google3_doh",""..translate("Google").." DNS DoH(dns.google)")
o:value("quad9_doh","Quad9 DNS DoH(9.9.9.9)")
o:value("quad92_doh","Quad9 DNS DoH(149.112.112.112)")
o:value("cloudflare_tcp","Cloudflare DNS Tcp(1.1.1.1)")
o:value("cloudflare2_tcp","Cloudflare DNS Tcp(1.0.0.1)")
o:value("google_tcp",""..translate("Google").." DNS Tcp(8.8.4.4)")
o:value("google2_tcp",""..translate("Google").." DNS Tcp(8.8.8.8)")
o:value("quad9_tcp","Quad9 DNS Tcp(9.9.9.9)")
o:value("quad92_tcp","Quad9 DNS Tcp(149.112.112.112)")
o:value("opendns_tcp","OpenDNS DNS Tcp(208.67.222.222)")
o:value("opendns2_tcp","OpenDNS DNS Tcp(208.67.220.220)")
o.default="cloudflare_doh"

o = s:taboption("DNS",DynamicList,"dns_local",translate("Local Query DNS"))
o:value("isp",translate("ISP DNS"))
o:value("alidns_doh",""..translate("Ali").." DNS DoH(223.5.5.5)")
o:value("alidns2_doh",""..translate("Ali").." DNS DoH(223.6.6.6)")
o:value("alidns3_doh",""..translate("Ali").." DNS DoH(dns.alidns.com)")
o:value("dnspod_doh",""..translate("Tencent").." DNS DoH(175.24.219.66)")
o:value("dnspod2_doh",""..translate("Tencent").." DNS DoH(doh.pub)")
o:value("360dns_doh","360 DNS DoH(101.226.4.6)")
o:value("360dns2_doh","360 DNS DoH(doh.360.cn)")
o:value("alidns_tcp",""..translate("Ali").." DNS Tcp(223.5.5.5)")
o:value("alidns2_tcp",""..translate("Ali").." DNS Tcp(223.6.6.6)")
o:value("dnspod_tcp",""..translate("Tencent").." DNS Tcp(175.24.219.66)")
o:value("360dns_tcp","360 DNS Tcp(101.226.4.6)")
o:value("360dns2_tcp","360DNS DNS Tcp(123.6.48.18)")
o:value("baidu_tcp",""..translate("BaiDu").."DNS Tcp(180.76.76.76)")
o:value("114dns_tcp","114DNS DNS Tcp(114.114.114.114)")
o:value("114dns2_tcp","114DNS DNS Tcp(114.114.115.115)")
o.default="alidns_doh"

o = s:taboption("DNS",Value, "bootstrap_dns", translate("Bootstrap DNS servers"), translate("Bootstrap DNS server is used to resolve IP addresses in the upstream DoH/DoT resolution list"))
o:value("119.29.29.29", ""..translate("Tencent").." DNS (119.29.29.29)")
o:value("119.28.28.28", ""..translate("Tencent").." DNS (119.28.28.28)")
o:value("223.5.5.5", ""..translate("Ali").."(223.5.5.5)")
o:value("223.6.6.6", ""..translate("Ali").."(223.6.6.6)")
o:value("114.114.114.114", translate("114DNS(114.114.114.114)"))
o:value("114.114.115.115", translate("114DNS(114.114.115.115)"))
o:value("180.76.76.76", ""..translate("BaiDu").." DNS(180.76.76.76)")
o:value("8.8.8.8",""..translate("Google").." DNS(8.8.8.8)")
o:value("8.8.4.4", ""..translate("Google").." DNS(8.8.4.4)")
o:value("1.1.1.1", translate("CloudFlare DNS(1.1.1.1)"))
o.default = "114.114.114.114"


return m
