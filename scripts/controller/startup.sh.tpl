#!/bin/bash

# install packages

sudo apt-get install gettext bash jq gzip coreutils grep less sed tar python-pexpect socat conntrack -y

# install docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
rm get-docker.sh
# install compose
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
#Run  services for controller
sleep 10
cat << EOF > docker-compose.yml
version: "3.7"
services:
  controller-postgres:
    image: postgres:9.5
    ports:
    - "5432:5432"
    restart: always
    environment:
      POSTGRES_USER: "naas"
      POSTGRES_PASSWORD: "naaspassword"
      POSTGRES_DB: "naas"
  controller-smtp:
    image: namshi/smtp
    ports:
    - "2587:25"
    restart: always
    network_mode: "host"
EOF
sudo docker-compose up -d

# install controller
sudo apt-get install jq -y
token=$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token' -H 'Metadata-Flavor: Google' | jq -r .access_token )
url="https://storage.googleapis.com/storage/v1/b/controller-demo/o/controller-installer-3.7.0.tar.gz?alt=media"
name=$(basename $url )
file=$${name}
file=$${file%"?alt=media"}
echo "$${file}"
curl -Lsk -H "Metadata-Flavor: Google" -H "Authorization: Bearer $token" $url -o /$file
tar xzf /$file
cd controller-installer
local_ipv4="$(curl -s -f --retry 20 'http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip' -H 'Metadata-Flavor: Google')"
echo "$${local_ipv4} 5432 naas naaspassword naaspassword local q y $${local_ipv4} 2587 n n 'noreply@example.com' $${local_ipv4} Nginx Admin Nginx admin@nginx-gcp.internal 'admin123!' 'admin123!' y" | ./install.sh

#vars:
#    - ctrl_tarball_src: "{{ctrl_install_path}}/{{controller_tarball}}"
#    - ctrl_install_path: /home/ubuntu
#    - remote_src: no
#    - db_host: 10.1.20.13
#    - db_port: "5432"
#    - db_user: "naas"
#    - db_password: 'naaspassword'
#    - tsdb_volume_type: local
#    - tsdb_nfs_path: "/controllerdb"
#    - tsdb_nfs_host: storage.internal
#    - smtp_host: "10.1.20.13"
#    - smtp_port: "25"
#    - smtp_authentication: false
#    - smtp_use_tls: false
#    - noreply_address: "noreply@example.com"
#    - fqdn:  10.1.20.13
#    - organization_name: "Nginx"
#    - admin_firstname: "Admin"
#    - admin_lastname: "Nginx"
#    - admin_email: "admin@nginx-gcp.internal"
#    - admin_password: 'admin123!'
#    - self_signed_cert: true
#    - overwrite_existing_configs: true
#    - auto_install_docker: false
#    - controller_tarball: "offline-controller-installer-1940006.tar.gz"
#    - ansible_python_interpreter: /usr/bin/python3