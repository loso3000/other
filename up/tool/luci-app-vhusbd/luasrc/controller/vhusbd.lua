--[[
LuCI - Lua Configuration Partition Expansion
 Copyright (C) 2022-2024  sirpdboy <herboy2008@gmail.com>
]]--

local fs = require "nixio.fs"
module("luci.controller.vhusbd", package.seeall)

function index()
	
	if not nixio.fs.access("/etc/config/vhusbd") then return end
	local e = entry({"admin", "nas", "vhusbd"}, cbi("vhusbd"), _("VirtualHere"), 46).dependent = true
	e.dependent = true
	e.acl_depends = { "luci-app-vhusbd" }
	
	entry({"admin", "nas", "vhusbd", "status"}, call("vhusbd_status")).leaf = true
end

function vhusbd_status()
	local status = {}
	status.running = luci.sys.call("pidof vhusbd >/dev/null")==0
	luci.http.prepare_content("application/json")
	luci.http.write_json(status)
end
