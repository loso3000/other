-- Copyright 2019 X-WRT <dev@x-wrt.com>
-- Copyright 2022 sirpdboy

module("luci.controller.netwizard", package.seeall)
function index()
	if not nixio.fs.access("/etc/config/netwizard") then
		return
	end
		local page 
		page = entry({"admin","system", "netwizard"}, cbi("netwizard/netwizard"), _("Inital Setup"), -1)
		page.dependent = true
end
