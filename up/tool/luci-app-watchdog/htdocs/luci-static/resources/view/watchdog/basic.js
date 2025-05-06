'use strict';
'require view';
'require fs';
'require ui';
'require uci';
'require rpc';
'require form';
'require poll';
'require tools.widgets as widgets';
'require tools.firewall as fwtool';

function checkProcess() {
    return fs.exec('/bin/pidof', ['watchdog']).then(function(res) {
        return {
            running: res.code === 0,
            pid: res.code === 0 ? res.stdout.trim() : null
        };
    }).catch(function() {
        return { running: false, pid: null };
    });
}

function renderStatus(isRunning) {
    var statusText = isRunning ? _('RUNNING') : _('NOT RUNNING');
    var color = isRunning ? 'green' : 'red';
    var icon = isRunning ? '✓' : '✗'; 
    
    return String.format(
        '<em><span style="color:%s">%s <strong>%s %s</strong></span></em>',
        color, icon, _('watchdog'), statusText
    );
}
var cbiRichListValue = form.ListValue.extend({
	renderWidget: function (section_id, option_index, cfgvalue) {
		var choices = this.transformChoices();
		var widget = new ui.Dropdown((cfgvalue != null) ? cfgvalue : this.default, choices, {
			id: this.cbid(section_id),
			sort: this.keylist,
			optional: true,
			select_placeholder: this.select_placeholder || this.placeholder,
			custom_placeholder: this.custom_placeholder || this.placeholder,
			validate: L.bind(this.validate, this, section_id),
			disabled: (this.readonly != null) ? this.readonly : this.map.readonly
		});

		return widget.render();
	},

	value: function (value, title, description) {
		if (description) {
			form.ListValue.prototype.value.call(this, value, E([], [
				E('span', { 'class': 'hide-open' }, [title]),
				E('div', { 'class': 'hide-close', 'style': 'min-width:25vw' }, [
					E('strong', [title]),
					E('br'),
					E('span', { 'style': 'white-space:normal' }, description)
				])
			]));
		}
		else {
			form.ListValue.prototype.value.call(this, value, title);
		}
	}
});

