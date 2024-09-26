# Install required plugins
packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
  }
}

# GCP Windows builder
source "googlecompute" "gce-windows" {
  project_id          = "ess-tech-test-project"
  source_image        = "projects/ess-tech-test-project/global/images/windows-2022-custom-ess"
  image_name          = "ess-windows-2022-custom"
  disk_size           = "100"
  machine_type        = "n1-standard-2"
  zone                = "europe-central2-b"
  image_description   = "ESS Windows Server 2022"
  credentials_file    = "../credentials/ess-tech-test-project.json"
  

  # Set WinRM details for communication
  communicator        = "winrm"
  winrm_username      = "packer"
  winrm_password      = "NewPassword123!"
  winrm_insecure      = true
  winrm_use_ssl       = false
  winrm_timeout       = "30m"

  # Metadata startup script for enabling WinRM and creating the packer user
    metadata = {
      windows-startup-script-ps1 = <<EOT
        # Enable WinRM
        winrm quickconfig -force
        Set-Item WSMan:\localhost\Service\Auth\Basic -Value $true
        Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value $true
        netsh advfirewall firewall add rule name="Allow WinRM" dir=in action=allow protocol=TCP localport=5985

        # Create the packer user and set password
        net user packer "NewPassword123!" /add
        net localgroup administrators packer /add
        EOT
    }
}

# Build block for provisioning
build {
  sources = ["source.googlecompute.gce-windows"]

  # Provision Puppet Agent
  provisioner "powershell" {
    inline = [
      # Download Puppet Agent installer
      "Invoke-WebRequest -Uri 'https://downloads.puppetlabs.com/windows/puppet8/puppet-agent-x64-latest.msi' -OutFile 'C:/Windows/Temp/puppet-agent.msi'",
      
      # Install Puppet Agent
      "Start-Process msiexec.exe -ArgumentList '/qn /i C:/Windows/Temp/puppet-agent.msi' -Wait",
      
      # Configure Puppet Agent
      "Set-Content -Path 'C:/ProgramData/PuppetLabs/puppet/etc/puppet.conf' -Value '[main]`nserver=puppet.example.com`nenvironment=production' -Force",
      
      # Start Puppet Agent service
      "Start-Service -Name puppet",
      
      # Run Puppet Agent and wait for cert signing
      "C:/Program Files/Puppet Labs/Puppet/bin/puppet.bat agent --test --waitforcert=60"
    ]
  }
}