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

---

## 💻 System Prerequisites
* **Memory:** Minimum 8GB RAM (16GB recommended).
* **Storage:** 20GB free disk space.
* **Hypervisor:** VirtualBox installed with virtualization enabled in BIOS/UEFI.

---

## 🚀 Step-by-Step Implementation

### Step 1: Provision VMs via Vagrant
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

### Step 2: Automation with Ansible
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

### Step 3: Run Containers with Docker
Deploy isolated target application packages over standard system boundaries.

1. Write a basic configuration file to render custom tracking assets.
2. Use Ansible configurations or manual steps inside target VMs to install and pull target assets:
   ```bash
   sudo apt-get update && sudo apt-get install -y docker.io
   ```

### Step 4: Bootstrap Local Kubernetes with Minikube
Spin up your container orchestration plane engine locally.

1. Initialize Minikube with Docker isolated boundaries:
   ```bash
   minikube start --driver=docker
   ```
2. Validate cluster access points and confirm node state availability:
   ```bash
   kubectl get nodes
   ```

### Step 5: Continuous Deployment via ArgoCD
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
