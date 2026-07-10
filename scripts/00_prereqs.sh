apt-get install -y certbot python3-certbot-dns-cloudflare git curl openssl gpg

if [ ! -e ../assets/omni.asc.encrypted ]; then
  gpg --batch --passphrase '' --quick-generate-key "Omni (Used for etcd data encryption)" rsa4096 cert never
  OMNI_FINGERPRINT=`gpg --with-colons --list-keys "Omni" | awk -F: '$1 == "fpr" {print $10; exit}'`
  gpg --batch --passphrase '' --quick-add-key ${OMNI_FINGERPRINT} rsa4096 encr never
  gpg --export-secret-key --armor Omni > ../assets/omni.asc.decrypted
  sh encrypt.sh ../assets/omni.asc.decrypted ../assets/omni.asc.encrypted
fi

if [ ! -e ../assets/omni.asc.decrypted ]; then
  sh decrypt.sh ../assets/omni.asc.encrypted ../assets/omni.asc.decrypted
fi

OMNI_VERSION=`wget -qO - "https://api.github.com/repos/siderolabs/omni/releases/latest" | grep -Po '"tag_name": "\K.*?(?=")' | sed 's/v//g'`
curl https://raw.githubusercontent.com/siderolabs/omni/v${OMNI_VERSION}/deploy/compose/env.template > ../assets/omni.env.original
curl https://raw.githubusercontent.com/siderolabs/omni/v${OMNI_VERSION}/deploy/compose/compose.yaml -o compose.yaml.original


