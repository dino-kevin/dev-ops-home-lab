# 🛠️ Complete DevOps Homelab

A zero-cost, production-style local DevOps infrastructure built on your laptop. This project provisions virtual infrastructure, configures container engines, bootstraps a Kubernetes cluster, and manages application lifecycles using GitOps practices.

---

## 📌 Credits & References
This lab architecture is inspired by and modeled after the **[Build Your Own DevOps Lab — Zero-Cost Infrastructure Guide](https://osomudeya.gumroad.com/l/BuildYourOwnDevOpsLab)** created by [Osomudeya Zudonu](https://osomudeya.gumroad.com/). Support the author's work on [Gumroad](https://osomudeya.gumroad.com/).

---

## 🏗️ Architecture Stack
* **[Vagrant](https://vagrantup.com):** Infrastructure-as-Code for virtual machine provisioning.
* **[Ansible](https://ansible.com):** Configuration management and system baselining.
* **[Docker](https://docker.com):** Container runtime engine for local workloads.
* **[Minikube](https://k8s.io):** Local single-node Kubernetes cluster management.
* **[Kubectl](https://kubernetes.io):** Official CLI tool to control Kubernetes clusters.
* **[ArgoCD](https://github.io):** Declarative GitOps engine for automated deployments.
* **[Floci](https://floci.io/floci/):** Free, open-source local AWS emulator for development, testing, and CI.
* **[Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/):** Securely exposes local services to the public internet without opening inbound firewall ports.

---

## 💻 System Prerequisites
* **Memory:** Minimum 8GB RAM (16GB recommended).
* **Storage:** 20GB free disk space.
* **Hypervisor:** VirtualBox installed with virtualization enabled in BIOS/UEFI, running a **Debian-based** distro (Ubuntu, Debian, etc.) since the included scripts and commands target those systems.
* **Domain:** A domain managed in [Cloudflare](https://dash.cloudflare.com/) (required to publish services through Cloudflare Tunnel).

### Create a Sudo-Enabled User
See the [How To Create a New Sudo-Enabled User on Ubuntu](https://www.digitalocean.com/community/tutorials/how-to-create-a-new-sudo-enabled-user-on-ubuntu) guide for provisioning a non-root user with administrative privileges.

### Install Docker on Ubuntu
See the [How To Install and Use Docker on Ubuntu 20.04](https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-20-04) guide for setting up the Docker engine. Alternatively, the [`docker/install_docker.sh`](docker/install_docker.sh) script can be used on Debian-based systems to automate the same installation steps.

---

## 🚀 Step-by-Step Implementation

### Step 1: Harden the Host Firewall with UFW (Debian/Ubuntu)
Since all services will be exposed through Cloudflare Tunnel, disable every inbound port and only allow SSH (port `22`) on the Debian/Ubuntu host.

1. Install UFW if it is not already present:
   ```bash
   sudo apt update
   sudo apt install ufw
   ```
2. Explicitly allow SSH so the session is not locked out:
   ```bash
   sudo ufw allow 22/tcp
   ```
3. Reset UFW to a clean state and deny all incoming traffic by default:
   ```bash
   sudo ufw default deny incoming
   sudo ufw default allow outgoing
   ```
4. Enable the firewall and verify the active rules:
   ```bash
   sudo ufw enable
   sudo ufw status verbose
   ```
   Only `22/tcp` (SSH) should be listed as `ALLOW`. All other inbound ports stay closed because Cloudflare Tunnel will publish services through outbound-only connections.

### Step 2: Expose Local Services via Cloudflare Tunnel
Use the Cloudflare connector to expose the services running in this project to the public internet through secure tunnels — no inbound firewall ports required.

- Learn more about [Cloudflare Tunnels](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/) and the [Cloud Connector](https://developers.cloudflare.com/rules/cloud-connector/).

1. Install `cloudflared` on a Debian-based system by running the [`cloudflare_connector/install_cloudflare_tunnel.sh`](cloudflare_connector/install_cloudflare_tunnel.sh) script:
   ```bash
   bash cloudflare_connector/install_cloudflare_tunnel.sh
   ```
2. Install the `cloudflared` system service with your tunnel token so the tunnel starts automatically on boot:
   ```bash
   cloudflared service install <YOUR_TUNNEL_TOKEN>
   ```

### Step 3: Provision VMs via Vagrant
Define and spin up isolated virtual machines mimicking distinct environment layers. 

1. Create your project directory and site content:
   ```bash
   mkdir devops-lab-project && cd devops-lab-project
   ```
2. Write a `Vagrantfile` to declare the web and database nodes:
   ```ruby
   Vagrant.configure("2") do |config|
     config.vm.box = "ubuntu/focal64"
     config.vm.define "web" do |web|
       web.vm.network "private_network", ip: "192.168.33.10"
       web.vm.network "forwarded_port", guest: 80, host: 8080
     end
     config.vm.define "db" do |db|
       db.vm.network "private_network", ip: "192.168.33.11"
     end
   end
   ```
3. Initialize the environments:
   ```bash
   vagrant up
   ```

### Step 4: Automation with Ansible
Automate machine packages and configure target boundaries dynamically.

1. Configure an `inventory` file using native Vagrant SSH keys:
   ```ini
   [webservers]
   192.168.33.10 ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/web/virtualbox/private_key

   [dbservers]
   192.168.33.11 ansible_user=vagrant ansible_ssh_private_key_file=.vagrant/machines/db/virtualbox/private_key
   ```
2. Define `ansible.cfg` targeting local variables:
   ```ini
   [defaults]
   inventory = inventory
   host_key_checking = False
   ```

### Step 5: Run Containers with Docker
Deploy isolated target application packages over standard system boundaries.

1. Write a basic configuration file to render custom tracking assets.
2. Use Ansible configurations or manual steps inside target VMs to install and pull target assets:

### Step 6: Bootstrap Local Kubernetes with Minikube
Spin up your container orchestration plane engine locally.

1. Initialize Minikube with Docker isolated boundaries:
   ```bash
   minikube start --driver=docker
   ```
2. Validate cluster access points and confirm node state availability:
   ```bash
   kubectl get nodes
   ```

### Step 7: Continuous Deployment via ArgoCD
Implement GitOps cycles to capture explicit states declared in git.

1. Create a segregated workspace for the operator controls:
   ```bash
   kubectl create namespace argocd
   ```
2. Deploy the core ArgoCD manifest controllers:
   ```bash
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
   ```
3. Expose the administration UI locally:
   ```bash
   kubectl port-forward svc/argocd-server -n argocd 55753:443
   ```
4. Extract the base system initialization security token:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```
5. Authenticate via CLI to configure delivery pathways:
   ```bash
   argocd login 127.0.0.1:55753 --username admin --password <YOUR_PASSWORD> --insecure
   ```

### Step 8: Local AWS Emulation with Floci
Run a free, open-source local AWS emulator on your machine for development, testing, and CI — no cloud account or auth token required. For more information, see the [`floci/README.md`](floci/README.md).

> ⚠️ **Warning:** The optional `cloudflared` service exposes `floci` to the public internet through a [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/networks/connectors/cloudflare-tunnel/). Only enable it if you understand the security implications, and review the official docs before publishing your local services to the web.

1. Create a `.env` file in the project root to configure environment variables:
   ```env
   TUNNEL_TOKEN=your-cloudflare-tunnel-token
   ```
2. Launch the stack with Docker Compose:
   ```bash
   docker compose up --build
   ```
   This starts two services on a shared `floci-network`:
   | Service       | Image                            | Description                                          |
   | ------------- | -------------------------------- | ---------------------------------------------------- |
   | `floci`       | `floci/floci:latest`             | Local AWS emulation, exposed on `4566`               |
   | `cloudflared` | `cloudflare/cloudflared:latest`  | Cloudflare Tunnel proxying `floci` securely          |
   The named volume `floci-data` is mounted at `/app/data` inside the `floci` container to persist AWS state across restarts.
3. Verify the deployment:
   - Floci is available locally at <http://localhost:4566>
   - If a tunnel token is configured, `cloudflared` will publish floci through the tunnel configured in your Cloudflare Zero Trust dashboard.
4. Point your AWS SDK, CLI, Terraform, CDK, OpenTofu, or test suite at `http://localhost:4566` and keep your existing workflows.
5. Useful commands:
   ```bash
   docker compose up -d          # run in the background
   docker compose logs -f        # tail logs from all services
   docker compose down           # stop the stack
   docker compose down -v        # stop and remove the floci-data volume
   ```
   > Thanks to the **floci team** for building and maintaining such a great tool.
   > - Website: <https://floci.io/floci/>
   > - GitHub: <https://github.com/floci-io/floci>

---

## 🎉 You're All Set!

With everything wired up, the user now has a complete local DevOps playground running on their laptop. From here, the user can tweak, break, and rebuild to their heart's content — swap components, add new services, integrate monitoring, or stand up a classic **LAMP** stack, a self-hosted **Nextcloud**, a **WordPress** site, or whatever else sparks curiosity. The lab is intentionally a sandbox, so experiment freely and let each iteration teach something new.

> *"The more you learn, the more you earn — but the real reward is becoming the engineer who can build, break, and fix anything."*
>
> Keep learning, keep shipping, and have fun with the stack. 🚀
