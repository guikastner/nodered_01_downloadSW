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

variable "mongo_network_name" {
  description = "Nome da rede Docker compartilhada entre o MongoDB existente e o Node-RED"
  type        = string
  default     = "mongo-node-red"
}

variable "existing_mongo_container" {
  description = "Nome do container MongoDB já existente que deve ser conectado à rede"
  type        = string
  default     = "mongodb"
}

variable "mongo_username" {
  description = "Usuário da aplicação no MongoDB"
  type        = string
  default     = "node_red_user"
}

variable "mongo_password" {
  description = "Senha do usuário da aplicação no MongoDB"
  type        = string
  sensitive   = true
  default     = "change-me"
}

variable "mongo_database" {
  description = "Nome do database usado pela aplicação no MongoDB"
  type        = string
  default     = "node_red_db"
}

variable "mongo_auth_username" {
  description = "Usuário com permissão para criar base/usuário (deixe vazio se o Mongo não exige autenticação)"
  type        = string
  default     = ""
}

variable "mongo_auth_password" {
  description = "Senha do usuário de criação (deixe vazio se o Mongo não exige autenticação)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "mongo_auth_db" {
  description = "Database usado para autenticação (ex.: admin)"
  type        = string
  default     = "admin"
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

variable "remove_volumes_on_destroy" {
  description = "Se true, remove os volumes/binds ao destruir o container; mantenha false para preservar dados"
  type        = bool
  default     = false
}

variable "plat_username" {
  description = "Username da plataforma 3DEXPERIENCE para uso dentro do container"
  type        = string
}

variable "plat_passport" {
  description = "Senha/passport da plataforma 3DEXPERIENCE"
  type        = string
  sensitive   = true
}
