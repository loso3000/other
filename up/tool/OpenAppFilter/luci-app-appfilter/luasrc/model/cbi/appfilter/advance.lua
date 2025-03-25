local ds = require "luci.dispatcher"
local nxo = require "nixio"
local nfs = require "nixio.fs"
local ipc = require "luci.ip"
local sys = require "luci.sys"
local utl = require "luci.util"
local dsp = require "luci.dispatcher"
local uci = require "luci.model.uci"
local lng = require "luci.i18n"
local jsc = require "luci.jsonc"

local m, s
arg[1] = arg[1] or ""
m = Map("appfilter", translate(""), translate(""))

local v
v = m:section(SimpleSection)
v.template = "admin_network/advance"

m.apply_on_parse = true
m.on_after_apply = function(self,map)
	luci.sys.exec("/etc/init.d/appfilter start >/dev/null 2>&1")
end


return m
