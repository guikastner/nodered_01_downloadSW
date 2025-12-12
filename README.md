# Node-RED OpenTofu stack

Infrastructure-as-code to build a custom Node-RED Docker image and run it via OpenTofu/Terraform.

## What it does
- Builds a custom Node-RED image (`opentofu/Dockerfile`) from a base image you choose.
- Installs extra Node-RED packages (axios, MySQL, MongoDB, PostgreSQL, FlowFuse dashboard, 3dxinterfaces).
- Creates `/data` subfolders (PDF, Solidworks, CATIAV5, Excel) with open permissions and sets ownership to `node-red`.
- Runs a container with bind mount to `/data/appdata/<your-folder>` and maps Node-RED port 1880 to a host port.
- Creates/reuses a Docker network shared with an existing MongoDB container, then ensures a Mongo database and single app user/password exist.

## Files
- `opentofu/main.tf`: Terraform and Docker provider setup.
- `opentofu/variables.tf`: Input variables for container name, ports, paths, base image, custom image name.
- `opentofu/node_red.tf`: Resources for data dir creation, image build, and container.
- `opentofu/mongo.tf`: Shared network + MongoDB user/database setup against an existing Mongo container.
- `opentofu/Dockerfile`: Custom Node-RED image build (includes extra npm packages and data dir setup).
- `opentofu/terraform.tfvars.example`: Sample variable values to copy and customize.
- `.gitignore`: Ignores `opentofu/terraform.tfvars`.

## Variables (see `opentofu/variables.tf`)
| Name               | Type   | Default                        | Description                                                               |
| ------------------ | ------ | ------------------------------ | ------------------------------------------------------------------------- |
| container_name     | string | `node-red`                     | Docker container name.                                                    |
| host_port          | number | `1880`                         | Host port mapped to container port 1880.                                  |
| data_dir_base      | string | `/DATA/AppData`                | Base path on host for data bind mount (must be writable).                 |
| data_dir_name      | string | `node-red`                     | Folder name appended to the base path for persistent data.                |
| node_red_image     | string | `nodered/node-red:4.1.2-22`    | Base Node-RED image tag from Docker Hub.                                  |
| custom_image_name  | string | `node-red-custom:latest`       | Name/tag for the locally built image.                                     |
| mongo_network_name | string | `mongo-node-red`               | Docker network shared between MongoDB and Node-RED.                       |
| existing_mongo_container | string | `mongodb`                | Name of the already-running MongoDB container to attach.                  |
| mongo_username     | string | `node_red_user`                | App user created in MongoDB.                                              |
| mongo_password     | string | `change-me`                    | Password for the app user.                                                |
| mongo_database     | string | `node_red_db`                  | Database name for the app user.                                           |
| mongo_auth_username| string | `""`                           | User with permission to create DB/user (leave empty if auth is disabled). |
| mongo_auth_password| string | `""`                           | Password for creation user (leave empty if auth is disabled).             |
| mongo_auth_db      | string | `admin`                        | Auth DB used when running mongosh.                                        |
| remove_volumes_on_destroy | bool | `false`                   | Keep bind/volumes when destroying the container.                          |
| plat_username      | string | (none)                         | Username for the 3DEXPERIENCE credentials injected during image build.    |
| plat_passport      | string | (none)                         | Password for the 3DEXPERIENCE credentials injected during image build.    |

## How to use
1) Copy example vars and edit as needed:
```sh
cd opentofu
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your values
```
2) Format and initialize:
```sh
tofu fmt
tofu init
```
3) Review plan and apply:
```sh
# already inside opentofu:
tofu plan
tofu apply
# or from the repo root:
# tofu -chdir=opentofu plan
# tofu -chdir=opentofu apply
```

## Destroy
- Normal destroy from `opentofu`: `tofu destroy`.
- Because Mongo is external, if the network is still connected to the Mongo container when removing only the network (common if the state no longer has the attach null_resource), disconnect first: `docker network disconnect -f mongo-node-red mongodb`, then run `tofu destroy`.

## Mongo setup notes
- `existing_mongo_container` must point to a running Mongo container (default `mongodb`).
- The plan attaches that container to the shared network (`mongo_network_name`) if not already attached.
- A single user/database pair is created/updated using `mongo_username`, `mongo_password`, `mongo_database` via `mongosh` inside the Mongo container. If your Mongo requires authentication, fill `mongo_auth_username`, `mongo_auth_password`, `mongo_auth_db` (e.g., admin).

## Notes
- To preload flows, uncomment COPY lines in `opentofu/Dockerfile` and provide `flows.json` / `flows_cred.json`.
- Ensure the base data path you set is writable on the host (default `/DATA/AppData`, change if needed).
- Node-RED image tags: https://hub.docker.com/r/nodered/node-red/tags
