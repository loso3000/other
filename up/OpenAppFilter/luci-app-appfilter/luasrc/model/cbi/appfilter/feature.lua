local fs  = require "nixio.fs"
local ds = require "luci.dispatcher"
local ipc = require "luci.ip"
local utl = require "luci.util"
local dsp = require "luci.dispatcher"
local uci = require "luci.model.uci"
local lng = require "luci.i18n"
local jsc = require "luci.jsonc"
local uci = require "luci.model.uci".cursor()
local SYS = require "luci.sys"
local m,s,n,o

m = Map("appfilter", translate(""))

local rule_count = 0
local version = ""
local format = ""
if fs.access("/tmp/feature.cfg") then
    rule_count = tonumber(SYS.exec("cat /tmp/feature.cfg | grep -v '#'|awk NF|wc -l"))
    version = SYS.exec("cat /tmp/feature.cfg | grep '#version' | awk '{print $2}'")
end
format=SYS.exec("uci get appfilter.feature.format")
if format == "" then
    format="v2.0"
end

local display_str = "<strong>"..translate("Current version")..":  </strong>" .. version .. 
                    "<br><strong>"..translate("Feature format")..":</strong>  " ..format ..
                    "<br><strong>"..translate("App number")..":</strong>  " ..rule_count
local display_str2 = "<font color=\'green\'>此处可以自行添加、修改特征库。如更新失败，可至<a href=\'http://www.openappfilter.com/download.html\' target=\'_blank\'>官方特征库</a> 复制到此使用。官方特征库会被升级覆盖，如要修改请按示例添加至用户特征库。</font>"
s = m:section(TypedSection, "global",  "", display_str)
s.addremove = false
s.anonymous = true

o = s:option(DynamicList, "update_url", translate('更新特征库地址'))

o:value("http://www.openappfilter.com/assets/feature/feature2.0_cn_23.07.29.cfg", translate("openappfilter2.0_cn-v230729"))
o:value("http://www.openappfilter.com/assets/feature/feature2.0_cn_22.12.01.cfg", translate("openappfilter2.0_cn-v221201"))
o:value("http://www.openappfilter.com/assets/feature/feature2.0_en_22.12.01.cfg", translate("openappfilter2.0_en-v221201"))
o:value("https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/destan19/OpenAppFilter/master/open-app-filter/files/feature_cn.cfg", translate("github-feature_cn"))
o:value("https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/destan19/OpenAppFilter/master/open-app-filter/files/feature_en.cfg", translate("github-feature_en"))
o:value("http://www.openappfilter.com/assets/feature/feature2.0_en_22.12.01.cfg", translate("openappfilter_cn-v221201"))
o.default = "http://www.openappfilter.com/assets/feature/feature2.0_cn_23.07.29.cfg"

o = s:option(Button, "Update", translate("手动更新官方特征库"))
o.inputstyle = "apply"
o.write = function()

	SYS.call("sh /usr/bin/appfilterupdate > /dev/null 2>&1 &")
	uci:commit("appfilter")
        luci.http.redirect(luci.dispatcher.build_url("admin", "control", "appfilter" ,"feature"))
	
end




o=s:option( Flag, "autoupdate", translate("自动更新"))
o.addremove = false
o.anonymous = true

o = s:option(ListValue, 'update_time', translate('每天更新时间'))
for t = 0, 23 do
    o:value(t, t .. ':08')
end
o.default = 1
o.rmempty = true
o:depends('autoupdate', '1')


s = m:section(TypedSection, "feature",  "", display_str2)
s.anonymous = true

s:tab("config1", translate("<font style='color:black'>官方特征库</font>"))
conf = s:taboption("config1", Value, "editconf1", nil, translate(""))
conf.template = "cbi/tvalue"
conf.rows = 30
conf.wrap = "off"
--conf.readonly="readonly"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/appfilter/feature_cn.cfg") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/tfeature.cfg", value)
        if (SYS.call("cmp -s /tmp/tfeature.cfg /etc/appfilter/feature_cn.cfg") == 1) then
            fs.writefile("/etc/appfilter/feature_cn.cfg", value)
	     SYS.exec("chmod 666  /etc/appfilter/feature_cn.cfg 2>/dev/null")
	     SYS.exec("rm -rf /tmp/appfilter 2>/dev/null")
	     SYS.call("/etc/init.d/appfilter restart >/dev/null")
        end
        fs.remove("/tmp/tfeature.cfg")
    end
end


s:tab("config2", translate("用户特征库"))
conf = s:taboption("config2", Value, "editconf2", nil, translate(""))
conf.template = "cbi/tvalue"
conf.rows = 32
conf.wrap = "off"
function conf.cfgvalue(self, section)
    return fs.readfile("/etc/appfilter/feature.user.cfg") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        fs.writefile("/tmp/feature.user.cfg", value)
        if (SYS.call("cmp -s /tmp/feature.user.cfg /etc/appfilter/feature.user.cfg") == 1) then
            fs.writefile("/etc/appfilter/feature.user.cfg", value)
	     SYS.exec("chmod 666  /etc/appfilter/feature.user.cfg 2>/dev/null")
	     SYS.exec("rm -rf /tmp/appfilter 2>/dev/null")
	     SYS.call("/etc/init.d/appfilter restart >/dev/null")
        end
        fs.remove("/tmp/feature.user.cfg")
    end
end

return m
