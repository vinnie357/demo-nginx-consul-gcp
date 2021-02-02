#!/bin/bash
#
# cobtap -- SNI health check with DNS update (ACTIVE--PASSIVE)
#
DNS_SERVER=72.183.103.39
KEY="hmac-sha512:my-tsig:DPZY68NzmaiWMVJjyEfzlwuFBMsL84n0Sp2TVsSD8kfKS++OPmcDaDhpIAC/+CP042jrLc6Tz0dAGbvm/IskNQ=="

function sniProbe() {
FQDN=$1
IP=$2
COB=$3

# change these variable to match your BIND server
#

if curl -sf --resolve $FQDN:443:$IP -o /dev/null https://$FQDN/
then
#
# app is responding, but DNS record needs to be added
# and failback from COB
#
  if [ ! -e /tmp/$FQDN$IP ]
  then
    echo adding DNS A record $IP to $FQDN
    /snap/bin/gcloud dns record-sets transaction start --transaction-file=/tmp/$FQDN.yaml --zone=poc-nginx-rocks
    /snap/bin/gcloud dns record-sets transaction remove --transaction-file=/tmp/$FQDN.yaml "$COB" --name="$FQDN" --ttl=10  --type=A --zone=poc-nginx-rocks
    /snap/bin/gcloud dns record-sets transaction add  --transaction-file=/tmp/$FQDN.yaml "$IP" --name="$FQDN" --ttl=10  --type=A --zone=poc-nginx-rocks
    /snap/bin/gcloud dns record-sets transaction execute --transaction-file=/tmp/$FQDN.yaml --zone=poc-nginx-rocks
    touch /tmp/$FQDN$IP
  fi
else
#
# app is *NOT* responding so DNS record needs to be deleted
# and failover to COB
#
  if [ -e /tmp/$FQDN$IP ]
  then
    echo deleting DNS A record $IP to $FQDN
    /snap/bin/gcloud dns record-sets transaction start --transaction-file=/tmp/$FQDN.yaml --zone=poc-nginx-rocks
    /snap/bin/gcloud dns record-sets transaction remove --transaction-file=/tmp/$FQDN.yaml "$IP" --name="$FQDN" --ttl=10  --type=A --zone=poc-nginx-rocks
    /snap/bin/gcloud dns record-sets transaction add  --transaction-file=/tmp/$FQDN.yaml "$COB" --name="$FQDN" --ttl=10  --type=A --zone=poc-nginx-rocks
    /snap/bin/gcloud dns record-sets transaction execute --transaction-file=/tmp/$FQDN.yaml --zone=poc-nginx-rocks
    rm /tmp/$FQDN$IP
  fi
fi
}

function deleteDNS () {
  FQDN=$1
  IP=$2
  COB=$3
  echo deleting DNS A record $IP to $FQDN
  /snap/bin/gcloud dns record-sets transaction start --transaction-file=/tmp/$FQDN.yaml --zone=poc-nginx-rocks
  /snap/bin/gcloud dns record-sets transaction remove --transaction-file=/tmp/$FQDN.yaml "$IP" --name="$FQDN" --ttl=10  --type=A --zone=poc-nginx-rocks
  /snap/bin/gcloud dns record-sets transaction execute --transaction-file=/tmp/$FQDN.yaml --zone=poc-nginx-rocks
  rm /tmp/$FQDN$IP
}
