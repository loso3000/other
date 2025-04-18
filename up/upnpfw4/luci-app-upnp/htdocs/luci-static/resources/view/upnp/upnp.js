'use strict';
'require view';
'require dom';
'require poll';
'require uci';
'require rpc';
'require form';

var callInitAction, callUpnpGetStatus, callUpnpDeleteRule,callUciGet, handleDelRule;

callInitAction = rpc.declare({
	object: 'luci',
	method: 'setInitAction',
	params: [ 'name', 'action' ],
	expect: { result: false }
});

callUpnpGetStatus = rpc.declare({
	object: 'luci.upnp',
	method: 'get_status',
	expect: {  }
});

callUpnpDeleteRule = rpc.declare({
	object: 'luci.upnp',
	method: 'delete_rule',
	params: [ 'token' ],
	expect: { result : "OK" },
});
callUciGet = rpc.declare({
    object: 'uci',
    method: 'get',
    params: ['config', 'section', 'option']
});
var iprul;
callUciGet('network', 'lan', 'ipaddr').then(function(res) {
    iprul = `http://${res.value}/`;});
handleDelRule = function(num, ev) {
	dom.parent(ev.currentTarget, '.tr').style.opacity = 0.5;
	ev.currentTarget.classList.add('spinning');
	ev.currentTarget.disabled = true;
	ev.currentTarget.blur();
	callUpnpDeleteRule(num);
};

