
local ipc = require "luci.ip"
local sys = require "luci.sys"

-- Copyright 2022-2023 sirpdboy <herboy2008@gmail.com>
local a, t, e

a = Map("eqosplus", translate("Network speed limit"))
a.description = translate("Users can limit the network speed for uploading/downloading through MAC, IP, and IP ranges.The speed unit is MB/second < Press - Customize - (at the bottom of the MAC list) to enter the IP or IP range (range connected with -)")
a.template = "eqosplus/index"

t = a:section(TypedSection, "eqosplus")
t.anonymous = true

e = t:option(DummyValue, "eqosplus_status", translate("Status"))
e.template = "eqosplus/eqosplus"
e.value = translate("Collecting data...")

dl = t:option(Value, "download", translate("Download bandwidth(Mbit/s)"))
dl.default = '1000'

ul = t:option(Value, "upload", translate("Upload bandwidth(Mbit/s)"))
ul.default = '30'

t = a:section(TypedSection, "device")
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true
t.sortable  = true

e = t:option(Flag, "enable", translate("Enabled"))
e.rmempty = false
e.size = 4

e = t:option(Value, "mac", translate("Speed Limiting Machines"))
sys.net.mac_hints(function(mac, name)
	e:value(mac, "%s (%s)" %{ mac, name })
end)
e.size = 8
dl = t:option(Value, "download", translate("Downloads"))
dl.default = '0.1'
dl.size = 4

ul = t:option(Value, "upload", translate("Uploads"))
ul.default = '0.1'
ul.size = 4
function validate_time(self, value, section)
        local hh, mm, ss
        hh, mm, ss = string.match (value, "^(%d?%d):(%d%d)$")
        hh = tonumber (hh)
        mm = tonumber (mm)
        if hh and mm and hh <= 23 and mm <= 59 then
            return value
        else
            return nil, "Time HH:MM or space"
        end
end

e = t:option(Value, "timestart", translate("Start control time"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true
e.size = 4
e = t:option(Value, "timeend", translate("Stop control time"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true
e.size = 4
week=t:option(Value,"week",translate("Week Day(1~7)"))
week.rmempty = true
week:value('*',translate("Everyday"))
week:value(7,translate("Sunday"))
week:value(1,translate("Monday"))
week:value(2,translate("Tuesday"))
week:value(3,translate("Wednesday"))
week:value(4,translate("Thursday"))
week:value(5,translate("Friday"))
week:value(6,translate("Saturday"))
week.default='*'
week.size = 6
comment = t:option(Value, "comment", translate("Comment"))
comment.size = 8

a.apply_on_parse = true
a.on_after_apply = function(self,map)
	luci.sys.exec("/etc/init.d/eqosplus start >/dev/null 2>&1")
end

return a
