#!/bin/sh


cat <<-EOF >$6
{
    "tls_host":"$1",
    "out_addr":"$2",
    "tls_ip":"$3",
    "port":"$4",
    "uuid":"$5"
}
EOF