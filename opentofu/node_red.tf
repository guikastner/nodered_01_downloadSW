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
      NODE_RED_BASE_IMAGE = var.node_red_image
      THREE_DX_USERNAME   = var.plat_username
      THREE_DX_PASSPORT   = var.plat_passport
    }
  }
}

resource "docker_container" "node_red" {
  name    = var.container_name
  image   = docker_image.node_red.image_id
  restart = "unless-stopped"
  remove_volumes = var.remove_volumes_on_destroy # evita apagar o volume/bind no destroy quando false

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

  networks_advanced {
    name    = docker_network.mongo_node_red.name
    aliases = [var.container_name]
  }
}
