module("luci.controller.qbittorrent", package.seeall)

function index()
	if not nixio.fs.access("/etc/config/qbittorrent") then
		return
	end

  entry({"admin","nas","qBittorrent"},cbi("qbittorrent"),_("qBittorrent")).acl_depends = { "luci-app-qbittorrent" }
	entry({"admin", "nas", "qbittorrent_status"}, call("qbittorrent_status"))
end

function qbittorrent_status()
	local sys  = require "luci.sys"
	local uci  = require "luci.model.uci".cursor()
	local port = tonumber(uci:get_first("qbittorrent", "qbittorrent", "port"))

	local status = {
		running = (sys.call("pgrep qbittorrent-nox >/dev/null") == 0),
		port = (port or 8080)
	}

	luci.http.prepare_content("application/json")
	luci.http.write_json(status)
end
