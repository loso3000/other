local ds = require "luci.dispatcher"
local nxo = require "nixio"
local nfs = require "nixio.fs"
local ipc = require "luci.ip"
local sys = require "luci.sys"
local utl = require "luci.util"
local dsp = require "luci.dispatcher"
local uci = require "luci.model.uci"
local lng = require "luci.i18n"
local jsc = require "luci.jsonc"
local http = luci.http
local SYS = require "luci.sys"
local m,s,n,o

local function llog(message)
    local log_file = "/tmp/log/oaf_luci.log"  
    local fd = io.open(log_file, "a")  
    if fd then
        local timestamp = os.date("%Y-%m-%d %H:%M:%S")  
        fd:write(string.format("[%s] %s\n", timestamp, message))  
        fd:close() 
    end
end
m = Map("appfilter", translate(""))

local rule_count = 0
local version = ""
local format = ""
if nixio.fs.access("/tmp/feature.cfg") then
    rule_count = tonumber(SYS.exec("cat /tmp/feature.cfg | grep -v ^$ |grep -v ^# | wc -l"))
    version = SYS.exec("cat /tmp/feature.cfg |grep '#version' | awk '{print $2}'")
end

if nixio.fs.access("/etc/appfilter/feature_cnnew.cfg") then
   SYS.exec("mv -f /etc/appfilter/feature_cnnew.cfg /etc/appfilter/feature_cn.cfg")
   SYS.call("/etc/init.d/appfilter restart >/dev/null")
   --luci.http.redirect(luci.dispatcher.build_url("admin", "services", "appfilter" ,"feature"))
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

fu = s:taboption("configs", FileUpload, "")
fu.template = "cbi/oaf_upload"
s.anonymous = true

um = s:taboption("configs", DummyValue, "rule_data")
um.template = "cbi/oaf_dvalue"

local dir, fd
dir = "/tmp/upload/"
nixio.fs.mkdir(dir)
http.setfilehandler(function(meta, chunk, eof)
    local feature_file = "/etc/appfilter/feature_cn.cfg"
    local f_format="v3.0"
    if not fd then
        if not meta then
            return
        end
        if meta and chunk then
            fd = nixio.open(dir .. meta.file, "w")
        end
        if not fd then
            return
        end
    end
    
    if chunk and fd then
        fd:write(chunk)
    end
    if eof and fd then
        fd:close()
        -- Extract the tar.gz file
        local tar_cmd = "tar -zxvf /tmp/upload/" .. meta.file .. " -C /tmp/upload/ >/dev/null"

        --llog("Starting file upload handler2" .. tar_cmd)
        local success = os.execute(tar_cmd)
        if success ~= 0 then
            um.value = translate("Failed to update feature file, format error")
            return
        else
            um.value = translate("Update the feature file successfully, please refresh the page")
        end

        local feature_dir="/tmp/upload/feature"
        local fd2 = io.open("/tmp/upload/feature.cfg")
        if not fd2 then
            um.value = translate("Failed to extract feature file, file not found")
            os.execute("rm /tmp/upload/* -fr")
            return
        end

        local version_line = fd2:read("*l")
        local format_line = fd2:read("*l")
        fd2:close()
        local ret = string.match(version_line, "#version")
        if ret ~= nil then
            if string.match(format_line, "#format") then
                f_format = SYS.exec("echo '"..format_line.."'|awk '{print $2}'")
            end
            if not string.match(f_format, format) then
                um.value = translate("Failed to update feature file, format error"..",feature format:"..f_format)
                os.execute("rm /tmp/upload/* -fr")
                return
            end
            local cmd = "cat /tmp/upload/feature.cfg>/etc/appfilter/feature_cnnew.cfg "  
            os.execute(cmd ) 
            SYS.exec("rm /www/luci-static/resources/app_icons/* -fr");
            cmd = "cp /tmp/upload/app_icons/* /www/luci-static/resources/app_icons/ -fr >/dev/null"
            os.execute(cmd )
	    SYS.exec("chmod 666 /etc/appfilter/feature*.cfg ")
            SYS.exec("killall -SIGUSR1 oafd")

            um.value = translate("Update the feature file successfully, please refresh the page")
        else
            um.value = translate("Failed to update feature file, format error")
        end
        os.execute("rm /tmp/upload/* -fr")
    end

end)

