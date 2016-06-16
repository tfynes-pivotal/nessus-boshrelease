#!/bin/bash

echo
echo "Nessu User/Pass Creation BoshAddon Manifest Generator"
echo "  Creates Bosh AddOn Manifest with user supplied username, sha512 hash of supplied password"
echo
filename="adduser.yml"

read -p Username: user
echo

stty_orig=`stty -g`
stty -echo
read -s -p Password: pwd
stty $stty_orig
echo

stty_orig=`stty -g`
stty -echo
read -s -p "Confirm Password:" pwd2
stty $stty_orig
echo

if [ "$pwd" == "$pwd2" ] 
then

cryptopass=`python -c 'import crypt; print crypt.crypt("'$pwd'","$6$salt")'`
echo "cryptopass = $cryptopass"
echo

cat << EOT > $filename
releases:
  - name: os-conf
    version: 6

addons:
  - name: user_add
    jobs:
    - name: user_add
      release: os-conf
    properties:
      users:
      - name: $user 
        crypted_password: "$cryptopass" 
EOT

echo
echo "Nessus Username $user and Password have been added to file $filename"
echo

else
  echo "ERROR: Password Mismatch"
fi
#python -c 'import crypt; print crypt.crypt("ntest12345","$6$salt")'
