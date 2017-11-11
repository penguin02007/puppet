class postfix {

  $sasl = $operatingsystem ? {
    Ubuntu => libsasl2-modules,
    RedHat => cyrus-sasl-plain,
  }

  package { 'cyrus-sasl-plain':
    name     => $sasl,
    ensure   => 'installed',
    provider => yum,
  }

  file { '/etc/postfix/main.cf':
    ensure  => file,
    content => template('postfix/main.cf.erb'),
  }

  file { '/etc/postfix/sasl_passwd':
    ensure  => file,
    content => template('postfix/sasl_passwd.erb'),
  }

  file { '/etc/postfix/generic'
    ensure  => file,
    content => $generic,
  }

}

