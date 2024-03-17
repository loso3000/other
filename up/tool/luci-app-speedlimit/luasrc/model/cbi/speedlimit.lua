local sys = require "luci.sys"
--Author: wulishui <wulishui@gmail.com>
local button = ""
local state_msg = ""
local m,s,n
local running=(luci.sys.call("[ `(tc qdisc show dev br-lan | head -1) 2>/dev/null | grep -c 'default' 2>/dev/null` -gt 0 ] > /dev/null") == 0)

if running then
	state_msg = "<b><font color=\"green\">" .. translate("������") .. "</font></b>"
else
	state_msg = "<b><font color=\"red\">" .. translate("δ����") .. "</font></b>"
end

m = Map("speedlimit", translate("�ٶ�����"))
m.description = translate("����ͨ��MAC��IP��IP�Σ�IP��Χ�����û��ϴ�/���ص����١�<br>�ٶȵ�λ�ǣ�<b><font color=\"green\">MB/��</font></b>�����ٶ�ֵ 0 ʱΪ�����ơ�").. button .. "<br/><br/>" .. translate("����״̬ ��") .. state_msg .. "<br />"

s = m:section(TypedSection, "usrlimit")
s.template = "cbi/tblsection"
s.anonymous = true
s.addremove = true
s.sortable  = true

e = s:option(Flag, "enable", translate("Enable"))
e.rmempty = false

usr = s:option(Value, "usr",translate("ѡ�����Ƶ��û���<font color=\"green\">MAC֧�� : �� - �ָ�</font>��"))
sys.net.mac_hints(function(mac, name)
	usr:value(mac, "%s (%s)" %{ mac, name })
end)
usr.size = 8

dl = s:option(Value, "download", translate("�����ٶ�"))
dl.rmempty = false
dl.size = 8

ul = s:option(Value, "upload", translate("�ϴ��ٶ�"))
ul.rmempty = false
ul.size = 8

comment = s:option(Value, "comment", translate("��ע"))
ul.rmempty = false
comment.size = 8

return m
