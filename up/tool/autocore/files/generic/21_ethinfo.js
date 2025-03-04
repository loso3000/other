'use strict';
'require baseclass';
'require rpc';

var callLuciETHList = rpc.declare({
	object: 'luci',
	method: 'getETHList',
	expect: { '': {} }
});

return L.Class.extend({
	title: _('Ethernet Information'),

	load: function() {
		return Promise.all([
			L.resolveDefault(callLuciETHList(), {})
		]);
	},

	render: function(data) {
		var ethlist = Array.isArray(data[0].ethlist) ? data[0].ethlist : [];
		var table = E('table', { 'class': 'table' }, [
			E('tr', { 'class': 'tr table-titles' }, [
				E('th', { 'class': 'th' }, _('Ethernet Name')),
				E('th', { 'class': 'th' }, _('Link Status')),
				E('th', { 'class': 'th' }, _('Speed')),
				E('th', { 'class': 'th' }, _('Duplex')),
				E('th', { 'class': 'th' }, _('MAC Address'))
			])
		]);

		cbi_update_table(table, ethlist.map(function(info) {
			var exp1;
			var exp2;

			if (info.status == "yes")
				exp1 = _('Link Up');
			else if (info.status == "no")
				exp1 = _('Link Down');

			if (info.duplex == "Full")
				exp2 = _('Full Duplex');
			else if (info.duplex == "Half")
				exp2 = _('Half Duplex');
			else
				exp2 = _('-');

			if (info.name == "lan[eth0]"  &&  info.duplex == "Half")
			       info.speed='10 G/s';
			return [
				info.name,
				exp1,
				info.speed,
				exp2,
				info.mac
			];
		}));

		return E([
			table
		]);
	}
});
