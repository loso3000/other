x = [[<br><font color="Red">配置文件是直接编辑的！除非你知道自己在干什么，否则请不要轻易修改这些配置文件。配置不正确可能会导致不能联网等错误。</font>]]

m=Map("bridge", translate("透明网桥"),
translate("<font color=\"green\">让路由成为与上级路由通信，无感知，并具备防火墙功能的透明网桥设备。</font><br>") ..
translate("<br><font color=orange>✯</font>适用于有上级路由，需要软路由的一些功能但又不想多级NAT的网络环境。") ..
translate("<br><font color=orange>✯</font>启用透明网桥后软路由的WEB控制台为网桥IP。") ..
translate("<br><font color=orange>✯</font>启用透明网桥后软路由上的一些功能会失效，如：Full Cone、多拨等。") ..
translate("<br><font color=orange>✯</font>关闭后恢复插件安装时的网络设置，WEB控制台恢复为原始设置的IP。"))

m:section(SimpleSection).template  = "bridge/bridge_status"

s = m:section(TypedSection, "bridge")
s.addremove = false
s.anonymous = true
s:tab("bridge", translate("设置"))
o = s:taboption("bridge", Flag, "enabled", translate("开启"))
o.rmempty = false

ping = s:taboption("bridge", DummyValue, "ping", translate("检查网络"))
ping.template = "bridge/diagnostics"

gateway = s:taboption("bridge", Value, "gateway", translate("网关IP"),
translate("必须是主路由web访问IP地址相同<code>必须设置</code>"))
gateway.datatype="ipaddr"
gateway.rmempty = true
gateway.anonymous = false

ipaddr = s:taboption("bridge", Value, "ipaddr", translate("网桥IP"), 
translate("主路由同网段未冲突的IP地址，<b><font color=\"red\">即是该路由web访问的IP</font></b>"))
for own_ip in luci.util.execi("uci get network.lan.ipaddr") do
	ipaddr:value(own_ip, translate(own_ip .. " --当前路由的IP--"))
end
ipaddr.datatype="ipaddr"
ipaddr.rmempty = true
ipaddr.anonymous = false

dns = s:taboption("bridge", DynamicList, "dns", translate("DNS IP"), 
translate("可以设置主路由的IP，或可到<a href='https://dnsdaquan.com' target='_blank'> DNS大全 </a>获取更多"))
dns:value("223.5.5.5", translate("阿里DNS：223.5.5.5"))
dns:value("223.6.6.6", translate("阿里DNS：223.6.6.6"))
dns:value("101.226.4.6", translate("DNS派：101.226.4.6"))
dns:value("218.30.118.6", translate("DNS派：218.30.118.6"))
dns:value("180.76.76.76", translate("百度DNS：180.76.76.76"))
dns:value("114.114.114.114", translate("114DNS：114.114.114.114"))
dns:value("114.114.115.115", translate("114DNS：114.114.115.115"))
dns.rmempty = true
dns.datatype = "ipaddr"
dns.cast = "string"

netmask = s:taboption("bridge", Value, "netmask", translate("Netmask"))
netmask:value("255.255.255.0", translate("255.255.255.0"))
netmask:value("255.255.0.0", translate("255.255.0.0"))
netmask:value("255.0.0.0", translate("255.0.0.0"))
netmask.datatype = "ipmask"
netmask.anonymous = false

ignore = s:taboption("bridge", ListValue, "dhcp", translate("DHCP设置"),
translate("当前路由的DHCP自动获取IP服务的接管"))
ignore:value("0", translate("关闭"))
ignore:value("1", translate("强制开启"))
ignore.default = ignore

dhcpv6 = s:taboption("bridge", Flag, "dhcpv6", translate("DHCPV6设置"),
translate("关闭DHCP里IPv6的服务<code>可忽略</code>"))
dhcpv6:depends("dhcp", 0)
dhcpv6.rmempty = true

wan = s:taboption("bridge", Flag, "wan", translate("修改WAN口"),
translate("把WAN口变成LAN口"))
wan.rmempty = true

o = s:taboption("bridge", Value, "network", translate("网口数量"),
translate("该路由物理网口数量，留空则自动获取"))
o.anonymous = false

firewall = s:taboption("bridge", Flag, "firewall", translate("防火墙设置"))
firewall.rmempty = true

fullcone = s:taboption("bridge", Flag, "fullcone", translate("SYN-flood"),
translate("关闭防火墙ISYN-flood防御服务<code>建议开启</code>"))
fullcone:depends("firewall", true)
fullcone.rmempty = true

