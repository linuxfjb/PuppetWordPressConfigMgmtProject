#!/bin/sh
#puppetAgentInstall.sh

# 1. Installs a puppet agent on ubuntu OS. There is an optional check for K8s that is
#    lab specific to Simplilearn.
# 2. This script can be run once per server. Give the server a name and it will append the
#    /etc/hosts file and set up the node.

#NOTE: This script is not secure, don't leave this script on your server! Use at your own risk. :D
# Be aware that most of this script runs as a normal user.
# There will be instructions to switch to root when certifications are being set up using puppet
# agent command.

echo "What is the name of the agent host to be used in /etc/hosts?"
read clientHostName

echo "Do you want to set up host and $clientHostName entries in /etc/hosts?"
read yesNo

if [ $yesNo = 'y' -o $yesNo = 'Y' ]
then
  sudo hostnamectl set-hostname $clientHostName.ec2.internal
  echo "Enter ip address of server: "
  read ipAddr

  echo "setting up hosts..."
  sudo -- sh -c "echo '$(hostname -i| cut -d' ' -f1) $clientHostName.ec2.internal' >> /etc/hosts"
  sudo -- sh -c "echo '$ipAddr puppetserver.ec2.internal puppet' >> /etc/hosts"
fi

echo "Do you want to download and install puppet agent?"
read yesNo

if [ $yesNo = 'y' -o $yesNo = 'Y' ]
then
  echo "Puppet agent install..."
  curl -O https://apt.puppetlabs.com/puppet7-release-xenial.deb
  sudo  dpkg -i puppet7-release-xenial.deb
  sudo apt-get update
  sudo apt-get install puppet-agent
fi

echo "Is this K8s and need to clean up the lab?"
read yesNo

if [ $yesNo = 'y' -o $yesNo = 'Y' ]
then
  #--
  #FOR k8s issues
  #---
  sudo apt-get update --fix-missing
  sudo apt-get remove puppet-agent puppet-master puppet  puppetserver puppet-agent
  sudo apt --fix-broken install
  sudo apt clean
  sudo rm -rf /tmp/*
  sudo apt-get install puppet-agent
fi

echo "Do you want to edit the puppet.conf file?"
read yesNo

if [ $yesNo = 'y' -o $yesNo = 'Y' ]
then
  sudo -- sh -c "echo '[main]\nserver = puppetserver.ec2.internal' >> /etc/puppetlabs/puppet/puppet.conf"
fi

echo "Do you want to restart puppet agent?"
read yesNo

if [ $yesNo = 'y' -o $yesNo = 'Y' ]
then
  sudo systemctl start puppet
  sudo systemctl enable puppet
  sudo systemctl status puppet
  sudo systemctl restart puppet
fi

echo "Do you want to wipe out previous client cert and recreate? (y/n)"
read certFlg

if [ $certFlg = 'y' -o $certFlg = 'Y' ]
then
  echo "Setting up puppet agent cert...\n"

  echo "If cert exists on server, do this as root: "
  echo "puppetserver ca clean --certname client1.ec2.internal"
  echo "Hit <enter> to continue." 
  read blank
  cd /etc/puppetlabs/puppet/ssl/
  sudo rm -rf *
  sudo systemctl stop puppet
  sudo systemctl restart puppet
fi

echo "Do you want to force the agent to pull from server? (y/n) Do this as root."
read certFlg

if [ $certFlg = 'y' -o $certFlg = 'Y' ]
then
  echo "In order to force agent pull, switch to root and run this: "
  echo "sudo -i"
  echo "/opt/puppetlabs/bin/puppet agent -t"
fi

echo "\n\nGo back to the *server* and look for requested certs. If present, sign the certs as *root*:"

#echo "puppetserver ca sign --certname $clientHostName.us-west-2.compute.internal"
echo "puppetserver ca sign --certname $clientHostName.ec2.internal"

exit 0
