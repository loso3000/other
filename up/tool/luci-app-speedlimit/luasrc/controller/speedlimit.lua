module("luci.controller.speedlimit", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/speedlimit") then return end
	local e = entry({"admin","control","speedlimit"},alias("admin", "control", "speedlimit", "speedlimit"),_("Speed Limit"), 54)
	e.dependent = false
	e.acl_depends = { "luci-app-partexp" }
	entry({"admin", "control", "speedlimit", "speedlimit"},cbi("speedlimit"),_("Speed Limit"),67).leaf = true 
 end
