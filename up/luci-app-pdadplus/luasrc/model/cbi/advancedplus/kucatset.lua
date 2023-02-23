local sys = require 'luci.sys'
local name = 'advancedplus'
local a, t, e


a = Map('advancedplus', translate('KuCat Theme Config'),  translate("<b>Set and manage theme main color scheme, activate menu and list background color, theme shortcut and other functions.</b></br>") .. 
translate("Set the preset theme color without setting the background color and transparency. The theme color is set with # plus color number, such as red: # ff0000. </br>" ) .. 
translate("The background color is set in hexadecimal, such as red: 255,0,0 The lower the transparency number, the higher the transparency. The default transparency is 0.2" ))
a.apply_on_parse=true

t=a:section(TypedSection,"basic")
t.anonymous=true

e = t:option(ListValue, 'background', translate('Wallpaper Source'))
e:value('0', translate('Built-in'))
e:value('1', translate('Bing Wallpapers'))
e.default = '0'
e.rmempty = false

e = t:option(ListValue, 'gossr', translate('Shortcut Ssrkey settings'))
e:value('shadowsocksr', translate('SSR'))
e:value('bypass', translate('bypass'))
e:value('vssr', translate('Hell World'))
e:value('passwall', translate('passwall'))
e:value('passwall2', translate('passwall2'))
e:value('clash', translate('Open Clash'))
e.default = 'bypass'
e.rmempty = false

t = a:section(TypedSection, "theme", translate("Color scheme list"))
t.template = "cbi/tblsection"
t.anonymous = true
t.addremove = true

e = t:option(ListValue, 'mode', translate('Theme mode'))
e:value('light', translate('Force Light'))
e:value('dark', translate('Force Dark'))
e.default = 'light'
e.rmempty = false

e = t:option(Value, 'primary', translate('Primary Color'))
e:value("blue",translate("RoyalBlue"))
e:value("green",translate("MediumSeaGreen"))
e:value("orange",translate("SandyBrown"))
e:value("red",translate("TomatoRed"))
e.default='green'

e = t:option(Value, 'primary_body', translate('Primary Body Color'))
e.default='#ffffff'

e = t:option(Value, 'primary_rgb', translate('Main Background color'))
e.default='74,161,133'

e = t:option(Value, 'primary_rgbs', translate('Secondary Background color'))
e.default='225,112,88'

e = t:option(Value, 'primary_rgb_ts', translate('Background transparency'))
e:value("0",translate("0"))
e:value("0.1",translate("0.1"))
e:value("0.2",translate("0.2"))
e:value("0.3",translate("0.3"))
e:value("0.4",translate("0.4"))
e:value("0.5",translate("0.5"))
e:value("0.6",translate("0.6"))
e:value("0.7",translate("0.7"))
e:value("0.8",translate("0.8"))
e:value("0.9",translate("0.9"))
e:value("1",translate("1"))
e.default='0.2'

e = t:option(Flag, "use", translate("Use"))
e.rmempty = false
e.default = '1'

e = t:option(Value, 'remarks', translate('Remarks'))

a.apply_on_parse = true
a.on_after_apply = function(self,map)
	luci.sys.exec("/etc/init.d/advancedplus start")
end

return a