syn_flood = s:taboption("bridge", Flag, "syn_flood", translate("FullCone-NAT"),
translate("关闭防火墙IFullCone-NAT服务<code>可忽略</code>"))
syn_flood:depends("firewall", true)
syn_flood.rmempty = true

masq = s:taboption("bridge", Flag, "masq", translate("IP动态伪装"),
translate("开启防火墙IP动态伪装IP服务<code>建议开启</code>"))
masq:depends("firewall", true)
masq.rmempty = true

omasq = s:taboption("bridge", Flag, "omasq", translate("防火墙规定"),
translate("添加自定义防火墙规则。多个命令合并一行，用[ ; ]分割<code>建议开启</code>"))
omasq:depends("firewall", true)

ip_tables = s:taboption("bridge", Value, "ip_tables", translate(" "))
ip_tables.default = "iptables -t nat -I POSTROUTING -j MASQUERADE"
ip_tables.anonymous = false
ip_tables:depends("omasq", true)
--TextValue

if nixio.fs.access("/etc/config/network") then
	s:tab("netwrokconf", translate("修改network"),
	translate("本页是/etc/config/network的配置文件内容，编辑后点击<code>保存&应用</code>按钮后重启生效") .. x)
	o = s:taboption("netwrokconf", Button, "_network")
	o.inputtitle = translate("重启network")
	o.inputstyle = "apply"
	function o.write(self, section)
		luci.sys.exec("/etc/init.d/network restart >/dev/null &")
	end

	conf = s:taboption("netwrokconf", Value, "netwrokconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 25
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/config/network") or ""
	end
	function conf.write(self, section, value)
		if value then
			value = value:gsub("\r\n?", "\n")
			nixio.fs.writefile("/tmp/network", value)
				if (luci.sys.call("cmp -s /tmp/network /etc/config/network") == 1) then
					nixio.fs.writefile("/etc/config/network", value)
					luci.sys.call("/etc/init.d/network restart >/dev/null &")
				end
			nixio.fs.remove("/tmp/network")
		end
	end
end

if nixio.fs.access("/etc/config/dhcp") then
	s:tab("dhcpconf", translate("修改DHCP"), translate("本页是/etc/config/dhcp的配置文件内容，编辑后点击<code>保存&应用</code>按钮后重启生效") .. x)
	o = s:taboption("dhcpconf", Button, "_dhcp")
	o.inputtitle = translate("重启dnsmasq")
	o.inputstyle = "apply"
	function o.write(self, section)
		luci.sys.exec("/etc/init.d/dnsmasq reload >/dev/null &")
	end

	conf = s:taboption("dhcpconf", Value, "dhcpconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 25
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/config/dhcp") or ""
	end
	function conf.write(self, section, value)
		if value then
			value = value:gsub("\r\n?", "\n")
			nixio.fs.writefile("/tmp/dhcp", value)
				if (luci.sys.call("cmp -s /tmp/dhcp /etc/config/dhcp") == 1) then
					nixio.fs.writefile("/etc/config/dhcp", value)
					luci.sys.call("/etc/init.d/dnsmasq reload >/dev/null &")
				end
			nixio.fs.remove("/tmp/dhcp")
		end
	end
end

if nixio.fs.access("/etc/config/firewall") then
	s:tab("firewallconf", translate("修改firewall"), translate("本页是/etc/config/firewall的配置文件内容，编辑后点击<code>保存&应用</code>按钮后重启生效") .. x)
	o = s:taboption("firewallconf", Button, "_firewall")
	o.inputtitle = translate("重启firewall")
	o.inputstyle = "apply"
	function o.write(self, section)
		luci.sys.exec("/etc/init.d/firewall reload >/dev/null &")
	end

	conf = s:taboption("firewallconf", Value, "firewallconf", nil)
	conf.template = "cbi/tvalue"
	conf.rows = 25
	conf.wrap = "off"
	function conf.cfgvalue(self, section)
		return nixio.fs.readfile("/etc/config/firewall") or ""
	end
	function conf.write(self, section, value)
		if value then
		value = value:gsub("\r\n?", "\n")
		nixio.fs.writefile("/tmp/firewall", value)
			if (luci.sys.call("cmp -s /tmp/firewall /etc/config/firewall") == 1) then
				nixio.fs.writefile("/etc/config/firewall", value)
				luci.sys.call("/etc/init.d/firewall reload >/dev/null &")
			end
		nixio.fs.remove("/tmp/firewall")
		end
	end
end

return m
