#! /bin/bash
#
#  bootstrap install Puppetserver, PuppetDB and PuppetBoard
#
#  Resources:
#  https://github.com/ppouliot/puppet-puppet_infrastructure
#  https://puppet.com/docs/puppet/5.3/install_linux.html
#
curl https://apt.puppetlabs.com/puppet5-release-xenial.deb -o /tmp/puppet5-release-xenial.deb
apt-get install /tmp/puppet5-release-xenial.deb
apt-get update && apt-get install aptitude -y
apt-cache show puppet-agent|grep -i 'puppet\s5' >>/dev/null && apt-get install ruby puppet-agent -y
gem install r10k hiera-eyaml
cd /etc/puppetlabs/code && wget https://raw.githubusercontent.com/penguin02007/puppet-puppet_infrastructure/master/Puppetfile
/usr/local/bin/r10k puppetfile install --verbose DEBUG2
r10k puppetfile install -v debug2 Puppetfile
