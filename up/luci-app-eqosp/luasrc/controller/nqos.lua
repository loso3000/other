module("luci.controller.nqos", package.seeall)
-- Copyright 2022-2023 sirpdboy <herboy2008@gmail.com>
function index()
    if not nixio.fs.access("/etc/config/nqos") then return end
    entry({"admin", "control"}, firstchild(), "Control", 44).dependent = false
    entry({"admin", "control", "nqos"}, cbi("nqos"), _("Nqos"), 20).dependent =true
    entry({"admin", "control", "nqos", "status"}, call("act_status")).leaf = true
end

function act_status()
    local sys  = require "luci.sys"
    local e = {} 
     e.status = sys.call(" nft list ruleset | grep 'default' >/dev/null ") == 0  
    luci.http.prepare_content("application/json")
    luci.http.write_json(e)
end
