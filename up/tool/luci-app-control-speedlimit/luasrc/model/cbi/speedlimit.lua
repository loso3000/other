local sys = require "luci.sys"
--Author: wulishui <wulishui@gmail.com>
local button = ""
local state_msg = ""
local m,s,n
local running=(luci.sys.call("[ `(tc qdisc show dev br-lan | head -1) 2>/dev/null | grep -c 'default' 2>/dev/null` -gt 0 ] > /dev/null") == 0)

if running then
	state_msg = "<b><font color=\"green\">" .. translate("Running") .. "</font></b>"
else
	state_msg = "<b><font color=\"red\">" .. translate("Not running") .. "</font></b>"
end

m = Map("speedlimit", translate("SpeedLimit"))
m.description = translate("Speed Limit can limit user's speed via MAC or IP or IP range.").. translate("The denomination is MB/S. You can type in 0 and move the rule to top to unlimit someone to exclude for overlapping IP range, click --custom-- (at the bottom of the MAC list) to type in IP or IP range or IP with mask.") .. "<br/><br/>" .. translate("Running state") .. state_msg .. "<br />"

s = m:section(TypedSection, "usrlimit")
s.template = "cbi/tblsection"
s.anonymous = true
s.addremove = true
s.sortable  = true

e = s:option(Flag, "enable", translate("Enable"))
e.rmempty = false

usr = s:option(Value, "usr",translate("MAC/IP/IPrange<font color=\"green\">(MAC support the separation is : or - .)</font>"))
sys.net.mac_hints(function(mac, name)
	usr:value(mac, "%s (%s)" %{ mac, name })
end)
usr.size = 8

dl = s:option(Value, "download", translate("downloads"))
dl.rmempty = false
dl.size = 8

ul = s:option(Value, "upload", translate("uploads"))
ul.rmempty = false
ul.size = 8

comment = s:option(Value, "comment", translate("Comment"))
ul.rmempty = false
comment.size = 8

return m
