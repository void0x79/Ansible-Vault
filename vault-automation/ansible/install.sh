#!/bin/bash

# install jq
sudo yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm && sudo yum install jq -y

# Customizing base configuration files
PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)
NODENAME=$(hostname)

if [ $1 == "vault" ]
then 
    sed -i 's/VAULT_API_ADDRESS/$PRIVATE_IP:8200/g' /tmp/vault.config
    sed -i 's/VAULT_CLUSTER_ADDRESS/$PRIVATE_IP:8201/g' /tmp/vault.config
    sed -i 's/NODENAME/$NODENAME/g' /tmp/consul_agent.json
    sed -i 's/PRIVATE_IP/$PRIVATE_IP/g' /tmp/consul.json
elif [ $1 == "consul" ]
    cat consul.json | jq '. + {"server":true}' > /tmp/consul-server.json
fi 

echo "Baking $1 into the AMI. Please wait."
echo "parameter two is $2"

# Installing Software. 
curl -O "https://artifactory.us.caas.oneadp.com/artifactory/hashicorp-vault-generic/$1/$2+ent/$1_$2+ent_linux_amd64.zip"
unzip $1_$2+ent_linux_amd64.zip
mv $1 /usr/bin
rm $1_$2+ent_linux_amd64.zip