terraform {
  required_version = ">= 0.12"
  backend "remote"{ 
  }
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.9.0"
    }
  }
}

    
provider "google" {
  project     = var.gcp_project
  region      = var.gcp_region
  zone        = var.gcp_zone
}

data "google_client_config" "current" {}

## ----- Network capabilities ------
# VPC creation
resource "google_compute_network" "network" {
  name = "${var.cluster}-network"
}


# Subnet creation
resource "google_compute_subnetwork" "subnet" {
  name          = "test-subnetwork"

  ip_cidr_range = "10.2.0.0/16"
  region        = var.gcp_region
  network       = google_compute_network.network.id
}

# External IP addresses
resource "google_compute_address" "ip-address" {
    count = var.nodes
    name = "ip-address-${count.index}"
    # subnetwork = google_compute_subnetwork.subnet.id
    region = var.gcp_region
}

# Create firewall rules
resource "google_compute_firewall" "default" {
    name = "vault-rules"
    network = google_compute_network.network.name

    allow {
        protocol = "tcp"
        ports = ["80","443","8200"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["${var.owner}"]
}


## ------ COmpute instances ---------
# Define image to use for VMs
data "google_compute_image" "my_image" {
    family = "debian-9"
    project = "debian-cloud"
}

# Create an instance template to use for similar VMs
resource "google_compute_instance_template" "instance-template" {
    name_prefix = "instance-template-"
    machine_type = var.machine

    //boot disk
    disk {
        source_image = data.google_compute_image.my_image.self_link
    }

    network_interface {
        network = google_compute_network.network.self_link
        access_config {

        }
    }
}

# resource "google_compute_instance_from_template" "tpl-vm" {
#   count = var.nodes
#   name = "vm-server-${count.index}"
#   zone = var.gcp_zone

#   source_instance_template = google_compute_instance_template.instance-template.id

#   // Override fields from instance template
#     network_interface {
#         access_config {
#             nat_ip = google_compute_address.ip-address[count.index].address
#         }
#     }

#   labels = {
#     node = "my_node_-${count.index}"
#   }
# }

resource "google_compute_instance" "vm" {
  count = var.nodes
  name         = "vm-server-${count.index}"
  machine_type = var.machine
  zone         = var.gcp_zone

  tags = ["foo", "bar"]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.my_image.self_link
      size = 50
      type = "pd-ssd"
    }
  }

#   // Local SSD disk
#   scratch_disk {
#     interface = "SCSI"
#   }

  network_interface {
    network = google_compute_network.network.self_link
    access_config {
      nat_ip = google_compute_address.ip-address[count.index].address
    }
  }

  metadata = {
    foo = "bar"
  }

  metadata_startup_script = "echo hi > /test.txt"

  labels = {
    node = "my_node_-${count.index}"
  }
}


