local sys = require "luci.sys"
local button = ""
local state_msg = ""
local m,t,e
local running=(luci.sys.call("[ `(tc qdisc show dev br-lan | head -1) 2>/dev/null | grep -c 'default' 2>/dev/null` -gt 0 ] > /dev/null") == 0)

if running then
	state_msg = "<b><font color=\"green\">" .. translate("Running") .. "</font></b>"
else
	state_msg = "<b><font color=\"red\">" .. translate("Not running") .. "</font></b>"
end

m = Map("netspeedlimit", translate("Network speed limit"))
m.description = translate("Users can limit the network speed for uploading/downloading through MAC, IP, IP segment, and IP range< The speed unit is MB/second< If a certain rate is filled with 0 and the rule is moved to the top, then the item is not limited in speed. If both the top and bottom are filled with 0, then the user is not limited in speed (excluding overlapping with the IP range)< Press - Customize - (at the bottom of the MAC list) to enter the IP or IP segment, IP range, or IP mask.")

t = m:section(TypedSection, "device")
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true
t.sortable  = true

e = t:option(Flag, "enable", translate("Enable"))
e.rmempty = false

usr = t:option(Value, "usr", translate("List of Speed Limiting Machines"))
sys.net.mac_hints(function(mac, name)
	usr:value(mac, "%s (%s)" %{ mac, name })
end)

dl = t:option(Value, "download", translate("Downloads"))
dl.rmempty = false
dl.default = '0.002'
dl.size = 6

ul = t:option(Value, "upload", translate("Uploads"))
ul.rmempty = false
ul.default = '0.002'
ul.size = 6
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

e = t:option(Value, "timeend", translate("Stop control time"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true

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

comment = t:option(Value, 'remarks', translate('Remarks'))
comment.size = 6

return m
