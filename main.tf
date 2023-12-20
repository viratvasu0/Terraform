resource "google_compute_router" "router" {
  name    = var.router_name
  region  = var.region
  project = var.project
  network = var.network_name
  bgp {
    asn               = var.router_asn
    keepalive_interval = var.router_keepalive_interval
    advertise_mode    = local.router_mode
    advertised_groups = local.router_advertise_group
    dynamic "advertised_ip_ranges" {
      for_each=var.advertise_mode_enable ? var.range : []
      content{
          range = advertised_ip_ranges.value.range
          description=advertised_ip_ranges.value.description
      }
      
    }
   
  }
}

# resource to create IAM member to create Cloud Router
resource "google_project_iam_member" "router_iam" {
  count = length(var.members)
  project = var.project
  role    = "roles/compute.networkAdmin"
  member  = var.members[count.index]
}