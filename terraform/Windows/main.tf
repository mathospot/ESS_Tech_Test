provider "google" {
  project = "ess-tech-test-project"
  region  = "europe-central2"
  credentials = file("../credentials/ess-tech-test-project.json") 
}

resource "google_compute_instance" "vm_instance" {
  name         = "ess-apache-ubuntu01"
  machine_type = "e2-medium"
  zone         = "europe-central2-c"

  # Network Interface
  network_interface {
    network       = "default"
    access_config {
      network_tier = "PREMIUM"
    }
  }

  # Disk Configuration
  boot_disk {
    initialize_params {
      image = "projects/ess-tech-test-project/global/images/ess-ubuntu-2204-20240922"
      size  = 20
      type  = "pd-balanced"
    }
    auto_delete = true
  }

  # Shielded VM configuration
  shielded_instance_config {
    enable_secure_boot          = false
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Maintenance Policy
  scheduling {
    on_host_maintenance = "MIGRATE"
    provisioning_model  = "STANDARD"
  }
}