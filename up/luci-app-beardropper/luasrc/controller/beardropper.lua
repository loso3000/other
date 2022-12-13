module("luci.controller.beardropper", package.seeall)

function index()
    if not nixio.fs.access("/etc/config/beardropper") then
	return
    end
    entry({"admin", "control"}, firstchild(), "Control", 44).dependent = false
    entry({"admin", "control", "beardropper"}, alias("admin", "control", "beardropper", "setting"),_("BearDropper"), 20).dependent = true
    entry({"admin", "control", "beardropper", "status"}, call("act_status"))
    entry({"admin", "control", "beardropper", "setting"}, cbi("beardropper/setting"), _("Setting"), 30).leaf= true
    entry({"admin", "control", "beardropper", "log"}, form("beardropper/log"),_("Log"), 40).leaf= true
    --entry:
end

function act_status()
    local e={}
    e.running = luci.sys.call("pgrep -f /usr/sbin/beardropper >/dev/null")==0
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end