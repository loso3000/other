-- Copyright 2019 X-WRT <dev@x-wrt.com>
-- Copyright 2022-2023 sirpdboy

module("luci.controller.netwizard", package.seeall)
function index()
	
	entry({"admin", "system", "netwizard"}).dependent = true
	entry({"admin", "system", "netwizard", "show"}, call("show_menu")).leaf = true
	entry({"admin", "system", "netwizard", "hide"}, call("hide_menu")).leaf = true

	if not nixio.fs.access("/etc/config/netwizard") then return end
	if not nixio.fs.access("/etc/config/netwizard_hide") then
	        e = entry({"admin","system", "netwizard"}, alias("admin","system", "netwizard","settings"), _("Inital Setup"), -1)
		e.dependent = true
		-- e.acl_depends = { "luci-app-netwizard" }
	end
	entry({"admin","system", "netwizard","settings"}, cbi("netwizard/netwizard"), _("Inital Setup"), 1).dependent = true
end

function hide_menu()
	luci.sys.call("touch /etc/config/netwizard_hide")
	luci.sys.call("rm -rf /tmp/luci-*")
	-- luci.sys.call("/etc/init.d/rpcd restart >/dev/null")
	luci.http.redirect(luci.dispatcher.build_url("admin", "system", "system"))
end

function show_menu()
	luci.sys.call("rm -rf /etc/config/netwizard_hide")
	luci.sys.call("rm -rf /tmp/luci-*")
	-- luci.sys.call("/etc/init.d/rpcd restart >/dev/null")
	luci.http.redirect(luci.dispatcher.build_url("admin","system", "netwizard","settings"))
end
