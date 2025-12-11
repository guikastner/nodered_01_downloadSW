resource "docker_network" "mongo_node_red" {
  name = var.mongo_network_name
}

resource "null_resource" "attach_mongo_to_network" {
  depends_on = [docker_network.mongo_node_red]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command     = <<-EOT
      set -eo pipefail

      network="${docker_network.mongo_node_red.name}"
      container="${var.existing_mongo_container}"

      if ! docker inspect "$${container}" >/dev/null 2>&1; then
        echo "Container '$${container}' não encontrado; ajuste 'existing_mongo_container' ou crie o container antes de aplicar."
        exit 1
      fi

      container_id="$(docker inspect -f '{{.Id}}' "$${container}")"

      if docker network inspect "$${network}" --format '{{json .Containers}}' | grep -q "$${container_id}"; then
        echo "Container '$${container}' já está conectado à rede '$${network}'."
        exit 0
      fi

      docker network connect --alias "$${container}" "$${network}" "$${container}"
    EOT
  }
}

resource "null_resource" "mongo_database_setup" {
  depends_on = [null_resource.attach_mongo_to_network]

  triggers = {
    mongo_container      = var.existing_mongo_container
    mongo_user           = var.mongo_username
    mongo_password       = var.mongo_password
    mongo_database       = var.mongo_database
    mongo_auth_user      = var.mongo_auth_username
    mongo_auth_db        = var.mongo_auth_db
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-lc"]
    command     = <<-EOT
      set -eo pipefail

      container="${var.existing_mongo_container}"
      db="${var.mongo_database}"
      user="${var.mongo_username}"
      pwd="${var.mongo_password}"
      auth_user="${var.mongo_auth_username}"
      auth_pwd="${var.mongo_auth_password}"
      auth_db="${var.mongo_auth_db}"

      if ! docker inspect "$${container}" >/dev/null 2>&1; then
        echo "Container '$${container}' não encontrado; ajuste 'existing_mongo_container' ou crie o container antes de aplicar."
        exit 1
      fi

      auth_args=""
      if [ -n "$${auth_user}" ]; then
        auth_args=" --username \"$${auth_user}\" --password \"$${auth_pwd}\" --authenticationDatabase \"$${auth_db}\""
      fi

      docker exec "$${container}" sh -c "cat <<'JS' | mongosh --quiet$${auth_args}
const dbName = '$${db}';
const user = '$${user}';
const pwd = '$${pwd}';
const db = db.getSiblingDB(dbName);
const existing = db.getUser(user);
if (existing) {
  db.updateUser(user, {pwd});
  print('User updated on ' + dbName);
} else {
  db.createUser({user, pwd, roles: [{role: 'readWrite', db: dbName}]});
  print('User created on ' + dbName);
}
// Garantir que a base apareça (Mongo só mostra bases com dados)
const markerColl = '__init__';
db.createCollection(markerColl, {capped: false});
db[markerColl].updateOne({_id: 'init'}, {$set: {createdAt: new Date()}}, {upsert: true});
JS
      "
    EOT
  }
}
