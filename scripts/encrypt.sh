echo "Encrypting ${1} as ${2}" 
openssl aes-256-cbc -e -in $1 -out $2 -pass file:../assets/.password -pbkdf2
