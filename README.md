# homelab-k8s-omni-bootstrap
Easy-to-run scripts for bootstrapping a Sidero Labs Omni controller

## Prequel

These instructions are for deploying Omni as a pet (vs livestock), but at least it's a designer pet and can be recreated pretty quickly/easily. To follow the design principle of not allowing circular dependencies (Omni in a K8s cluster managed by Omni), Omni runs as its own VM; Omni runs in a container, but you will have to manage the OS. One could take a less manual approach and deploy via Helm chart, but the author isn't that smart yet.

These steps are all loosely based on sources from around the web:
* Official Sidero Labs instructions
* https://andreivasiliu.com/need-for-speed-automating-proxmox-k8s-clusters-with-talos-omni
* https://integrations.goauthentik.io/infrastructure/omni/ <-- Authentik/Omni instructions

# Installation

## Overall Prereqs
- Cloudflare manages a DNS zone which will be used by Certbot, and you'll need an API token with all the right permissions to use the DNS01 method
- Authentik is already deployed and accessible via DNS and has SSL configured
- omni.whatever DNS entry is already created and points to the IP of the Omni VM

## Omni VM Prereqs
- Debian Trixie
- Set a static IP or DHCP reservation
- Put you Cloudflare API token in assets/cloudflare.ini.template
- Update assets/priate.env.template to use your own values

```text
# remove the old junk
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)

# install required packages
sudo apt-get install -y git curl openssl

# upgrade
sudo apt-get update && sudo apt-get upgrade

# install docker via the helper script
curl -fsSL https://test.docker.com -o test-docker.sh
sudo sh test-docker.sh

# grab this repo
cd ~
git clone https://github.com/discojohnson/homelab-k8s-omni-bootstrap
cd homelab-k8s-omni-bootstrap/scripts
sudo sh 00_prereqs.sh

```
