locals {
  project_name         = coalesce(var.project_name, var.stack_name)
  ssh_private_key_path = pathexpand(var.ssh_private_key_path)
  extra_files = [
    for path in sort(keys(var.extra_files)) : {
      path    = path
      content = var.extra_files[path].content
      mode    = var.extra_files[path].mode
    }
  ]

  deploy_spec = {
    stack_name        = var.stack_name
    project_name      = local.project_name
    remote_dir        = var.remote_dir
    compose_yaml      = var.compose_yaml
    env_file          = coalesce(var.env_file, "")
    extra_files       = local.extra_files
    external_networks = var.external_networks
  }

  deploy_spec_b64 = base64encode(jsonencode(local.deploy_spec))

  deploy_playbook  = abspath("${path.root}/ansible/deploy-compose-stack.yml")
  destroy_playbook = abspath("${path.root}/ansible/destroy-compose-stack.yml")

  extra_files_checksum = join(",", [
    for path in sort(keys(var.extra_files)) :
    "${path}:${var.extra_files[path].mode}:${sha256(var.extra_files[path].content)}"
  ])
}

resource "terraform_data" "this" {
  input = {
    ssh_host                     = var.ssh_host
    ssh_user                     = var.ssh_user
    ssh_port                     = var.ssh_port
    ssh_private_key_path         = local.ssh_private_key_path
    ssh_strict_host_key_checking = var.ssh_strict_host_key_checking
    destroy_playbook             = local.destroy_playbook
    deploy_spec_b64              = local.deploy_spec_b64
  }

  triggers_replace = [
    var.stack_name,
    local.project_name,
    var.remote_dir,
    sha256(var.compose_yaml),
    sha256(jsonencode(var.external_networks)),
    sha256(coalesce(var.env_file, "")),
    sha256(local.extra_files_checksum),
  ]

  provisioner "local-exec" {
    command = "ansible-playbook -i '${var.ssh_host},' -u '${var.ssh_user}' --private-key '${local.ssh_private_key_path}' -e 'ansible_port=${var.ssh_port}' '${local.deploy_playbook}'"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = var.ssh_strict_host_key_checking ? "True" : "False"
      ANSIBLE_SSH_ARGS          = var.ssh_strict_host_key_checking ? "" : "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
      COMPOSE_STACK_SPEC_B64    = local.deploy_spec_b64
    }
  }

  provisioner "local-exec" {
    when    = destroy
    command = "ansible-playbook -i '${self.input.ssh_host},' -u '${self.input.ssh_user}' --private-key '${self.input.ssh_private_key_path}' -e 'ansible_port=${self.input.ssh_port}' '${self.input.destroy_playbook}'"

    environment = {
      ANSIBLE_HOST_KEY_CHECKING = self.input.ssh_strict_host_key_checking ? "True" : "False"
      ANSIBLE_SSH_ARGS          = self.input.ssh_strict_host_key_checking ? "" : "-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"
      COMPOSE_STACK_SPEC_B64    = self.input.deploy_spec_b64
    }
  }
}
