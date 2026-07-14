export OMNI_VERSION=`wget -qO - "https://api.github.com/repos/siderolabs/omni/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'`

export OMNI_ASSETS=~/omni
OMNI_PRIVATE_ENV=${OMNI_ASSETS}/private.env.decrypted

echo "Sourcing ${OMNI_PRIVATE_ENV}"
. ${OMNI_PRIVATE_ENV}

export OMNI_DOMAIN_NAME
export OMNI_ACCOUNT_UUID
export OMNI_WG_IP
export OMNI_ADMIN_EMAIL

echo "Launching via docker compose"
docker compose -f ${OMNI_ASSETS}/omni.compose.yaml --env-file ${OMNI_ASSETS}/omni.env up -d
