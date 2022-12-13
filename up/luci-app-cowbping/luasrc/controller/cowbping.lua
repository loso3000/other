module("luci.controller.cowbping", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/cowbping") then return end
	local relaymode=(luci.sys.call("[ `grep -c 'work_mode .6.' /etc/config/cowbping 2>/dev/null` -ge 1 ] ") == 0)
	-- if relaymode then
		-- entry({"admin", "network", "cowbping"}, alias("admin", "network", "cowbping","cowbping"), _("无线中继"), 20).dependent = true
	-- else
		entry({"admin", "network", "cowbping"}, alias("admin", "network", "cowbping","cowbping"), _("网络检测"), 66).dependent = true
	-- end
	entry({"admin", "network", "cowbping", "cowbping"}, cbi("cowbping/cowbping"),_("设置"), 10).leaf = true
	entry({"admin", "network", "cowbping", "cowblog"}, form("cowbping/cowblog"),_("日志"), 20).leaf = true
end
