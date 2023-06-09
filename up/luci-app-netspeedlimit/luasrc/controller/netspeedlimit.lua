module("luci.controller.netspeedlimit", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/netspeedlimit") then return end
	local page
        entry({"admin", "control"}, firstchild(), "Control", 44).dependent = false
	page = entry({"admin","control","netspeedlimit"},cbi("netspeedlimit"),_("Network speed limit"),67)
	page.dependent = true
 end
