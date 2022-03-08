#!/bin/sh
# add new domain
test -z $1 && echo "pleae specify domain: \n\$ adddomain.sh example.com admin@example.com" && exit 1
test -z $2 && echo "pleae specify email: \n\$ adddomain.sh example.com admin@example.com" && exit 1
NewDomain=$1
domain_args="-d $NewDomain"
email_arg="--email $2"
data_path="./data/certbot"
path="$(dirname "$(readlink -f $0)")/data/certbot/conf/live/${NewDomain}"
rsa_key_size=4096
mkdir -p "$path"
openssl req -x509 -nodes -newkey rsa:$rsa_key_size -days 1\
    -keyout "${path}/privkey.pem" \
    -out "${path}/fullchain.pem" \
    -subj '/CN=localhost'
docker-compose up --force-recreate -d nginx
rm -rf ${path}
docker-compose run --rm --entrypoint "\
  certbot certonly --webroot -w /var/www/certbot \
    $staging_arg \
    $email_arg \
    $domain_args \
    --rsa-key-size $rsa_key_size \
    --agree-tos \
    --force-renewal" certbot
docker-compose exec nginx nginx -s reload
