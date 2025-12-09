locals {
  data_dir_base_expanded = pathexpand(var.data_dir_base)
  host_data_path         = "${local.data_dir_base_expanded}/${var.data_dir_name}"
}

# Garante que o diretório exista antes de criar o container
resource "null_resource" "ensure_data_dir" {
  provisioner "local-exec" {
    command = "mkdir -p ${local.host_data_path}"
  }
}

resource "docker_image" "node_red" {
  name         = var.custom_image_name
  keep_locally = true

  build {
    context    = path.module
    dockerfile = "${path.module}/Dockerfile"
    build_args = {
      NODE_RED_BASE_IMAGE  = var.node_red_image
      ADMIN_PASSWORD_HASH  = bcrypt(var.admin_password)
      VIEWER_PASSWORD_HASH = bcrypt(var.viewer_password)
    }
  }
}

resource "docker_container" "node_red" {
  name    = var.container_name
  image   = docker_image.node_red.image_id
  restart = "unless-stopped"

  depends_on = [null_resource.ensure_data_dir]

  ports {
    internal = 1880
    external = var.host_port
  }

  mounts {
    target = "/data"
    source = local.host_data_path
    type   = "bind"
  }
}
