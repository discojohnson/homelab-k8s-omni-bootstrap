# Cluster Templates

This directory contains Omni cluster template definitions for deploying Talos Kubernetes clusters on Proxmox via Sidero Omni.

## Available Templates

### Development Clusters

**`k8s-dev-dhcp.yaml`**
- Cluster name: `k8s-dev-dhcp`
- 1 control plane node
- 3 worker nodes
- Uses DHCP for IP assignment (gateway provided by DHCP)
- Configured NTP (pool.ntp.org)
- Hostnames: DHCP/Default (static hostnames removed for Talos 1.12+ compatibility)
- Simpler configuration, good for testing

## Network Configuration

All templates use:
- **Machine classes**: `proxmox-control-plane` and `proxmox-worker` (defined in `../machine-classes/`)
- **System extensions**:
  - siderolabs/iscsi-tools (iSCSI storage support)
  - siderolabs/nfsd (NFS support)
  - siderolabs/qemu-guest-agent (Proxmox integration)
  - siderolabs/util-linux-tools (System utilities)

## Usage

### Deploy a Cluster

From the root of this repository:

```bash
# Sync template to Omni (creates/updates cluster definition)
omnictl cluster template sync -v -f cluster-template/k8s-dev-dhcp.yaml
```

### Delete a Cluster

From the root of this repository:

```bash
# Delete cluster and all resources using the template file
omnictl cluster delete -v -f cluster-template/k8s-dev-dhcp.yaml

# Or delete by name
omnictl cluster delete k8s-dev
```

### Monitor Cluster Creation

```bash
# Watch cluster status
omnictl get clusters

# Watch machines being provisioned
omnictl get machines

# Get cluster details
omnictl get cluster k8s-dev -o yaml
```

## Template Structure

```yaml
---
kind: Cluster           # Cluster metadata
name: cluster-name
kubernetes:
  version: v1.36.2      # K8s version
talos:
  version: v1.13.6      # Talos OS version

---
kind: ControlPlane      # Control plane definition
machineClass:
  name: machine-class-name
  size: 1               # Number of control plane nodes
systemExtensions: [...]
patches: [...]          # Network config, extensions, etc.

---
kind: Workers           # Worker definition (can have multiple)
name: worker-name
machineClass:
  name: machine-class-name
  size: 1
systemExtensions: [...]
patches: [...]
```
