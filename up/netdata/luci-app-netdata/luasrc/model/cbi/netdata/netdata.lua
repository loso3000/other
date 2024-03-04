-- Copyright 2018-2022 sirpdboy (herboy2008@gmail.com)
-- https://github.com/sirpdboy/luci-app-netdata
require("luci.util")
local fs = require "nixio.fs"
local http = require "luci.http"
local uci = require"luci.model.uci".cursor()

local m, s ,o

ssl=uci:get('netdata', 'netdata', 'enable_ssl')
nginx=uci:get('netdata', 'netdata', 'nginx_support') 

m = Map("netdata", translate("NetData"), translate("Netdata is high-fidelity infrastructure monitoring and troubleshooting.Open-source, free, preconfigured, opinionated, and always real-time.")..translate("</br>For specific usage, see:")..translate("<a href=\'https://github.com/sirpdboy/luci-app-netdata.git' target=\'_blank\'>GitHub @sirpdboy/luci-app-netdata </a>") )
m:section(SimpleSection).template = "netdata_status"

m.apply_on_parse=true
function m.on_apply(self)
luci.sys.call("/etc/init.d/netdata reload > /dev/null 2>&1 &")
luci.http.redirect(luci.dispatcher.build_url("admin","status","netdata","setting"))
end

-- m.apply_on_parse = true
-- m.on_after_apply = function(self,map)
--   luci.sys.exec("/etc/init.d/netdata start")
-- end

s = m:section(TypedSection, "netdata", translate("Global Settings"))
s.addremove=false
s.anonymous=true

o=s:option(Flag,"enabled",translate("Enable"))
o.default=0

o=s:option(Value, "port",translate("Set the netdata access port"))
o.datatype="uinteger"
o.default=19999

o=s:option(Flag, 'enable_ssl', translate('Enable SSL'),translate("Mandatory use of HTTPS access requires uploading SSL certificate"))
o:depends("nginx_support", false)

o=s:option(Value, 'cert_file', translate('Cert file'))
o.placeholder = '/etc/cert.crt'
o.default='/etc/cert.crt'
o.rmempty = false
o:depends("enable_ssl", true)

o=s:option(Value, 'key_file', translate('Cert Key file'))
o.placeholder = '/etc/cert.key'
o.default='/etc/cert.key'
o.rmempty = false
o:depends("enable_ssl", true)

o=s:option(Flag, 'nginx_support', translate('Nginx Support'),translate('To enable this feature you need install <b>luci-nginx</b> and <b>luci-ssl-nginx</b>first'))
o.rmempty = true
o.default=0

o=s:option(Flag, 'auth', translate('Enable Auth'))
o.rmempty = true
o:depends("nginx_support", true)

o=s:option(Value, 'user_passwd', translate('Login Username and Password hash'))
o.placeholder = 'admin:$apr1$t7qQjoqb$YBHtAb7VGSkjIdObMG.Oy0'
o.default='admin:$apr1$t7qQjoqb$YBHtAb7VGSkjIdObMG.Oy0'
o.rmempty = false
o:depends("auth", true)

return m
