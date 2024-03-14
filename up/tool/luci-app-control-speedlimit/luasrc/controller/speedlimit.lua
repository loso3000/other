module("luci.controller.speedlimit", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/speedlimit") then return end
        entry({"admin", "control"}, firstchild(), "Control", 44).dependent = false
	local e = entry({"admin","control","speedlimit"},cbi("speedlimit"),_("Speed Limit"),67)
	e.dependent=false
        e.acl_depends = { "luci-app-speedlimit" }
 end
