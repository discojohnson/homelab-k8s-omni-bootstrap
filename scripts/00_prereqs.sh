apt-get install -y certbot python3-certbot-dns-cloudflare git curl openssl gpg

OMNI_ASSETS=~/omni
ETCD_ENCRYPTION_KEY=${OMNI_ASSETS}/omni.asc.decrypted
OMNI_ENV_TEMPLATE=${OMNI_ASSETS}/omni.env.original
OMNI_COMPOSE_TEMPLATE=${OMNI_ASSETS}/compose.yaml.original
mkdir -p ${OMNI_ASSETS}

if [ ! -e ${OMNI_ASSETS}/.password ]; then
  echo " "
  echo " "
  echo "No ${OMNI_ASSETS}/.password file exists. Either CTRL-C things right now and create it, or just input a bunch of random characters here (but nothing that will break your shell's read command"
  read -p "Your choice of a password is: " temppassword
  echo ${temppassword} > ${OMNI_ASSETS}/.password
fi

if [ ! -e ${ETCD_ENCRYPTION_KEY} ]; then
  gpg --batch --passphrase '' --quick-generate-key "Omni (Used for etcd data encryption)" rsa4096 cert never
  OMNI_FINGERPRINT=`gpg --with-colons --list-keys "Omni" | awk -F: '$1 == "fpr" {print $10; exit}'`
  gpg --batch --passphrase '' --quick-add-key ${OMNI_FINGERPRINT} rsa4096 encr never
  gpg --export-secret-key --armor Omni > ${ETCD_ENCRYPTION_KEY}
fi

OMNI_VERSION=`wget -qO - "https://api.github.com/repos/siderolabs/omni/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")' | sed 's/v//g'`
curl https://raw.githubusercontent.com/siderolabs/omni/v${OMNI_VERSION}/deploy/compose/env.template > ${OMNI_ENV_TEMPLATE}
curl https://raw.githubusercontent.com/siderolabs/omni/v${OMNI_VERSION}/deploy/compose/compose.yaml -o ${OMNI_COMPOSE_TEMPLATE}

cp ../assets/omni.env ${OMNI_ASSETS}/omni.env
cp ../assets/compose.yaml ${OMNI_ASSETS}/compose.yaml

cp ../assets/private.env.template ${OMNI_ASSETS}/private.env.decrypted

if [ -e ../assets/private.env.encrypted ]; then
  sh decrypt.sh ../assets/private.env.encrypted ${OMNI_ASSETS}/private.env.decrypted
  . ${OMNI_ASSETS}/private.env.decrypted
  if [ "${OMNI_DECRYPTION_TEST}" != "passed" ]; then
    echo "Decryption test failed. The password is probably wrong"
  fi
fi

if [ -e ../assets/cloudflare.ini.encrypted ]; then
  sh decrypt.sh ../assets/cloudflare.ini.encrypted ${OMNI_ASSETS}/cloudflare.ini.decrypted
fi

