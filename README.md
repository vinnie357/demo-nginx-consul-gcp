# demo-nginx-consul
nginx k8s consul in gke

## Requirements

- GCS bucket with controller tarball

    eg: controller-installer-3.7.0.tar.gz

- Controller
  - license file

    [trial license](https://www.nginx.com/free-trial-request-nginx-controller/)

- Nginx plus
  - cert
  - key

    [trial keys](https://www.nginx.com/free-trial-request/)

## Workflow

Demo is to show container registry into Hashicorp consul which will be used as a configuration source to build NGINX+ configuration. NGINX+ instance will also be registered in NGINX Controller.

### Componets

- GKE
- NGINX Controller - https://github.com/MattDierick/F5-Networks/tree/master/others/Ansible/NGINX/NGINX%20Controller
- NGINX Host
  - https://github.com/nginxinc/ansible-role-nginx
  - https://github.com/nginxinc/ansible-role-nginx-controller-agent
- Consul
  - https://hub.docker.com/_/consul
``` Service Discovery with Containers
There are several approaches you can use to register services running in containers with Consul. For manual configuration, your containers can use the local agent's APIs to register and deregister themselves, see the Agent API for more details. Another strategy is to create a derived Consul container for each host type which includes JSON config files for Consul to parse at startup, see Services for more information. Both of these approaches are fairly cumbersome, and the configured services may fall out of sync if containers die or additional containers are started.

If you run your containers under HashiCorp's Nomad scheduler, it has first class support for Consul. The Nomad agent runs on each host alongside the Consul agent. When jobs are scheduled on a given host, the Nomad agent automatically takes care of syncing the Consul agent with the service information. This is very easy to manage, and even services on hosts running outside of Docker containers can be managed by Nomad and registered with Consul. You can find out more about running Docker under Nomad in the Docker Driver guide.

Other open source options include Registrator from Glider Labs and ContainerPilot from Joyent. Registrator works by running a Registrator instance on each host, alongside the Consul agent. Registrator monitors the Docker daemon for container stop and start events, and handles service registration with Consul using the container names and exposed ports as the service information. ContainerPilot manages service registration using tooling running inside the container to register services with Consul on start, manage a Consul TTL health check while running, and deregister services when the container stops.
```
- Consul Template
  - https://learn.hashicorp.com/tutorials/consul/load-balancing-nginx

### variables
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| google | n/a |
| null | n/a |
| random | n/a |
| template | n/a |
| tls | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| adminAccount | admin account | `any` | n/a | yes |
| adminPass | admin password | `any` | n/a | yes |
| adminSrcAddr | admin src address in cidr | `any` | n/a | yes |
| baseDomain | The root DNS name | `string` | n/a | yes |
| controllerAccount | name of controller admin account | `string` | `"admin"` | no |
| controllerLicense | license for controller | `string` | `"none"` | no |
| controllerPass | pass of controller admin account | `string` | `"admin123!"` | no |
| dbPass | pass of controller admin account | `string` | `"naaspassword"` | no |
| dbUser | pass of controller admin account | `string` | `"naas"` | no |
| gcpProjectId | gcp project id | `any` | n/a | yes |
| gcpRegion | region where gke is deployed | `any` | n/a | yes |
| gcpZone | zone where gke is deployed | `any` | n/a | yes |
| gkeVersion | https://cloud.google.com/kubernetes-engine/docs/release-notes-regular https://cloud.google.com/kubernetes-engine/versioning-and-upgrades gcloud container get-server-config --region us-east1 | `string` | `"1.18.14-gke.1200"` | no |
| nginx-controllerBucket | name of controller installer bucket | `string` | `"none"` | no |
| nginxCert | cert for nginxplus | `any` | n/a | yes |
| nginxKey | key for nginxplus | `any` | n/a | yes |
| nginxPublicKey | admin public key | `any` | n/a | yes |
| podCidr | k8s pod cidr | `string` | `"10.56.0.0/14"` | no |
| projectPrefix | prefix for resources | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| jumphost | jumphost |
| jumphost-group-info | jumphost group |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