return view.extend({
	load: function() {
		return Promise.all([
			callUpnpGetStatus(),
			uci.load('upnpd')
		]);
	},

	poll_status: function(nodes, data) {

		var rules = Array.isArray(data[0].rules) ? data[0].rules : [];

		var rows = rules.map(function(rule) {
			return [
				rule.proto,
				rule.extport,
				rule.intaddr,
				rule.host_hint || _('Unknown'),
				rule.intport,
				rule.descr,
				E('button', {
					'class': 'btn cbi-button-remove',
					'click': L.bind(handleDelRule, this, rule.num)
				}, [ _('Delete') ])
			];
		});

		cbi_update_table(nodes.querySelector('#upnp_status_table'), rows, E('em', _('There are no active port forwards.')));

		return;
	},

	render: function(data) {

		var m, s, o;

		m = new form.Map('upnpd', [_('UPnP IGD & PCP/NAT-PMP Service')],
			_('UPnP IGD & PCP/NAT-PMP allows clients on the local network to automatically configure port forwards on the router. Also called Universal Plug and Play.'));

		s = m.section(form.GridSection, '_active_rules');

		s.render = L.bind(function(view, section_id) {
			var table = E('table', { 'class': 'table cbi-section-table', 'id': 'upnp_status_table' }, [
				E('tr', { 'class': 'tr table-titles' }, [
					E('th', { 'class': 'th' }, _('Protocol')),
					E('th', { 'class': 'th' }, _('External Port')),
					E('th', { 'class': 'th' }, _('Client Address')),
					E('th', { 'class': 'th' }, _('Host')),
					E('th', { 'class': 'th' }, _('Client Port')),
					E('th', { 'class': 'th' }, _('Description')),
					E('th', { 'class': 'th cbi-section-actions' }, '')
				])
			]);

			var rules = Array.isArray(data[0].rules) ? data[0].rules : [];

			var rows = rules.map(function(rule) {
				return [
					rule.proto,
					rule.extport,
					rule.intaddr,
					rule.host_hint || _('Unknown'),
					rule.intport,
					rule.descr,
					E('button', {
						'class': 'btn cbi-button-remove',
						'click': L.bind(handleDelRule, this, rule.num)
					}, [ _('Delete') ])
				];
			});

			cbi_update_table(table, rows, E('em', _('There are no active port forwards.')));

			return E('div', { 'class': 'cbi-section cbi-tblsection' }, [
					E('h3', _('Active Port Forwards')), table ]);
		}, o, this);

		s = m.section(form.NamedSection, 'config', 'upnpd', _('Service Settings'));
		s.addremove = false;
		s.tab('general',  _('General Settings'));
		s.tab('advanced', _('Advanced Settings'));

		o = s.taboption('general', form.Flag, 'enabled', _('Start service'));
		o.rmempty  = false;

		s.taboption('general', form.Flag, 'enable_upnp', _('Enable UPnP IGD protocol')).default = '1'
		s.taboption('general', form.Flag, 'enable_natpmp', _('Enable PCP/NAT-PMP protocol')).default = '1'

		s.taboption('general', form.Flag, 'secure_mode', _('Enable secure mode'),
			_('Allow adding port forwards only to requesting IP addresses')).default = '1'

		s.taboption('general', form.Flag, 'igdv1', _('Enable UPnP IGDv1 mode'),
			_('Advertise as UPnP IGDv1 device (no IPv6) instead of IGDv2')).default = '0'

		s.taboption('general', form.Flag, 'log_output', _('Enable additional logging'),
			_('Puts extra debugging information into the system log'))

		s.taboption('general', form.Value, 'download', _('Download speed'),
			_('Value in KByte/s, informational only')).rmempty = true

		s.taboption('general', form.Value, 'upload', _('Upload speed'),
			_('Value in KByte/s, informational only')).rmempty = true

		o = s.taboption('general', form.Value, 'port', _('Port'))
		o.datatype = 'port'
		o.default  = 5000

		s.taboption('advanced', form.Flag, 'system_uptime', _('Report system instead of service uptime')).default = '1'

		s.taboption('advanced', form.Value, 'uuid', _('Device UUID'))
		s.taboption('advanced', form.Value, 'serial_number', _('Announced serial number'))
		s.taboption('advanced', form.Value, 'model_number', _('Announced model number'))

		o = s.taboption('advanced', form.Value, 'notify_interval', _('Notify interval'))
		o.datatype    = 'uinteger'
		o.placeholder = 30

		o = s.taboption('advanced', form.Value, 'clean_ruleset_threshold', _('Clean rules threshold'))
		o.datatype    = 'uinteger'
		o.placeholder = 20

		o = s.taboption('advanced', form.Value, 'clean_ruleset_interval', _('Clean rules interval'))
		o.datatype    = 'uinteger'
		o.placeholder = 600

		o = s.taboption('advanced', form.Value, 'presentation_url', _('Presentation URL'))
		o.placeholder = iprul;
		
		o = s.taboption('advanced', form.Value, 'upnp_lease_file', _('Service lease file'))
		o.placeholder = '/var/run/miniupnpd.leases'

		s.taboption('advanced', form.Flag, 'use_stun', _('Use STUN'))

		o = s.taboption('advanced', form.Value, 'stun_host', _('STUN Host'))
		o.depends('use_stun', '1');
		o.datatype    = 'host'

		o = s.taboption('advanced', form.Value, 'stun_port', _('STUN Port'))
		o.depends('use_stun', '1');
		o.datatype    = 'port'
		o.placeholder = '0-65535'

		s.taboption('advanced', form.Flag, 'force_forwarding', _('Force Forwarding'),
			_('Force forwarding even there is no public IP (please try STUN first)'))

		s = m.section(form.GridSection, 'perm_rule', _('Service ACLs'),
			_('ACLs specify which external ports can be forwarded to which client addresses and ports, IPv6 always allowed.'))

		s.sortable  = true
		s.anonymous = true
		s.addremove = true

		s.option(form.Value, 'comment', _('Comment'))

		o = s.option(form.Value, 'ext_ports', _('External Port'))
		o.datatype    = 'portrange'
		o.placeholder = '0-65535'

		o = s.option(form.Value, 'int_addr', _('Client Address'))
		o.datatype    = 'ip4addr'
		o.placeholder = '0.0.0.0/0'

		o = s.option(form.Value, 'int_ports', _('Client Port'))
		o.datatype    = 'portrange'
		o.placeholder = '0-65535'

		o = s.option(form.ListValue, 'action', _('Action'))
		o.value('allow', _('Allow'));
		o.value('deny', _('Deny'));

		return m.render().then(L.bind(function(m, nodes) {
			poll.add(L.bind(function() {
				return Promise.all([
					callUpnpGetStatus()
				]).then(L.bind(this.poll_status, this, nodes));
			}, this), 5);
			return nodes;
		}, this, m));
	}
});
