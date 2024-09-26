class ubuntu {

    ### Firewall rules ###

    firewall { '000 allow outgoing':
    proto  => 'all',
    chain  => 'OUTPUT',
    jump   => 'accept',
    }

    # Allow established and related incoming connections
    firewall { '001 allow established/related connections':
    proto  => 'all',
    state  => ['RELATED', 'ESTABLISHED'],
    chain  => 'INPUT',
    jump   => 'accept',
    }

    # Allow ICMP
    firewall { '002 allow ICMP':
    proto  => 'icmp',
    chain  => 'INPUT',
    jump   => 'accept',
    }

    # Allow DNS
    firewall { '003 allow DNS':
    proto  => 'udp',
    dport  => 53,
    chain  => 'INPUT',
    jump   => 'accept',
    }

    firewall { '004 allow DNS TCP':
    proto  => 'tcp',
    dport  => 53,
    chain  => 'INPUT',
    jump   => 'accept',
    }

    # Allow incoming SSH on port 22
    firewall { '100 allow ssh':
    proto  => 'tcp',
    dport  => 22,
    chain  => 'INPUT',
    jump   => 'accept',
    state  => ['NEW', 'ESTABLISHED', 'RELATED'],
    }

    # Allow incoming HTTP on port 8080
    firewall { '101 allow http':
    proto  => 'tcp',
    dport  => 8080,
    chain  => 'INPUT',
    jump   => 'accept',
    }

    # Allow Puppet on port 8140
    firewall { '102 allow puppet':
    proto  => 'tcp',
    dport  => 8140,
    chain  => 'INPUT',
    jump   => 'accept',
    }

    # Log dropped packets
    firewall { '998 log dropped traffic':
    proto  => 'all',
    chain  => 'INPUT',
    jump   => 'LOG',
    log_prefix => 'Dropped by firewall: ',
    log_level  => '4',
    }

    # Drop all other incoming traffic
    firewall { '999 drop all other incoming':
    proto  => 'all',
    chain  => 'INPUT',
    jump   => 'drop',
    require => [Firewall['100 allow ssh'], Firewall['101 allow http'], Firewall['002 allow ICMP']],
    }


    ### Apache ###

    package { 'apache2':
        ensure => installed,
    }

    service { 'apache2':
        ensure  => running,
        enable  => true,
        require => Package['apache2'],
    }

    file { '/etc/apache2/ports.conf':
        ensure  => file,
        content => "Listen 8080\n",
        require => Package['apache2'],
        notify  => Service['apache2'],
    }

    file { '/etc/apache2/sites-available/000-default.conf':
        ensure  => file,
        content => "
        <VirtualHost *:8080>
            DocumentRoot /var/www/html
            <Directory /var/www/html>
                Options Indexes FollowSymLinks
                AllowOverride None
                Require all granted
            </Directory>
        </VirtualHost>
        ",
        require => Package['apache2'],
        notify  => Service['apache2'],
    }

    file { '/var/www/html/index.html':
        ensure  => file,
        content => '<html><body><h1>Hello ESS World!</h1></body></html>',
        require => Package['apache2'],
        notify  => Service['apache2'],
    }


    ### New Relic ###
    
    class { 'newrelic_installer::install':
        targets => ["infrastructure", "logs"],
        environment_variables => {
            "NEW_RELIC_API_KEY"          => $api_key,
            "NEW_RELIC_ACCOUNT_ID"       => $account_id,
            "NEW_RELIC_REGION"           => "EU",
            "NEW_RELIC_APPLICATION_NAME" => "Apache Ubuntu"
        }
    }

    ### Prometheus ###

    class { 'prometheus':
        version => '1.3.1',
    }

    service { 'node_exporter':
        ensure => running,
        enable => true,
    }

}
