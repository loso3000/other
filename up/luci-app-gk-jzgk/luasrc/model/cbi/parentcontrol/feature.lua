local fs  = require "nixio.fs"
local sys = require "luci.sys"
local uci = require "luci.model.uci".cursor()
local m,s,n,o
m = Map("parentcontrol", translate(""), translate(""))

s = m:section(TypedSection, "basic", translate(""),translate("此处可以自行修改删除插件中配置参数和儿童网址过滤库。【修改前建议备份】"))

s.anonymous = true

s:tab("config1", translate("<font style='color:black'>配置参数</font>"))
conf = s:taboption("config1", Value, "editconf1", nil, translate(""))
conf.template = "cbi/tvalue"
conf.rows = 30
conf.wrap = "off"
--conf.readonly="readonly"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/config/parentcontrol")or""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/parentcontrol.tmp", value)
        if (sys.call("cmp -s /tmp/parentcontrol.tmp /etc/config/parentcontrol") == 1) then
            fs.writefile("/etc/config/parentcontrol", value)

	     sys.exec("rm -rf /tmp/parentcontrol.tmp 2>/dev/null")
	     sys.call("/etc/init.d/parentcontrol restart >/dev/null")
        end
        fs.remove("/tmp/parentcontrol.tmp")
    end
end



s:tab("config2",translate("儿童(黑名单)过滤库"))
conf = s:taboption("config2", Value, "editconf2", nil, translate(""))
conf.template = "cbi/tvalue"
conf.rows = 30
conf.wrap = "off"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/parentcontrol/black.list") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/black.tmp", value)
        if (sys.call("cmp -s /tmp/black.tmp /etc/parentcontrol/black.list") == 1) then
            fs.writefile("/etc/parentcontrol/black.list", value)
	     sys.exec("rm -rf /tmp/black.tmp 2>/dev/null")
	     sys.call("/etc/init.d/parentcontrol restart >/dev/null")
        end
        fs.remove("/tmp/black.tmp")
    end
end

return m


