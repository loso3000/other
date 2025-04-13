'use strict';
'require view';
'require rpc';
'require ui';
'require uci';

var callPowerOff = rpc.declare({
	object: 'system',
	method: 'poweroff',
	expect: { result: 0 }
});

return view.extend({
	load: function() {
		return uci.changes();
	},

	render: function(changes) {
		var body = E([
			E('h2', _('PowerOff')),
			E('p', {}, _('Turn off the power to the device you are using'))
		]);

		for (var config in (changes || {})) {
			body.appendChild(E('p', { 'class': 'alert-message warning' },
			_('WARNING: Power off might result in a reboot on a device which not support power off.')));
			break;
		}

		body.appendChild(E('hr'));
		body.appendChild(E('button', {
			'class': 'cbi-button cbi-button-action important',
			'click': function () {
				ui.showModal(_('Power Off Device'), [
					E('p', {}, _('Turn off the power to the device you are using')),
					E('p', {}, _(' ')),
					E('button', {
						'class': 'cbi-button cbi-button-action important',
						'style': 'margin: 2rem 5rem 1rem 5rem; background: red!important; border-color: red!important',
						'click': function () {
							ui.hideModal();
							this.handlePowerOff();
						}.bind(this)
					}, _('Confirm')),
					E('button', {
						'class': 'btn cbi-button cbi-button-apply',
						'style': 'margin: 0 5rem 1rem 5rem;',
						'click': function () {
							ui.hideModal();
						}
					}, _('Cancel'))
				]);
			}.bind(this)
		}, _('Perform Power Off')));

		return body;
	},

	handlePowerOff: function(ev) {
		return callPowerOff().then(function(res) {
			if (res != 0) {
				L.ui.addNotification(null, E('p', _('The PowerOff command failed with code %d').format(res)));
				L.raise('Error', 'PowerOff failed');
			}

			L.ui.showModal(_('PowerOffing...'), [
				E('p', { 'class': 'spinning' }, _('The device is shutting down...'))
			]);

			window.setTimeout(function() {
				L.ui.showModal(_('PowerOffing...'), [
					E('p', { 'class': 'spinning alert-message warning' },
						_('The device may have powered off. If not, check manually.'))
				]);
			}, 150000);

			L.ui.awaitReconnect();
		})
		.catch(function(e) { L.ui.addNotification(null, E('p', e.message)) });
	},

	handleSaveApply: null,
	handleSave: null,
	handleReset: null
});
