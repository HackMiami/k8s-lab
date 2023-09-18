# Kubernetes cluster lab

The intention for this lab is to have 2 working Kubernetes clusters as if it was setup on prem with consul and service mesh.

This lab also sets up Vault with etcd stroage in HA mode and ArgoCD, openEBS, Nginx-Ingest...
With the vault agent injector demo.

The setup make sure the system can use ansible playbooks and have the needed tools it uses.
To do this the script uses devbox.
`./setup-k8s-lab.sh`

To run the script you need to have a linode api token in `.linode_token`.

Req:

- devbox
- nix

## Nix and Devbox

The script checks for devbox which uses nix.
Before running this script you should install nix and devbox and I sugest install nix first.

### Nix

This is the cleans way to install nix but from my testing still needed to be install in a root shell.

https://determinate.systems/posts/determinate-nix-installer

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix > nix-installer.sh
chmod +x nix-installer.sh
./nix-installer.sh install
```

### Devbox

Installing devbox is easy.

```bash
curl -fsSL https://get.jetpack.io/devbox | bash
# Done

# To Test.
mkdir test_devbox
cd test_devbox
devbox init
devbox add ripgrep
devbox shell
```

### Setup

Make sure you have devbox and nix setup

Run the script and follow the prompts.
`./setup-k8s-lab.sh`

### Firewall

The scripts setup firewall rules and will only allow your IP to ssh.
`curl https://ifconfig.io`

The k8s_nodes zone list all the IP and ports for Kubernetes and Flannel to work.

6443/tcp: Kubernetes API server (master nodes)

2379/tcp: Kubernetes etcd server client API (on master nodes in multi-master deployments)

2380/tcp: Kubernetes etcd server client API (on master nodes in multi-master deployments)

10250/tcp: Kubernetes kubelet API server (master and worker nodes)

10251/tcp: Kubernetes kube-scheduler (on master nodes in multi-master deployments)

10252/tcp: Kubernetes kube-controller-manager (on master nodes in multi-master deployments)

10255/tcp: Kubernetes kubelet API server for read-only access with no authentication (master and worker nodes)

30000-32767: Kubernetes also recommends TCP 30000-32767 for node port services.

8472/udp: Flannel overlay network, VxLAN backend (master and worker nodes)

#### Admin_access Zone

This admin_access zone is set for target ACCEPT

```yml
- name: Make zone of ssh_access
  ansible.posix.firewalld:
    zone: admin_access
    target: ACCEPT
    state: present
    permanent: true
```

If you want to lock it down to ssh and 6443

This neededs to be done on all the servers in the lab.

```bash
firewall-cmd --zone=admin_access --permanent --set-target=default
firewall-cmd --reload
```

If you need to add your IP to the zone

```bash
firewall-cmd --zone=admin_access --permanent --add-source=YOUR_IP
firewall-cmd --reload
```

#### Opening services to the world

If you want to open a service to the world one of the worker nodes.

You can do this for example:

```bash
firewall-cmd --zone=public --permanent --add-port=443/tcp
firewall-cmd --reload
```

## Access the ENV

After the build has completed you can source the env files to access the servers.

In the k8s_env folder you will find atlanta_env and dallas_env. Source one of the files to open ports for the services you need, kubectl and consul installed on your devbox system.

- https://127.0.0.1:4343 - consul
- https://127.0.0.1:8200 - vault
- https://127.0.0.1:8080 - argocd

## Sharing access to the lab

You can tar up the k8s* folders and shere them with anyone in akamai to access the lab.

Or point them to this repo to setup there own.

`tar czf k8s.tar.gz k8s*`

## Building you your lab

You can install jenkins from the argocd ui and the helm chart.

Dont forget to add the port forward for the service port to your env file.

- https://127.0.0.1:8090 - jenkins

To get the jenkins password run this command:

`kubectl get secret jenkins -o jsonpath={.data.jenkins-admin-password} | base64 --decode ; echo`

Other apps to setup:

- https://artifacthub.io/packages/helm/k8s-dashboard/kubernetes-dashboard

## Connect ArgoCD to the Dallas

Add the cluster to argoCD to use the Dallas cluster.

```bash
cd k8s_env
source dallas_env
argocd cluster add kubernetes-admin@kubernetes dallas
```

Log into argoCD with admin http://localhost:8080

## kube-hunt

https://github.com/aquasecurity/kube-bench

```bash
git clone https://github.com/aquasecurity/kube-hunter.git
cd kube-hunter
kubectl apply -f jobs.yaml
kubectl get pods -o wide | grep kube-hunter
kubectl logs pod kube-hunter-??????
kubectl delete -f jobs.yaml
```

## kube-bench

https://github.com/aquasecurity/kube-bench

```bash
git clone https://github.com/aquasecurity/kube-bench.git
cd kube-bench
kubectl apply -f jobs.yaml
kubectl get pods -o wide | grep kube-bench
kubectl logs pod kube-bench-??????
kubectl delete -f jobs.yaml
```
