# demo-nginx-consul
nginx k8s consul in gke

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
