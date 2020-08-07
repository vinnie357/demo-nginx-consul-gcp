#!/bin/bash

# install packages

sudo apt get install gettext bash jq gzip coreutils grep less sed tar python-pexpect socat conntrack -y

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
    env:
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
#    - admin_email: "admin@nginx-udf.internal"
#    - admin_password: 'admin123!'
#    - self_signed_cert: true
#    - overwrite_existing_configs: true
#    - auto_install_docker: false
#    - controller_tarball: "offline-controller-installer-1940006.tar.gz"
#    - ansible_python_interpreter: /usr/bin/python3