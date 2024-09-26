# Install required plugins
packer {
  required_plugins {
    googlecompute = {
      source  = "github.com/hashicorp/googlecompute"
      version = "~> 1"
    }
    puppet = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/puppet"
    }
  }
}

# GCP Ubuntu builder
source "googlecompute" "gce" {
  project_id          = "ess-tech-test-project"
  source_image_family = "ubuntu-2204-lts"
  image_name          = "ess-ubuntu-2204-20240922"
  machine_type        = "n1-standard-2"
  zone                = "europe-central2-b"
  ssh_username        = "ubuntu"
  image_family        = "ubuntu-images"
  image_description   = "ESS Ubuntu 2204 LTS"
  credentials_file        = "../credentials/ess-tech-test-project.json"
}

# Build block for provisioning
build {
  sources = ["source.googlecompute.gce"]

  # Update repositories and install puppet
  provisioner "shell" {
    inline = [
      "wget https://apt.puppetlabs.com/puppet8-release-jammy.deb",
      "sudo dpkg -i puppet8-release-jammy.deb",
      "sudo apt-get clean",
      "sudo apt-get update",
      "sudo apt-get -y --fix-broken install",
      "sudo apt-get install -y puppet-agent",

      # Configure Puppet agent to point to Puppet master
      "sudo sh -c 'echo [main] >> /etc/puppetlabs/puppet/puppet.conf'",
      "sudo sh -c 'echo server=puppet.example.com >> /etc/puppetlabs/puppet/puppet.conf'",

      # Enable and start Puppet service
      "sudo systemctl enable puppet",
      "sudo systemctl start puppet",

      # Run Puppet agent for the first time and wait for the master to sign the certificate
      "sudo /opt/puppetlabs/bin/puppet agent --test --waitforcert 60"
    ]
  }
}
