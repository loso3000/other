-- Copyright 2017 Florian Eckert <fe@dev.tdt.de>
-- Licensed to the public under the GNU General Public License v2.

local net = require "luci.model.network".init()

local s, m, o, rtmon

m = Map("mwan3", translate("MWAN - Globals"))

s = m:section(NamedSection, "globals", "globals", nil)

o = s:option(Value, "mmx_mask",
	translate("Firewall mask"),
	translate("Enter value in hex, starting with <code>0x</code>"))
o.datatype = "hex(4)"
o.default = "0x3F00"

o = s:option(Flag, "logging",
	translate("Logging"),
	translate("Enables global firewall logging"))

o = s:option(ListValue, "loglevel",
	translate("Loglevel"),
	translate("Firewall loglevel"))
o.default = "notice"
o:value("emerg", translate("Emergency"))
o:value("alert", translate("Alert"))
o:value("crit", translate("Critical"))
o:value("error", translate("Error"))
o:value("warning", translate("Warning"))
o:value("notice", translate("Notice"))
o:value("info", translate("Info"))
o:value("debug", translate("Debug"))
o:depends("logging", "1")

rtmon = s:option(
	Value,
	"rtmon_interval",
	translate("Update interval"),
	translate("How often should rtmon update the interface routing table"))
rtmon.datatype = "integer"
rtmon.default = "5"
rtmon:value("1", translatef("%d second", 1))
rtmon:value("3", translatef("%d seconds", 3))
rtmon:value("5", translatef("%d seconds", 5))
rtmon:value("7", translatef("%d seconds", 7))
rtmon:value("10", translatef("%d seconds", 10))
o = s:option(DynamicList, "rt_table_lookup",
	translate("Routing table lookup"),
	translate("Also scan this Routing table for connected networks"))
o.datatype = "integer"
o:value("220", translatef("Routing table %d", 220))

return m
