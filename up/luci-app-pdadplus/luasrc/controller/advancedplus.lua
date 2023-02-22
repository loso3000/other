module("luci.controller.advancedplus",package.seeall)
function index()
	if not nixio.fs.access("/etc/config/advancedplus") then return end
	
	if nixio.fs.access('/www/luci-static/kucat/css/style.css') then
	
	    entry({"admin","system","advancedplus"},alias("admin","system","advancedplus","kucatset"),_("Advanced plus"),60)dependent = true
	    entry({"admin","system","advancedplus","kucatset"},cbi("advancedplus/kucatset"),_("KuCat Theme Config"),10).leaf = true
	    entry({"admin", "system","advancedplus","kucatupload"}, form("advancedplus/kucatupload"), _("Theme Background upload"), 20).leaf = true
	else
	
	   entry({"admin","system","advancedplus"},alias("admin","system","advancedplus","advancededit"),_("Advanced plus"),60)dependent = true
	end
	entry({"admin","system","advancedplus","advancededit"},cbi("advancedplus/advancededit"),_("Advanced Edit"),60).leaf = true
	
end
