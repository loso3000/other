'use strict';
'require view';
'require fs';
'require ui';
'require uci';
'require rpc';
'require form';
'require poll';

return view.extend({
	callHostHints: rpc.declare({
		object: 'luci-rpc',
		method: 'getHostHints',
		expect: { '': {} }
	}),

	load: function () {
		return Promise.all([
			this.callHostHints(),
			fs.read('/proc/net/arp')
		]);
	},


	render: function (data) {
		var  m, s, o;
		m = new form.Map('watchdog', _(''))
		m.description = _("If you are not familiar with the meanings of these options, please do not modify them.<br/><br/>")

		s = m.section(form.NamedSection, 'config', 'watchdog', _(''));
		s.anonymous = true
		s.addremove = false

		o = s.option(form.Flag, "passive_mode", _("Disable active detection"))
		o.default = 0
		o.rmempty = true
		o.description = _("Disable active detection of client online status. Enabling this feature will no longer prompt device online/offline events.<br/>Suitable for users who are not sensitive to online devices but need other features.")

		o = s.option(form.Value, "thread_num", _('Maximum concurrent processes'))
		o.placeholder = "3"
		o.datatype = "uinteger"
		o.rmempty = false;
		o.description = _("Do not change the setting value for low-performance devices, or reduce the parameters as appropriate.")


		o = s.option(form.Value, 'up_timeout', _('Device online detection timeout (s)'));
		o.placeholder = "2"
		o.optional = false
		o.datatype = "uinteger"
		o.rmempty = false;
		o.depends('passive_mode', '0');

		o = s.option(form.Value, "down_timeout", _('Device offline detection timeout (s)'))
		o.placeholder = "10"
		o.optional = false
		o.datatype = "uinteger"
		o.rmempty = false;
		o.depends('passive_mode', '0');

		o = s.option(form.Value, "timeout_retry_count", _('Offline detection count'))
		o.placeholder = "2"
		o.optional = false
		o.datatype = "uinteger"
		o.rmempty = false;
		o.description = _("If the device has good signal strength and no Wi-Fi sleep issues, you can reduce the above values.<br/>Due to the mysterious nature of Wi-Fi sleep during the night, if you encounter frequent disconnections, please adjust the parameters accordingly.<br/>..╮(╯_╰）╭..")
		o.depends('passive_mode', '0');



		return m.render();
	}
});
