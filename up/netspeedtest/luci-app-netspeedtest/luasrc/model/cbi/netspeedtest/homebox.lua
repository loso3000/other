local o = require "luci.sys"


local m, s ,o

m = Map("netspeedtest", "<font color='green'>" .. translate("Net Speedtest") .."</font>",translate( "Network speed diagnosis test (including intranet and extranet)<br/>For specific usage, see:") ..translate("<a href=\'https://github.com/sirpdboy/netspeedtest.git' target=\'_blank\'>GitHub @sirpdboy/netspeedtest</a>") )

s = m:section(TypedSection, "homebox", translate('Lan homebox Web'))
s.anonymous = true

o=s:option(Flag,"enabled",translate("Enable"))
o.default=0

o = s:option(DummyValue, '', '')
o.rawhtml = true
o.template ='netspeedtest/homebox'

local o=luci.http.formvalue("cbi.apply")
if o then
  io.popen("/etc/init.d/netspeedtest restart")
end
return m
