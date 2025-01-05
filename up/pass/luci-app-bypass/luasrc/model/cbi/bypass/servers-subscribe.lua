local m,s,o
local bypass="bypass"
local uci=luci.model.uci.cursor()
local server_count=0

uci:foreach(bypass,"servers",function(s)
	server_count=server_count+1
end)

m=Map(bypass,translate("Servers subscription and manage"),translate("Support SS/SSR/XRAY/TROJAN/NAIVEPROXY/SOCKS5/TUN etc."))
s=m:section(TypedSection,"server_subscribe")
s.anonymous=true

o=s:option(Flag,"auto_update",translate("Auto Update"))
o.rmempty=false
o.description=translate("Auto Update Server subscription,GFW list and CHN route")

o=s:option(ListValue,"auto_update_time",translate("Update time (every day)"))
for t=0,23 do
	o:value(t,t..":00")
end
o.default=2
o.rmempty=false

o=s:option(DynamicList,"subscribe_url",translate("Subscribe URL"))
o.rmempty=true

o=s:option(Button,"update_Sub",translate("Save Subscribe Setting"))
o.inputstyle="reload"
o.description=translate("Update subscribe url or Setting list first")
o.write=function()
	uci:commit(bypass)
	luci.http.redirect(luci.dispatcher.build_url("admin","services",bypass,"servers-subscribe"))
end

o=s:option(Button,"subscribe",translate("Update All Subscribe Servers"))
o.rawhtml=true
o.template="bypass/subscribe"

o=s:option(Button,"delete",translate("Delete All Subscribe Servers"))
o.inputstyle="reset"
o.description=string.format(translate("Server Count")..": %d",server_count)
o.write=function()
	uci:delete_all(bypass,"servers",function(s)
		if s.hashkey or s.isSubscribe then
			return true
		else
			return false
		end
	end)
	uci:commit(bypass)
	luci.http.redirect(luci.dispatcher.build_url("admin","services",bypass,"servers-subscribe"))
end

o=s:option(ListValue,"filter_mode",translate("Filter Words Mode"))
o:value("",translate("Discard Mode"))
o:value(1,translate("Keep Mode"))
o = s:option(Value, "filter_words", translate("Subscribe Filter Words"))
o.rmempty = true
o.description = translate("Filter Words splited by /")


o=s:option(Flag,"switch",translate("Subscribe Default Auto-Switch"))
o.rmempty=false
o.description=translate("Subscribe new add server default Auto-Switch on")
o.default=0

o=s:option(Flag,"insecure",translate("allowInsecure"))
o.rmempty=false
o.description=translate("If true, allowss insecure connection at TLS client, e.g., TLS server uses unverifiable certificates.")
o.default=1

o=s:option(Flag,"proxy",translate("Through proxy update"))
o.rmempty=false
o.description=translate("Through proxy update list,Not Recommended")


o = s:option(Value, "user_agent", translate("User-Agent"))
o:value("Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36", translate("Win64"))
o:value("Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",translate("Linux"))
o.default = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36"

return m
