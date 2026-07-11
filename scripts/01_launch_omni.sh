export OMNI_VERSION=`wget -qO - "https://api.github.com/repos/siderolabs/omni/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")'`

OMNI_ASSETS=~/omni
OMNI_PRIVATE_ENV=${OMNI_ASSETS}/private.env.decrypted

echo "Sourcing ${OMNI_PRIVATE_ENV}"
. ${OMNI_PRIVATE_ENV}

echo "Launching via docker compose"
docker compose --env-file ${OMNI_ASSETS}/omni.env up -d
