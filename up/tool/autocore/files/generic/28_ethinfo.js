'use strict';
'require baseclass';
'require rpc';
'require ui';

var callLuciETHList = rpc.declare({
	object: 'luci',
	method: 'getETHList',
	expect: { '': {} }
});

return baseclass.extend({
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

        ethlist.forEach(function(info) {
            var exp1 = _('-');
            var exp2 = _('-'); 

            if (info.status === "yes") {
                exp1 = _('Link Up');
            } else if (info.status === "no") {
                exp1 = _('Link Down');
            }

            if (info.duplex === "Full") {
                exp2 = _('Full Duplex');
            } else if (info.duplex === "Half") {
                exp2 = _('Half Duplex');
            }

            var speed = info.speed;
            if (info.name === "LAN[eth0]" && info.duplex === "Half") {
                speed = '10 G/s';
            }

            var row = E('tr', { 'class': 'tr' }, [
                E('td', { 'class': 'td' }, info.name),
                E('td', { 'class': 'td' }, exp1),
                E('td', { 'class': 'td' }, speed),
                E('td', { 'class': 'td' }, exp2),
                E('td', { 'class': 'td' }, info.mac)
            ]);
            table.appendChild(row);
        });

        return E([
            table
        ]);
	}
});
