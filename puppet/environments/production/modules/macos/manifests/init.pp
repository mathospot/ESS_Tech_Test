# Configure pf firewall rules
file { '/etc/pf.conf':
  ensure  => file,
  content => "
  pass out all
  pass in proto icmp
  pass in proto tcp from any to any port 53
  pass in proto udp from any to any port 53
  pass in proto tcp from any to any port 22
  pass in proto tcp from any to any port 8080
  pass in proto tcp from any to any port 8140
  block log all
  ",
  notify  => Service['pf'],
}

service { 'pf':
  ensure  => running,
  enable  => true,
  subscribe => File['/etc/pf.conf'],
}

# Apache setup on macOS
package { 'apache2':
  ensure => installed,
}

service { 'org.apache.httpd':
  ensure  => running,
  enable  => true,
  require => Package['apache2'],
}

file { '/etc/apache2/ports.conf':
  ensure  => file,
  content => "Listen 8080\n",
  require => Package['apache2'],
  notify  => Service['org.apache.httpd'],
}

file { '/etc/apache2/sites-available/000-default.conf':
  ensure  => file,
  content => "
  <VirtualHost *:8080>
      DocumentRoot /Library/WebServer/Documents
      <Directory /Library/WebServer/Documents>
          Options Indexes FollowSymLinks
          AllowOverride None
          Require all granted
      </Directory>
  </VirtualHost>
  ",
  require => Package['apache2'],
  notify  => Service['org.apache.httpd'],
}

file { '/Library/WebServer/Documents/index.html':
  ensure  => file,
  content => '<html><body><h1>Hello ESS World!</h1></body></html>',
  require => Package['apache2'],
  notify  => Service['org.apache.httpd'],
}

# New Relic installation
class { 'newrelic_installer::install':
  targets => ["infrastructure", "logs"],
  environment_variables => {
    "NEW_RELIC_API_KEY"          => $api_key,
    "NEW_RELIC_ACCOUNT_ID"       => $account_id,
    "NEW_RELIC_REGION"           => "EU",
    "NEW_RELIC_APPLICATION_NAME" => "Apache macOS"
  }
}

# Prometheus installation
package { 'prometheus':
  ensure => installed,
  provider => 'homebrew',
}

service { 'prometheus':
  ensure => running,
  enable => true,
  require => Package['prometheus'],
}

service { 'node_exporter':
  ensure => running,
  enable => true,
  require => Package['prometheus'],
}
