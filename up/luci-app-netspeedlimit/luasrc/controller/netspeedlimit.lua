module("luci.controller.netspeedlimit", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/netspeedlimit") then return end
	
    entry({"admin", "control"}, firstchild(), "Control", 44).dependent = false
    entry({"admin", "control", "netspeedlimit"}, cbi("netspeedlimit"), _("Netspeedlimit"), 10).dependent =true
    entry({"admin", "control", "netspeedlimit", "status"}, call("act_status")).leaf = true

 end
function act_status()
    local sys  = require "luci.sys"
    local e = {} 
    e.status = sys.call("[ `(tc qdisc show dev br-lan | head -1) 2>/dev/null | grep -c 'default' 2>/dev/null` -gt 0 ] > /dev/null") == 0 
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end
