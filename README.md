# Node-RED OpenTofu stack

Infrastructure-as-code to build a custom Node-RED Docker image and run it via OpenTofu/Terraform.

## What it does
- Builds a custom Node-RED image (`opentofu/Dockerfile`) from a base image you choose.
- Installs extra Node-RED packages (axios, MySQL, MongoDB, PostgreSQL, FlowFuse dashboard, 3dxinterfaces).
- Creates `/data` subfolders (PDF, Solidworks, CATIAV5, Excel) with open permissions and sets ownership to `node-red`.
- Runs a container with bind mount to `/data/appdata/<your-folder>` and maps Node-RED port 1880 to a host port.

## Files
- `opentofu/main.tf`: Terraform and Docker provider setup.
- `opentofu/variables.tf`: Input variables for container name, ports, paths, base image, custom image name, and credentials.
- `opentofu/node_red.tf`: Resources for data dir creation, image build, container, and password hashing.
- `opentofu/Dockerfile`: Custom Node-RED image build (includes extra npm packages and data dir setup).
- `opentofu/terraform.tfvars.example`: Sample variable values to copy and customize.
- `opentofu/settings.js`: Settings used as the base inside the image; admin/viewer password hashes are injected at build time.
- `.gitignore`: Ignores `opentofu/terraform.tfvars`.

## Variables (see `opentofu/variables.tf`)
| Name              | Type   | Default                     | Description                                                               |
| ----------------- | ------ | --------------------------- | ------------------------------------------------------------------------- |
| container_name    | string | `node-red`                  | Docker container name.                                                    |
| host_port         | number | `1880`                      | Host port mapped to container port 1880.                                  |
| data_dir_base     | string | `/DATA/AppData`             | Base path on host for data bind mount (must be writable).                 |
| data_dir_name     | string | `node-red`                  | Folder name appended to the base path for persistent data.                |
| node_red_image    | string | `nodered/node-red:4.1.2-22` | Base Node-RED image tag from Docker Hub.                                  |
| custom_image_name | string | `node-red-custom:latest`    | Name/tag for the locally built image.                                     |
| admin_password    | string | (none)                      | Plaintext admin password; hashed with `bcrypt()` during `tofu apply`.     |
| viewer_password   | string | (none)                      | Plaintext viewer password; hashed with `bcrypt()` during `tofu apply`.    |

## How to use
1) Copy example vars and edit as needed:
```sh
cd opentofu
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your values
# set admin_password and viewer_password (plaintext; hashes are generated automatically)
```
2) Format and initialize:
```sh
tofu fmt
tofu init
```
3) Review plan and apply:
```sh
tofu plan
tofu apply
```

## Notes
- To preload flows, uncomment COPY lines in `opentofu/Dockerfile` and provide `flows.json` / `flows_cred.json`.
- Passwords in `terraform.tfvars` are hashed by OpenTofu using `bcrypt()` and injected into `settings.js` at image build time; the container never sees plaintext passwords.
- Ensure the base data path you set is writable on the host (default `/DATA/AppData`, change if needed).
- Node-RED image tags: https://hub.docker.com/r/nodered/node-red/tags
