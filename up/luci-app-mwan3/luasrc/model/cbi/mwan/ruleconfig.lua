-- Copyright 2014 Aedan Renner <chipdankly@gmail.com>
-- Copyright 2018 Florian Eckert <fe@dev.tdt.de>
-- Licensed to the public under the GNU General Public License v2.

local dsp = require "luci.dispatcher"
local util   = require("luci.util")

local m, s, o

arg[1] = arg[1] or ""


m = Map("mwan3", translatef("MWAN Rule Configuration - %s", arg[1]))
m.redirect = dsp.build_url("admin", "network", "mwan", "rule")

s = m:section(NamedSection, arg[1], "rule", "")
s.addremove = false
s.dynamic = false

o = s:option(ListValue, "family", translate("Internet Protocol"))
o.default = ""
o:value("", translate("IPv4 and IPv6"))
o:value("ipv4", translate("IPv4 only"))
o:value("ipv6", translate("IPv6 only"))

o = s:option(Value, "src_ip", translate("Source address"),
	translate("Supports CIDR notation (eg \"192.168.100.0/24\") without quotes"))
o.datatype = ipaddr

o = s:option(Value, "src_port", translate("Source port"),
	translate("May be entered as a single or multiple port(s) (eg \"22\" or \"80,443\") or as a portrange (eg \"1024:2048\") without quotes"))
o:depends("proto", "tcp")
o:depends("proto", "udp")

o = s:option(Value, "dest_ip", translate("Destination address"),
	translate("Supports CIDR notation (eg \"192.168.100.0/24\") without quotes"))
o.datatype = ipaddr

o = s:option(Value, "dest_port", translate("Destination port"),
	translate("May be entered as a single or multiple port(s) (eg \"22\" or \"80,443\") or as a portrange (eg \"1024:2048\") without quotes"))
o:depends("proto", "tcp")
o:depends("proto", "udp")

o = s:option(Value, "proto", translate("Protocol"),
	translate("View the content of /etc/protocols for protocol description"))
o.default = "all"
o.rmempty = false
o:value("all")
o:value("tcp")
o:value("udp")
o:value("icmp")
o:value("esp")

sticky = s:option(ListValue, "sticky", translate("Sticky"),
	translate("Traffic from the same source IP address that previously matched this rule within the sticky timeout period will use the same WAN interface"))
sticky.default = "0"
sticky:value("1", translate("Yes"))
sticky:value("0", translate("No"))

timeout = s:option(Value, "timeout", translate("Sticky timeout"),
	translate("Seconds. Acceptable values: 1-1000000. Defaults to 600 if not set"))
timeout.datatype = "range(1, 1000000)"

ipset = s:option(Value, "ipset", translate("IPset"),
	translate("Name of IPset rule. Requires IPset rule in /etc/dnsmasq.conf (eg \"ipset=/youtube.com/youtube\")"))

policy = s:option(Value, "use_policy", translate("Policy assigned"))
m5.uci:foreach("mwan3", "policy",
	function(s)
		policy:value(s['.name'], s['.name'])
	end
)
o:value("unreachable", translate("unreachable (reject)"))
o:value("blackhole", translate("blackhole (drop)"))
o:value("default", translate("default (use main routing table)"))
local e=luci.http.formvalue("cbi.apply")
if e then
  io.popen("/etc/init.d/mwan3 restart")
end

-- m5.apply_on_parse = true
-- m5.on_after_apply = function(self,map)
-- 	luci.sys.exec("/etc/init.d/mwan3 restart")
-- end
return m
