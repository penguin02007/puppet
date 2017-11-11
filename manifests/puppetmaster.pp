node /puppetmaster.*/ {

  # Disable IPv6 due to causing problem with PUPPETDB not starting on IPv4
  sysctl { 'net.ipv6.conf.all.disable_ipv6': value => '1' }
  sysctl { 'net.ipv6.conf.default.disable_ipv6': value => '1' }
  sysctl { 'net.ipv6.conf.lo.disable_ipv6': value => '1' }

  # PuppetServer and PuppetDB
  class { 'puppetserver::repository': } ->
  class { 'puppetserver': } ->
  class { 'puppetdb':
    disable_ssl => false,
  }
  class { 'puppetdb::master::config':
    puppetdb_disable_ssl  => false,
  }

  # Additional Packages for Puppet Module Testing/Development Provided by the OS
  package {[
    'puppet-lint',
    'ruby-bundler',
    'vim-puppet',
  ]:
    ensure => latest,
  }

  file {'/root/bin':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0770',
  } ->
  file {'/root/bin/stop_puppet_services.sh':
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0770',
    content => "# This Script is Managed by in the
#Puppet Node Definition for ${fqdn}
#!/bin/bash
puppet resource service puppet ensure=stopped
puppet resource service puppetdb ensure=stopped
puppet resource service postgresql ensure=stopped
puppet resource service mcollective ensure=stopped
",
  } ->
  file {'/root/bin/start_puppet_services.sh':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0770',
    content => "# This Script is Managed by in the
#Puppet Node Definition for ${::fqdn}
#!/bin/bash
puppet resource service puppet ensure=running
puppet resource service puppetdb ensure=running
puppet resource service postgresql ensure=running
puppet resource service mcollective ensure=running
",
  }

  file {'/etc/hosts':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "127.0.0.1 ${::fqdn} ${::hostname} puppet localhost

# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
",
    notify => Package['puppetserver'],
  }

  vcsrepo {"/usr/local/src/puppet-module-skeleton":
    source => 'https://github.com/garethr/puppet-module-skeleton',
    provider => git,
    ensure   => 'latest',
  }

  # Apache Server Installation
  class { 'apache': }
  class { 'apache::mod::wsgi': }

  # PuppetBoard Web UI
  class { 'puppetboard':
    manage_git        => true,
    manage_virtualenv => true,
    enable_catalog    => true,
    enable_query      => true,
    reports_count     => '50',
  }
  # Apache Vhost for PuppetBoard Web UI
  class { 'puppetboard::apache::vhost':
    vhost_name => $::fqdn,
    port       => 80,
  }

}

