# Global health check
resource "google_compute_health_check" "webservers-health-check" {
  name        = "webservers-health-check"
  description = "Health check via tcp"

  timeout_sec         = 5
  check_interval_sec  = 10
  healthy_threshold   = 3
  unhealthy_threshold = 2

  tcp_health_check {
    port_name          = "http"
  }

  depends_on = [
    google_project_service.compute_service
  ]
}


# Global backend service
resource "google_compute_backend_service" "webservers-backend-service" {

  name                            = "webservers-backend-service"
  timeout_sec                     = 30
  connection_draining_timeout_sec = 10
  load_balancing_scheme = "EXTERNAL"
  protocol = "HTTP"
  port_name = "http"
  health_checks = [google_compute_health_check.webservers-health-check.id]

  backend {
    group = google_compute_instance_group.webservers.id
    balancing_mode = "UTILIZATION"
  }
}



resource "google_compute_url_map" "my-url-map" {

  name            = "website-map"
  default_service = google_compute_backend_service.webservers-backend-service.id
}


# Global http proxy
resource "google_compute_target_http_proxy" "my-http-proxy" {

  name    = "website-proxy"
  url_map = google_compute_url_map.my-url-map.id
}

# Regional forwarding rule
resource "google_compute_forwarding_rule" "webservers-loadbalancer" {
  name                  = "website-forwarding-rule"
  ip_protocol           = "TCP"
  port_range            = 80
  load_balancing_scheme = "EXTERNAL"
  network_tier          = "STANDARD"
  target                = google_compute_target_http_proxy.my-http-proxy.id
}

resource "google_compute_firewall" "load_balancer_inbound" {
  name    = "my-demo-lb"
  network = google_compute_network.my-vpc.id

  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }

  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["nginx-instance"]
}
