echo "Decrypting ${1} to ${2}"
openssl aes-256-cbc -d -in $1 -out $2 -pass file:../assets/.password -pbkdf2
