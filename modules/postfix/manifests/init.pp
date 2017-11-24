class postfix {

  package { 'postfix':
    ensure   => installed,
  }

  file { '/etc/postfix/main.cf':
    ensure  => file,
    content => template('postfix/main.cf.erb'),
  }

  service { 'postfix'
     ensure => running,
  }

}

