variable "container_name" {
  description = "Nome do container Docker para o Node-RED"
  type        = string
  default     = "node-red"
}

variable "host_port" {
  description = "Porta no host que será mapeada para o Node-RED (porta interna 1880)"
  type        = number
  default     = 1880
}

variable "data_dir_name" {
  description = "Nome final da pasta dentro de /data/appdata onde os dados do Node-RED serão armazenados"
  type        = string
  default     = "node-red"
}

variable "data_dir_base" {
  description = "Caminho base no host onde será criado o diretório de dados (precisa ser gravável)"
  type        = string
  default     = "/DATA/AppData"
}

variable "node_red_image" {
  description = "Imagem completa do Node-RED no Docker Hub (ex.: nodered/node-red:3.1.9)"
  type        = string
  default     = "nodered/node-red:4.1.2-22"
}

variable "custom_image_name" {
  description = "Nome da imagem personalizada que será construída localmente"
  type        = string
  default     = "node-red-custom:latest"
}
