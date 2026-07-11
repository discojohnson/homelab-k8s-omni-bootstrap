echo "Encrypting ${1} as ${2}" 
openssl aes-256-cbc -e -in $1 -out $2 -pass file:/root/omni/.password -pbkdf2
