class windows {
  # Install IIS
  windowsfeature { 'Web-Server':
    ensure => present,
  }

  # Open firewall rule for RDP (port 3389)
  exec { 'open_rdp_port':
    command => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall add rule name="Open RDP" dir=in action=allow protocol=TCP localport=3389',
    unless  => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall show rule name="Open RDP"',
  }

  # Open firewall rule for WinRM HTTP (port 5985)
  exec { 'open_winrm_http_port':
    command => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall add rule name="Open WinRM HTTP" dir=in action=allow protocol=TCP localport=5985',
    unless  => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall show rule name="Open WinRM HTTP"',
  }

  # Open firewall rule for WinRM HTTPS (port 5986)
  exec { 'open_winrm_https_port':
    command => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall add rule name="Open WinRM HTTPS" dir=in action=allow protocol=TCP localport=5986',
    unless  => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall show rule name="Open WinRM HTTPS"',
  }

  # Open firewall rules for DNS (port 53 TCP and UDP)
  exec { 'open_dns_port_tcp':
    command => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall add rule name="Open DNS TCP" dir=in action=allow protocol=TCP localport=53',
    unless  => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall show rule name="Open DNS TCP"',
  }

  exec { 'open_dns_port_udp':
    command => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall add rule name="Open DNS UDP" dir=in action=allow protocol=UDP localport=53',
    unless  => 'C:\\Windows\\System32\\netsh.exe advfirewall firewall show rule name="Open DNS UDP"',
  }

  # Configure WinRM service
  exec { 'configure_winrm':
    command => 'C:\\Windows\\System32\\winrm.cmd quickconfig -q',
    unless  => 'C:\\Windows\\System32\\winrm.cmd e winrm/config/listener',
  }

  # Set IIS to bind to port 8080
  exec { 'set_iis_port_8080':
    command => 'C:\\Windows\\System32\\inetsrv\\appcmd.exe set site "Default Web Site" /bindings:http/*:8080:',
    unless  => 'C:\\Windows\\System32\\inetsrv\\appcmd.exe list site /name:"Default Web Site" /bindings | findstr "8080"',
    require => Windowsfeature['Web-Server'],
  }

  # Create a simple index.html for the IIS site
  file { 'C:/inetpub/wwwroot/index.html':
    ensure  => file,
    content => '<html><body><h1>Hello ESS World!</h1></body></html>',
    require => Exec['set_iis_port_8080'],
  }

  # Ensure IIS is running
  service { 'W3SVC':
    ensure => running,
    enable => true,
  }

  # Ensure firewall is running
  service { 'MpsSvc':
    ensure => running,
    enable => true,
  }


  ### Prometheus ###
  class { 'prometheus':
      version => '1.3.1',
  }
  service { 'node_exporter':
      ensure => running,
      enable => true,
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
}
