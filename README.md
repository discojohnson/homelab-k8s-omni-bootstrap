# homelab-k8s-omni-bootstrap
Easy-to-run scripts for bootstrapping a Sidero Labs Omni controller

## Prequel

These instructions are for deploying Omni as a pet (vs livestock), but at least it's a designer pet and can be recreated pretty quickly/easily. To follow the design principle of not allowing circular dependencies (Omni in a K8s cluster managed by Omni), Omni runs as its own VM; Omni runs in a container, but you will have to manage the OS. One could take a less manual approach and deploy via Helm chart, but the author isn't that smart yet.

These steps are all loosely based on the official Sidero Labs instructions and a blog https://andreivasiliu.com/need-for-speed-automating-proxmox-k8s-clusters-with-talos-omni

# Installation

## Overall Prereqs
- Cloudflare manages a DNS zone, which will be used by Certbot to get valid SSL certificates across the lab

## VM Prereqs
- Debian Trixie
- Set a static IP or DHCP reservation

```text
# remove the old junk
sudo apt remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)

# install required packages
sudo apt-get install certbot python3-certbot-dns-cloudflare git curl openssl

# upgrade
sudo apt-get update && sudo apt-get upgrade

# install docker via the helper script
curl -fsSL https://test.docker.com -o test-docker.sh
sudo sh test-docker.sh


```
