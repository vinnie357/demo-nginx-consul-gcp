#!/bin/bash
#
# crontab for COBTAP
#
. /opt/nginx-sniprobe/sniprobe.sh

for i in {1..3}
do
sniProbe {{ item.spec.tls[0].hosts[0] }} 35.227.6.168 35.233.248.130
if [ $i -lt 3 ]
then
sleep 20
fi
done
