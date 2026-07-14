export OMNI_ASSETS=~/omni

echo "Proxmox Provider"

#######
####### environment file
#######
echo "Environment file"
PROXMOX_ENV=${OMNI_ASSETS}/proxmox_provider.env.decrypted
echo "..Copying template to ${PROXMOX_ENV}"
cp ../assets/proxmox_provider.env.template ${PROXMOX_ENV}

echo "..Sourcing ${PROXMOX_ENV}"
. ${PROXMOX_ENV}

#######
####### proxmox_provider.config.yaml
#######
echo "proxmox_provider.config.yaml"
PROXMOX_CONFIG_YAML=${OMNI_ASSETS}/proxmox_provider.config.yaml.decrypted
echo "..Copying template to ${PROXMOX_CONFIG_YAML}"
cp ../assets/proxmox_provider.config.yaml.template ${PROXMOX_CONFIG_YAML}

echo "..Checking if encrypted version already exists"
if [ -e ../assets/proxmox_provider.config.yaml.encrypted ]; then
  echo "....It does, so decrypt it. Assuming password was fine though"
  sh decrypt.sh ../assets/proxmox_provider.config.yaml.encrypted ${PROXMOX_CONFIG_YAML}
fi

echo "Copying Docker Compose file to ${OMNI_ASSETS}/proxmox_provider.compose.yaml"
cp ../assets/proxmox_provider.compose.yaml ${OMNI_ASSETS}/proxmox_provider.compose.yaml
echo "Launching via docker compose"
docker compose -f ${OMNI_ASSETS}/proxmox_provider.compose.yaml up -d
