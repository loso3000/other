f = SimpleForm("logview")
f.reset = false
f.submit = false

o = f:field(Button, "_apply")
o.inputtitle = translate("删除日志")
o.inputstyle = "remove"
function o.write()
	luci.sys.exec("cat /dev/null >/tmp/log/cowbping.log &")
end

t = f:field(TextValue, "conf")
t.rmempty = true
t.rows = 25
function t.cfgvalue()
	local logs = luci.util.execi("cat /tmp/log/cowbping.log 2>/dev/null")
	local s = ""
	for line in logs do
		s = line .. "\n" .. s
	end
	return s
end
t.readonly="readonly"

return f
