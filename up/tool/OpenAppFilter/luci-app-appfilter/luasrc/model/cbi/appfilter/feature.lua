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
    rule_count = tonumber(SYS.exec("cat /tmp/feature.cfg | grep -v ^$ |grep -v ^# | wc -l"))
    version = SYS.exec("cat /tmp/feature.cfg |grep '#version' | awk '{print $2}'")
end
format="v3.0"

local display_str = "<strong>"..translate("Current version")..":  </strong>" .. version .. 
                    "<br><strong>"..translate("Feature format")..":</strong>  " ..format ..
                    "<br><strong>"..translate("App number")..":</strong>  " ..rule_count
		    
local display_str2 = "<font color=\'green\'>此处可以自行添加、修改特征库。如更新失败，可至<a href=\'https://www.openappfilter.com/#/feature\' target=\'_blank\'>官方特征库</a> 复制到此使用。官方特征库会被升级覆盖，如要修改请按示例添加至用户特征库。</font>"

s = m:section(TypedSection, "global",  "", display_str)
s.addremove = false
s.anonymous = true

s:tab("configs", translate("设置特征库"))

o = s:taboption("configs", DynamicList, "update_url", translate('更新特征库地址'))
o:value("https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/destan19/OpenAppFilter/master/open-app-filter/files/feature_cn.cfg", translate("destan19_cn_v24.06.26"))
o:value("https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/destan19/OpenAppFilter/master/open-app-filter/files/feature_cn.cfg", translate("destan19_cn_v22.3.24"))
o:value("https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/destan19/OpenAppFilter/master/open-app-filter/files/feature_en.cfg", translate("destan19_en_v22.3.24"))
o:value("https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/jjm2473/OpenAppFilter/master/open-app-filter/files/feature_cn.cfg", translate("jjm2473_cn_v23.07.29"))
o:value("https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/jjm2473/OpenAppFilter/dev4/open-app-filter/files/feature_en.cfg", translate("jjm2473_en_v23.07.29"))
o.default = "https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/destan19/OpenAppFilter/master/open-app-filter/files/feature_cn.cfg"

o = s:taboption("configs", Button, "Update", translate("手动更新官方特征库"))
o.inputstyle = "apply"
o.write = function()

	SYS.call("sh /usr/bin/appfilterupdate > /dev/null 2>&1 &")
	uci:commit("appfilter")
        luci.http.redirect(luci.dispatcher.build_url("admin", "control", "appfilter" ,"feature"))
	
end

o = s:taboption("configs", ListValue, "filter_space", translate("Filter Space"),translate(""))
o:value(0, translate("Filter Domestic"))
o:value(1,translate("Filter Overseas"))

o = s:taboption("configs",  Flag, "autoupdate", translate("自动更新"))
o.addremove = false
o.anonymous = true

o = s:taboption("configs", ListValue, 'update_time', translate('每天更新时间'))
for t = 0, 23 do
    o:value(t, t .. ':08')
end
o.default = 1
o.rmempty = true
o:depends('autoupdate', '1')


s = m:section(TypedSection, "feature",  "", display_str2)
s.anonymous = true

s:tab("config1", translate("编辑特征库"))

conf = s:taboption("config1", Value, "editconf1","", translate("官方特征库"))
conf.template = "cbi/tvalue"
conf.rows = 30
conf.wrap = "off"
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

conf = s:taboption("config1", Value, "editconf2","", translate("用户特征库"))
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

            SYS.call("rm /www/luci-static/resources/app_icons/* -fr");
            SYS.call("cp /tmp/upload/app_icons/* /www/luci-static/resources/app_icons/ -fr >/dev/null")
            SYS.call("killall -SIGUSR1 oafd")
	    
            fs.writefile("/etc/appfilter/feature.user.cfg", value)
	     SYS.exec("chmod 666  /etc/appfilter/feature.user.cfg 2>/dev/null")
	     SYS.exec("rm -rf /tmp/appfilter 2>/dev/null")
	     SYS.call("/etc/init.d/appfilter restart >/dev/null")
        end
        fs.remove("/tmp/feature.user.cfg")
    end
end

m.apply_on_parse = true
m.on_after_apply = function(self,map)
	luci.sys.exec("/etc/init.d/appfilter start >/dev/null 2>&1")
end


return m
