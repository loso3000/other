local o = require "luci.sys"
local fs = require "nixio.fs"
local ipc = require "luci.ip"
local net = require "luci.model.network".init()
local sys = require "luci.sys"

local a, t, e
a = Map("parentcontrol", translate("Parent Control"), translate("<b><font color=\"green\">利用iptables来管控数据包过滤以禁止符合设定条件的用户连接互联网的工具软件。</font> </b></br>\
网址过滤：指定“关键词/URL”过滤,可以是字符串或网址.包括IPV4和IPV6</br>不指定MAC就是代表控制所有机器,起控时间要小于停控时间，不指定时间就是所有时段" ))


a.template = "parentcontrol/index"
t = a:section(TypedSection, "basic", translate(""))
t.anonymous = true
e = t:option(DummyValue, "parentcontrol_status", translate("当前状态"))
e.template = "parentcontrol/parentcontrol"
e.value = translate("Collecting data...")


e = t:option(Flag, "enabled", translate("开启"))
e.rmempty = false

e = t:option(ListValue, "algos", translate("过滤力度"))
e:value("bm", "一般过滤")
e:value("kmp", "强效过滤")
e.default = "kmp"

e = t:option(ListValue, "control_mode",translate("网址过滤模式"), translate("儿童模式即黑名单：全网不允访问名单内容;自定义:单机设置不允许访问"))
e.rmempty = false
e:value("black_mode", "儿童模式")
--e:value("white_mode", "白名单")
e:value("custom_mode", "自定义")
e.default = "custom_mode"

t = a:section(TypedSection, "macbind2", translate("网址过滤"))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true
e = t:option(Flag, "enable", translate("开启"))
e.rmempty = false
e.default = '1'
e = t:option(Value, "macaddr", translate("黑名单MAC<font color=\"green\">(留空则过滤全部客户端)</font>"))
e.rmempty = true
o.net.mac_hints(function(t, a) e:value(t, "%s (%s)" % {t, a}) end)
e = t:option( Value, "keyword", translate("关键词/URL<font color=\"green\">(可留空)</font>"))
e.rmempty = true
    function validate_time(self, value, section)
        local hh, mm, ss
        hh, mm, ss = string.match (value, "^(%d?%d):(%d%d)$")
        hh = tonumber (hh)
        mm = tonumber (mm)
        if hh and mm and hh <= 23 and mm <= 59 then
            return value
        else
            return nil, "时间格式必须为 HH:MM 或者留空"
        end
    end
e = t:option(Value, "timeon", translate("起控时间"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true
e = t:option(Value, "timeoff", translate("停控时间"))
e.placeholder = '00:00'
e.default = '00:00'
e.validate = validate_time
e.rmempty = true
e = t:option(MultiValue, "daysofweek", translate("星期<font color=\"green\">(至少选一天，某天不选则该天不进行控制)</font>"))
e.optional = false
e.rmempty = false
e.default = 'Monday Tuesday Wednesday Thursday Friday Saturday Sunday'
e:value("Monday", translate("一"))
e:value("Tuesday", translate("二"))
e:value("Wednesday", translate("三"))
e:value("Thursday", translate("四"))
e:value("Friday", translate("五"))
e:value("Saturday", translate("六"))
e:value("Sunday", translate("日"))
return a



