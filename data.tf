data "template_file" "demo_gcp_yml" {
  template = file("./templates/demo.gcp.yml")
  vars = {
    gcp-project = var.gcpProjectId
  }
}

data "template_file" "ssh_cfg" {
  template = file("./templates/ssh.cfg")
  depends_on = [
    data.google_compute_instance.jumphost,
    data.google_compute_instance_group.jumphosts
  ]
  vars = {
    jumphost-name = data.google_compute_instance.jumphost.name,
    jumphost-ip = data.google_compute_instance.jumphost.network_interface[0].access_config[0].nat_ip
  }
}

data "google_compute_instance_group" "jumphosts" {
  name = "${var.projectPrefix}-jumphost-instance-group-manager"
}

data "google_compute_instance" "jumphost" {
  self_link = tolist(data.google_compute_instance_group.jumphosts.instances)[0]
}

#data "template_file" "ssh_cfg" {
#  template = file("../templates/ssh.cfg")
#  depends_on = [
#    azurerm_linux_virtual_machine.jumphost,
#    azurerm_public_ip.jumphost
#  ]
#  vars = {
#    jumphosts = jsonencode(azurerm_public_ip.jumphost)
#  }
#}

#data "template_file" "dns_hosts" {
#  for_each = var.azure_locations
#  template = file("../templates/unified-demo.hosts")
#  depends_on = [
#    azurerm_linux_virtual_machine_scale_set.k8s_controller_nodes
#  ]
#  vars = {
#    controllers = jsonencode(azurerm_linux_virtual_machine_scale_set.k8s_controller_nodes)
#    location = each.value
#    root_domain = var.root_domain
#  }
#}
