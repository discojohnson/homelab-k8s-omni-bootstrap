apt-get install -y certbot python3-certbot-dns-cloudflare git curl openssl gpg

OMNI_ASSETS=~/omni
ETCD_ENCRYPTION_KEY=${OMNI_ASSETS}/omni.asc.decrypted
OMNI_ENV_TEMPLATE=${OMNI_ASSETS}/omni.env.template
OMNI_COMPOSE_TEMPLATE=${OMNI_ASSETS}/compose.yaml.template
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

#######
####### private environment overrides
#######
echo "Private Environment Overrides"

OMNI_PRIVATE_ENV=${OMNI_ASSETS}/private.env.decrypted
echo "..Copying template to ${OMNI_PRIVATE_ENV}"
cp ../assets/private.env.template ${OMNI_PRIVATE_ENV}

echo "..Checking if encrypted version already exists"
if [ -e ../assets/private.env.encrypted ]; then
  echo "....It does, so decrypt it"
  sh decrypt.sh ../assets/private.env.encrypted ${OMNI_PRIVATE_ENV}
  echo "....Source it"
  . ${OMNI_PRIVATE_ENV}
  echo "....Check if OMNI_DECRYPTION_TEST is now set"
  if [ "${OMNI_DECRYPTION_TEST}" != "passed" ]; then
    echo "Decryption test failed. The password is probably wrong. Either delete ../assets/private.env.encrypted or fix your ${OMNI_ASSETS}/.password, then retry."
  fi
fi

echo "..Sourcing ${OMNI_PRIVATE_ENV}"
. ${OMNI_PRIVATE_ENV}

#######
####### authentik
#######
echo "Authentik metadata"

# use this section if you have to specify an xml file instead of being able to use a URL; this happens when you can't use port 443 on the authentik server
echo "..Checking if encrypted version already exists"
if [ -e ../assets/authentik.metadata.xml.encrypted ]; then
  echo "....It does, so decrypt it. Assuming password was fine though"
  sh decrypt ../assets/authentik.metadata.xml.encrypted ${OMNI_ASSETS}/authentik.metadata.xml.decrypted
fi

#######
####### certbot
#######
echo "Certbot"

CLOUDFLARE_INI=${OMNI_ASSETS}/cloudflare.ini.decrypted
echo "..Copying template to ${CLOUDFLARE_INI}"
cp ../assets/cloudflare.ini.template ${CLOUDFLARE_INI}

echo "..Checking if encrypted version already exists"
if [ -e ../assets/cloudflare.ini.encrypted ]; then
  echo "....It does, so decrypt it. Assuming password was fine though"
  sh decrypt.sh ../assets/cloudflare.ini.encrypted ${CLOUDFLARE_INI}
fi
echo "..chmod 600 ${CLOUDFLARE_INI}"
chmod 600 ${CLOUDFLARE_INI}

echo "..Call certbot command: certbot certonly --dns-cloudflare --dns-cloudflare-credentials ${CLOUDFLARE_INI} -d ${OMNI_DOMAIN_NAME} -n --agree-tos"
certbot certonly --dns-cloudflare --dns-cloudflare-credentials ${CLOUDFLARE_INI} -d ${OMNI_DOMAIN_NAME} -n --agree-tos
