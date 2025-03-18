'use strict';
'require baseclass';
'require rpc';

var callOnlineUsers = rpc.declare({
    object: 'luci',
    method: 'getOnlineUsers'
});

var callOnlineUserlist = rpc.declare({
    object: 'luci',
    method: 'getOnlineUserlist',
    expect: { userlist: [] }
});


return baseclass.extend({
    title: _('Online User'),
    load: function() {
		return Promise.all([
			L.resolveDefault(callOnlineUserlist(), {}),
			L.resolveDefault(callOnlineUsers(), {})
        ]);
    },

    render: function(data) {
        var onlineuserlist = Array.isArray(data[0]) ? data[0] : [],
         fields = [_('Online Users'), data[1].onlineusers || '0'];

        var usestatus = E('table', { 'class': 'table' });
        if (fields[0] == _('Online Users')) {
            usestatus.appendChild(E('tr', { 'class': 'tr' }, [
                E('td', { 'class': 'td', 'width': '33%' }, [fields[0]]),
                E('td', { 'class': 'td left' }, [
                    (fields[1] != null) ? fields[1] : '0'
                ])
            ]));
        }

        var table = E('table', { 'class': 'table' }, [
            E('tr', { 'class': 'tr table-titles' }, [
                E('th', { 'class': 'th'}, _('Hostname')),
                E('th', { 'class': 'th'}, _('IP Address')),
                E('th', { 'class': 'th'}, _('MAC address')),
                E('th', { 'class': 'th'}, _('Interface'))
            ])
        ]);

        onlineuserlist.sort(function(a, b) {
            return L.naturalCompare(a.ipaddr, b.ipaddr);
        });

        onlineuserlist.forEach(function(info) {
            if (!info.ipaddr && !info.macaddr) {
   	        return;
            }
            var row = E('tr', { 'class': 'tr' }, [
                E('td', { 'class': 'td'}, info.hostname),
                E('td', { 'class': 'td'}, info.ipaddr),
                E('td', { 'class': 'td'}, info.macaddr),
                E('td', { 'class': 'td'}, info.device)
            ]);
            table.appendChild(row);
        });

        return E([
            table,
            usestatus
        ]);
    }
});