return view.extend({
	callHostHints: rpc.declare({
		object: 'luci-rpc',
		method: 'getHostHints',
		expect: { '': {} }
	}),

	load: function () {
		return Promise.all([
			this.callHostHints()
		]);
	},

	render: function (data) {
		if (fwtool.checkLegacySNAT())
			return fwtool.renderMigration();
		else
			return this.renderForwards(data);
	},


    renderForwards: function(data) {
        var hosts = data[0], m, s, o;

        m = new form.Map('watchdog', _('watchdog'),);

        s = m.section(form.TypedSection);
        s.anonymous = true;
        s.render = function() {
            var statusView = E('p', { id: 'control_status' }, 
                '<span class="spinning">⏳</span> ' + _('Checking status...'));
            
            poll.add(function() {
                return checkProcess()
                    .then(function(res) {
                        var status = renderStatus(res.running);
                        if (res.running && res.pid) {
                            status += ' <small>(PID: ' + res.pid + ')</small>';
                        }
                        statusView.innerHTML = status;
                    })
                    .catch(function(err) {
                        statusView.innerHTML = '<span style="color:orange">⚠ ' + 
                            _('Status check failed') + '</span>';
                        console.error('Status check error:', err);
                    });
            });

            poll.start();
            return E('div', { class: 'cbi-section', id: 'status_bar' }, statusView);
        }

		s = m.section(form.NamedSection, 'config', 'watchdog', _(''));
		s.tab('basic', _('Basic Settings'));
		s.tab('blacklist', _('Black list'));
		s.tab('whitelist', _('White list'));
		s.addremove = false;
		s.anonymous = true;

		// 基本设置
		o = s.taboption('basic', form.Flag, 'enable', _('Enabled'));
		o = s.taboption('basic', form.Value, 'sleeptime', _('Check Interval (s)'));
		o.rmempty = false;
		o.placeholder = '60';
		o.datatype = 'and(uinteger,min(10))';
		o.description = _('Shorter intervals provide quicker response but consume more system resources.');

		o = s.taboption('basic', form.MultiValue, 'Login_control', _('Login control'));
		o.value('web_logged', _('Web Login'));
		o.value('ssh_logged', _('SSH Login'));
		o.value('web_login_failed', _('Frequent Web Login Errors'));
		o.value('ssh_login_failed', _('Frequent SSH Login Errors'));
		o.modalonly = true;

		o = s.taboption('basic', form.Value, 'login_max_num', _('Login failure count'));
		o.default = '3';
		o.rmempty = false;
		o.datatype = 'and(uinteger,min(1))';
		o.depends({ Login_control: "web_login_failed", '!contains': true });
		o.depends({ Login_control: "ssh_login_failed", '!contains': true });
		o.description = _('Reminder and optional automatic IP ban after exceeding the number of times');

		o = s.taboption('blacklist', form.Flag, 'login_web_black', _('Auto-ban unauthorized login devices'));
		o.default = '0';
		o.depends({ Login_control: "web_login_failed", '!contains': true });
		o.depends({ Login_control: "ssh_login_failed", '!contains': true });

		o = s.taboption('blacklist', form.Value, 'login_ip_black_timeout', _('Blacklisting time (s)'));
		o.default = '86400';
		o.rmempty = false;
		o.datatype = 'and(uinteger,min(0))';
		o.depends('login_web_black', '1');
		o.description = _('\"0\" in ipset means permanent blacklist, use with caution. If misconfigured, change the device IP and clear rules in LUCI.');

		o = s.taboption('blacklist', form.Flag, 'port_knocking_enable', _('Port knocking'));
		o.default = '0';
		o.description = _('If you have disabled LAN port inbound and forwarding in Firewall - Zone Settings, it won\'t work.');
		o.depends({ Login_control: "web_login_failed", '!contains': true });
		o.depends({ Login_control: "ssh_login_failed", '!contains': true });

		o = s.taboption('blacklist', form.Value, 'login_port_white', _('Port'));
		o.default = '';
		o.description = _('Open port after successful login<br/>example：\"22\"、\"21:25\"、\"21:25,135:139\"');
		o.depends('port_knocking_enable', '1');

		o = s.taboption('blacklist', form.DynamicList, 'login_port_forward_list', _('Port Forwards'));
		o.default = '';
		o.description = _('Example: Forward port 13389 of this device (IPv4:10.0.0.1 / IPv6:fe80::10:0:0:2) to port 3389 of (IPv4:10.0.0.2 / IPv6:fe80::10:0:0:8)<br/>\"10.0.0.1,13389,10.0.0.2,3389\"<br/>\"fe80::10:0:0:1,13389,fe80::10:0:0:2,3389\"');
		o.depends('port_knocking_enable', '1');

		o = s.taboption('blacklist', form.Value, 'login_ip_white_timeout', _('Release time (s)'));
		o.default = '86400';
		o.datatype = 'and(uinteger,min(0))';
		o.description = _('\"0\" in ipset means permanent release, use with caution');
		o.depends('port_knocking_enable', '1');

		o = s.taboption('blacklist', form.TextValue, 'ip_black_list', _('IP blacklist'));
		o.rows = 8;
		o.wrap = 'soft';
		o.cfgvalue = function (section_id) {
			return fs.trimmed('/usr/share/watchdog/api/ip_blacklist');
		};
		o.write = function (section_id, formvalue) {
			return this.cfgvalue(section_id).then(function (value) {
				if (value == formvalue) {
					return
				}
				return fs.write('/usr/share/watchdog/api/ip_blacklist', formvalue.trim().replace(/\r\n/g, '\n') + '\n');
			});
		};
		o.depends('login_web_black', '1');
		o.description = _('You can add or delete here, the numbers after represent the remaining time. When adding, only the IP needs to be entered.<br/>Due to limitations on the web interface, please keep one empty line if you need to clear the content; otherwise, it will not be possible to submit. ╮(╯_╰)╭<br/>Please use the 「Save」 button in the text box.');


		o = s.taboption('whitelist', cbiRichListValue, 'mac_filtering_mode_1', _('MAC Filtering Mode'));
		o.value('', _('Close'),
			_(' '));
		o.value('allow', _('Ignore devices in the list'),
			_('Ignored devices will not logged'));
		o.value('block', _('Notify only devices in the list'),
			_('Ignored devices will not logged'));
		o.value('interface', _('Notify only devices using this interface'),
			_('Multiple choice is not currently supported'));

		o = fwtool.addMACOption(s, 'whitelist', 'up_down_push_whitelist', _('Ignored device list'),
			_('Please select device MAC'), hosts);
		o.datatype = 'list(neg(macaddr))';
		o.depends('mac_filtering_mode_1', 'allow');

		o = fwtool.addMACOption(s, 'whitelist', 'up_down_push_blacklist', _('Followed device list'),
			_('Please select device MAC'), hosts);
		o.datatype = 'list(neg(macaddr))';
		o.depends('mac_filtering_mode_1', 'block');

		o = s.taboption('whitelist', widgets.DeviceSelect, 'up_down_push_interface', _("Device"));
		o.description = _('Notify only devices using this interface');
		o.modalonly = true;
		o.multiple = false;
		o.depends('mac_filtering_mode_1', 'interface');

		o = fwtool.addIPOption(s, 'whitelist', 'login_ip_white_list', _('Login (Auto-Ban) Whitelist'), null, 'ipv4', hosts, true);
		o.datatype = 'ipaddr';
		o.depends({ Login_control: "web_logged", '!contains': true });
		o.depends({ Login_control: "ssh_logged", '!contains': true });
		o.depends({ Login_control: "web_login_failed", '!contains': true });
		o.depends({ Login_control: "ssh_login_failed", '!contains': true });
		o.description = _('Add the IP addresses in the list to the whitelist for the blocking function (if available), Only record in the log. Mask notation is currently not supported.');


		return m.render();
	}
});
