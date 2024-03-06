
local fs = require "nixio.fs"
local netdatafile = "/etc/netdata/netdata.conf" 
local util = require "luci.util"

f = SimpleForm("netdatas", translate("Netdata Config"),
	translate("Netdata is high-fidelity infrastructure monitoring and troubleshooting.Open-source, free, preconfigured, opinionated, and always real-time.") ..
	translate("<br/>Edit Netdata main config: <code>/etc/netdata/netdata.conf</code>"))

t = f:field(TextValue, "netdata")
t.rmempty = true
t.rows = 20
function t.cfgvalue()
	return fs.readfile(netdatafile) or ""
end

function f.handle(self, state, data)
	if state == FORM_VALID then
		if data.netdata then
			fs.writefile(netdatafile, util.trim(data.netdata):gsub("\r\n", "\n") .. "\n")

		else
			fs.writefile(netdatafile, "")
		end
	end
	return true
end

return f
