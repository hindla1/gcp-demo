locals {
  project_id = var.project_id
}

resource "google_project_service" "compute_service" {
  project = local.project_id
  service = "compute.googleapis.com"
}

#vpc
resource "google_compute_network" "my-vpc" {
   name = "my-vpc"
   auto_create_subnetworks = false
   delete_default_routes_on_create = true
   depends_on = [
    google_project_service.compute_service
     ]
}

#public subnet
resource "google_compute_subnetwork" "my-pub-subnet" {
  name          = "my-pub-subnet"
  ip_cidr_range = "10.0.0.0/24"
  region        = "us-central1"
  network       = google_compute_network.my-vpc.id
}



#private subnet
resource "google_compute_subnetwork" "my-private-subnet" {
  name          = "my-private-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-central1"
  network       = google_compute_network.my-vpc.id
}

#router
resource "google_compute_router" "my-router" {
    name = "my-router"
    network =  google_compute_network.my-vpc.id
}

#nat
resource "google_compute_router_nat" "my-nat" {
  name                               = "my-nat-router"
  router                             = google_compute_router.my-router.name
  region                             = google_compute_router.my-router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}

resource "google_compute_route" "private_network_internet_route" {
  name             = "private-network-internet"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.my-vpc.id
  next_hop_gateway = "default-internet-gateway"
  priority    = 100
}
