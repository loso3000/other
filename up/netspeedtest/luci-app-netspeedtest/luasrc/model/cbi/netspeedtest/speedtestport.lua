-- Copyright (C) 2020-2022  sirpdboy  <herboy2008@gmail.com> https://github.com/sirpdboy/netspeedtest
require("luci.util")
local o,s,e

m = Map("netspeedtest", "<font color='green'>" .. translate("Net Speedtest") .."</font>",translate( "Network speed diagnosis test (including intranet and extranet)<br/>For specific usage, see:") ..translate("<a href=\'https://github.com/sirpdboy/netspeedtest.git' target=\'_blank\'>GitHub @sirpdboy/netspeedtest</a>") )

s = m:section(TypedSection, "speedtestport", translate('Server Port Latency Test'))
s.addremove=false
s.anonymous=true


e = s:option(DummyValue, '', '')
e.rawhtml = true
e.template ='netspeedtest/speedtestport'
e =s:option(DummyValue, '', '')
e.rawhtml = true
e.template = 'netspeedtest/log'

return m