if luci.http.formvalue("upload") then
    local f = luci.http.formvalue("ulfile")
    if #f <= 0 then
        -- um.value = translate("No specify upload file.")
    end
elseif luci.http.formvalue("download") then
    Download()
end

o = s:taboption("configs", Value, "update_url", translate('更新特征库地址'))
o:value("https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/destan19/OpenAppFilter/master/open-app-filter/files/feature_cn.cfg", translate("destan19_cn_v22.3.24"))
o:value("https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/destan19/OpenAppFilter/master/open-app-filter/files/feature_en.cfg", translate("destan19_en_v22.11.11"))
o:value("https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/jjm2473/OpenAppFilter/master/open-app-filter/files/feature_cn.cfg", translate("jjm2473_cn_v23.07.29"))
o:value("https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/jjm2473/OpenAppFilter/dev4/open-app-filter/files/feature_en.cfg", translate("jjm2473_en_v22.12.01"))
o:value("https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/sirpdboy/other/master/patch/oaf/feature_cn.cfg", translate("sirpdboy_cn_v24.06.26"))
o.default = "https://gh.404delivr.workers.dev/https://raw.githubusercontent.com/sirpdboy/other/master/patch/oaf/feature_cn.cfg"

o = s:taboption("configs", Button, "Update", translate("手动更新链接特征库"))
o.inputstyle = "apply"
o.write = function()

	SYS.call("sh /usr/bin/appfilterupdate > /dev/null 2>&1 &")
	uci:commit("appfilter")
        --luci.http.redirect(luci.dispatcher.build_url("admin", "services", "appfilter" ,"feature"))
	
end

o = s:taboption("configs", ListValue, "filter_space", translate("Filter Space"))
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
    return nfs.readfile("/etc/appfilter/feature_cn.cfg") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        nfs.writefile("/tmp/tfeature.cfg", value)
        if (SYS.call("cmp -s /tmp/tfeature.cfg /etc/appfilter/feature_cn.cfg") == 1) then
            nfs.writefile("/etc/appfilter/feature_cn.cfg", value)
	     SYS.exec("chmod 666  /etc/appfilter/feature_cn.cfg 2>/dev/null")
	     SYS.exec("rm -rf /tmp/appfilter 2>/dev/null")
        end
        nfs.remove("/tmp/tfeature.cfg")
    end
end

conf = s:taboption("config1", Value, "editconf2","", translate("用户特征库"))
conf.template = "cbi/tvalue"
conf.rows = 32
conf.wrap = "off"
function conf.cfgvalue(self, section)
    return nfs.readfile("/etc/appfilter/feature.user.cfg") or ""
end
function conf.write(self, section, value)
    if value then
        value = value:gsub("\r\n?", "\n")
        nfs.writefile("/tmp/feature.user.cfg", value)
        if (SYS.call("cmp -s /tmp/feature.user.cfg /etc/appfilter/feature.user.cfg") == 1) then
	    
            nfs.writefile("/etc/appfilter/feature.user.cfg", value)
	     SYS.exec("chmod 666  /etc/appfilter/feature.user.cfg 2>/dev/null")
	     SYS.exec("rm -rf /tmp/appfilter 2>/dev/null")
	     SYS.call("/etc/init.d/appfilter restart >/dev/null")
        end
        nfs.remove("/tmp/feature.user.cfg")
    end
end

m.apply_on_parse = true
m.on_after_apply = function(self,map)
        luci.sys.exec("killall -SIGUSR1 oafd")
	luci.sys.exec("/etc/init.d/appfilter start 2>/dev/null  && sleep 5")
end


return m
