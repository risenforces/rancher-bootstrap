#!/bin/bash

CURRENT_HOSTNAME=$(hostname)
read -p "Enter unique hostname [$CURRENT_HOSTNAME]: " HOSTNAME
export HOSTNAME=${HOSTNAME:-$CURRENT_HOSTNAME}

read -p "Enter load balancer hostname (domain): " LOAD_BALANCER_HOSTNAME
read -p "Enter shared token: " TOKEN

source <(wget -qO- https://raw.githubusercontent.com/risenforces/rancher-bootstrap/main/prepare.sh)

##################
## set hostname ##
##################

hostnamectl set-hostname $HOSTNAME
sed -i "s/$CURRENT_HOSTNAME/$HOSTNAME/g" /etc/hosts

################
## setup rke2 ##
################

curl -sfL https://get.rke2.io | sh -
systemctl enable rke2-server.service

# allow safe connections through load balancer
tee -a /etc/rancher/rke2/config.yaml << END
server: https://$LOAD_BALANCER_HOSTNAME:9345
token: $TOKEN
tls-san:
  - $LOAD_BALANCER_HOSTNAME
END

systemctl start rke2-server.service
