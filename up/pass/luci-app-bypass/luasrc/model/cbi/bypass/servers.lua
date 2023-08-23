local m,s,o
local bypass="bypass"
local uci=luci.model.uci.cursor()

m=Map(bypass)
-- s=m:section(TypedSection,"server_subscribe")

-- s.anonymous = true
-- s:append(Template("bypass/node_add"))
s=m:section(TypedSection,"servers")
s.anonymous=true
s.addremove=true
s.template="cbi/tblsection"
-- s.sortable=true
s.extedit=luci.dispatcher.build_url("admin","services",bypass,"servers","%s")
function s.create(...)
	local sid=TypedSection.create(...)
	if sid then
		uci:set(bypass,sid,'switch_enable',1)
		luci.http.redirect(s.extedit%sid)
		return
	end
end

o=s:option(DummyValue,"type",translate("Type"))
function o.cfgvalue(...)
	return (Value.cfgvalue(...)=="vless") and "VLESS" or Value.cfgvalue(...)
end

o=s:option(DummyValue,"alias",translate("Alias"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or translate("None")
end

o=s:option(DummyValue,"server_port",translate("Server Port"))
function o.cfgvalue(...)
	return Value.cfgvalue(...) or "N/A"
end

o=s:option(DummyValue,"server_port",translate("Socket Connected"))
o.template="bypass/socket"
o.width="10%"

o=s:option(DummyValue,"server",translate("TCPing Latency"))
o.template="bypass/ping"
o.width="10%"

o=s:option(Button,"apply_node",translate("Apply"))
o.inputstyle="apply"
o.write=function(self,section)
	uci:set(bypass,'@global[0]','global_server',section)
	uci:commit(bypass)
	luci.http.redirect(luci.dispatcher.build_url("admin","services",bypass,"base"))
end

o=s:option(Flag,"switch_enable",translate("Auto Switch"))
o.rmempty=false
function o.cfgvalue(...)
	return Value.cfgvalue(...) or 1
end

m:append(Template("bypass/server_list"))

return m
