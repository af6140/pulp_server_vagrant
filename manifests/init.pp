
  $pulpserver_hostname =  $::fqdn
  $pulpserver_hostname_ud = regsubst($pulpserver_hostname, '\.', '_', 'G')

  $ssl_cert_path = "/tmp/${pulpserver_hostname_ud}.crt"
  $ssl_key_path = "/tmp/${pulpserver_hostname_ud}.key"
  yumrepo {'epel-release':
         ensure => 'present',
         baseurl => 'http://mirror.math.princeton.edu/pub/epel/$releasever/$basearch/',
         enabled => 1,
         gpgcheck => 0,
  }

  openssl::certificate::x509 { $pulpserver_hostname_ud:
  	ensure => 'present',
    commonname => $pulpserver_hostname,
  	days => 1024,
  	country => 'US',
  	state => 'MI',
  	locality => 'Detroit',
  	organization => 'Entertainment',
  	unit => 'Operation',
  	base_dir => '/tmp',
    require => Package['httpd'],
    key_owner => 'apache',
    key_group => 'apache',
  }

  $ssl_cacert_path = $ssl_cert_path

  yumrepo {'copr-qpid':
    ensure => 'present',
    descr => 'Copr QPID Repo',
    baseurl => 'https://copr-be.cloud.fedoraproject.org/results/@qpid/qpid/epel-$releasever-$basearch/',
    gpgkey => 'https://copr-be.cloud.fedoraproject.org/results/@qpid/qpid/pubkey.gpg',
    enabled =>1,
    gpgcheck =>1,
  }
  yumrepo {'pulp':
    ensure => 'present',
    descr => 'Pulp Stable Repo',
    baseurl => 'https://repos.fedorapeople.org/repos/pulp/pulp/stable/2/$releasever/$basearch/',
    enabled => 1,
    gpgcheck => 0,
  }
  package {'cyrus-sasl-plain':
   ensure => 'present',
  }


  class {'mongodb::globals':
    manage_package_repo => false,
    manage_package => false,
    client_package_name => 'mongodb',
    server_package_name => 'mongodb-server',
  }
  class{'::pulp':
    server_name => $pulpserver_hostname,
    default_login => 'admin',
    default_password => 'admin',
    ca_cert => '/etc/pki/pulp/ca.crt',
    ca_key => '/etc/pki/pulp/ca.key',
    messaging_url => 'tcp://localhost:5672',
    messaging_transport => 'qpid',
    messaging_auth_enabled => false,
    messaging_topic_exchange => 'amq.topic',
    broker_url => 'qpid://localhost:5672',
    broker_use_ssl => false,
    messaging_ca_cert => '/etc/pki/pulp/qpid/ca.crt',
    messaging_client_cert => '/etc/pki/pulp/qpid/client.crt',
    https_cert => $ssl_cert_path,
    https_key => $ssl_key_path,
    enable_http => true,
    enable_rpm => true,
    enable_puppet => true,
    enable_docker => true,
    email_host => 'smtp.entertainment.com',
    email_from => 'pulp@pulp.co.epi.web',
    email_enabled => true,
    manage_db => true,
    oauth_enabled => false,
    db_ssl => false,
    messaging_event_notification_url => 'qpid://localhost:5672',
  }

  class{'::pulp::admin':
    enable_puppet => true,
    enable_docker => true,
    verify_ssl => false,
  }

  Yumrepo['epel-release'] ->
  Yumrepo['copr-qpid'] ->
  Yumrepo['pulp'] ->
  Class['apache'] ->
  Package['qpid-tools'] ->
  Package['mongodb-server']


  Yumrepo['pulp'] -> Class['pulp::apache']
  Yumrepo['pulp'] -> Class['pulp::database']
  Yumrepo['pulp'] -> Class['pulp::broker']
  Yumrepo['pulp'] -> Class['pulp::install']
  Yumrepo['pulp'] -> Class['pulp::admin::install']


  Package['cyrus-sasl-plain'] -> Class['pulp']
  Class['mongodb::globals'] -> Class['pulp']

  Yumrepo['copr-qpid'] -> Class['qpid::install']






