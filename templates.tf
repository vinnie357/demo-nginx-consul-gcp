resource "null_resource" "demo_gcp_yml" {
  triggers = {
    template_rendered = data.template_file.demo_gcp_yml.rendered
  }
  provisioner "local-exec" {
    command = "echo \"${data.template_file.demo_gcp_yml.rendered}\" > ./configs/ansible/demo.gcp.yml"
  }
}

resource "null_resource" "ssh_cfg" {
  triggers = {
    template_rendered = data.template_file.ssh_cfg.rendered
  }
  provisioner "local-exec" {
    command = "echo \"${data.template_file.ssh_cfg.rendered}\" > ./configs/ssh/ssh.cfg"
  }
}
