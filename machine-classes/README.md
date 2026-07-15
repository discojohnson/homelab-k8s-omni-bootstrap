# Machine Classes

This directory contains Omni machine class definitions that specify the hardware resources for VMs provisioned on Proxmox via the Sidero Omni infrastructure provider.

## Overview

Machine classes define the VM specifications (CPU, memory, disk, network) that will be used when Omni provisions machines on Proxmox. These classes are referenced by cluster templates to determine what type of resources each node should receive.

## Template Machine Classes

You will need to copy the template files to their base yaml files (control-plane.yaml.template -> dev-cluster-control-plane.yaml) and modify as appropriate.

### `control-plane.yaml.template`
**Machine class ID:** `proxmox-control-plane`

Control plane node specifications:
- **CPU**: 2 cores, 1 socket
- **Memory**: 4096 MB (2 GB)
- **Disk**: 40 GB
- **Network**: vmbr0 bridge
- **Storage**: local-lvm (via selector `name == "local-lvm"`)
- **Provider**: proxmox

### `worker.yaml.template`
**Machine class ID:** `proxmox-worker`

Worker node specifications:
- **CPU**: 4 cores, 1 socket
- **Memory**: 8192 MB (8 GB)
- **Disk**: 60 GB
- **Network**: vmbr0 bridge
- **Storage**: local-lvm (via selector `name == "local-lvm"`)
- **Provider**: proxmox

## Configuration Fields

### Provider Data
The `providerdata` section contains Proxmox-specific configuration:

- **`cores`**: Number of CPU cores per socket
- **`sockets`**: Number of CPU sockets
- **`memory`**: RAM in MB
- **`disk_size`**: Root disk size in GB
- **`network_bridge`**: Proxmox network bridge to attach VMs to (usually `vmbr0`)
- **`storage_selector`**: CEL expression to select Proxmox storage (e.g., `name == "local-lvm"`)
- **`grpctunnel`**: Enable/disable gRPC tunnel (0 = disabled, 1 = enabled)

### Storage Selector
The `storage_selector` uses Common Expression Language (CEL) to match Proxmox storage pools:
- `name == "local-lvm"` - Match by exact name
- `type == "lvm"` - Match by storage type
- `name matches "^local.*"` - Match by regex pattern

## Usage

### Apply Machine Classes to Omni

Before deploying clusters, register the machine classes with Omni:

```bash
cd ~/homelab-k8s-omni-bootstrap/machine-classes

# Apply control plane class
omnictl apply -f control-plane.yaml

# Apply worker class
omnictl apply -f worker.yaml

# Verify classes are registered
omnictl get machineclasses
```

### List Machine Classes

```bash
# List all machine classes
omnictl get machineclasses

# Get details for a specific class
omnictl get machineclass proxmox-control-plane -o yaml
omnictl get machineclass proxmox-worker -o yaml
```

### Update Machine Classes

To modify resource allocations:

1. Edit the YAML file
2. Update the values in the `providerdata` section
3. Reapply to Omni:
   ```bash
   omnictl apply -f control-plane.yaml
   omnictl apply -f worker.yaml
   ```

**Note:** Changes to machine classes affect newly provisioned machines only. Existing machines keep their original specs.

### Delete Machine Classes

```bash
# Delete specific class
omnictl delete machineclass proxmox-control-plane
omnictl delete machineclass proxmox-worker

# Warning: Cannot delete classes that are referenced by active clusters
```
