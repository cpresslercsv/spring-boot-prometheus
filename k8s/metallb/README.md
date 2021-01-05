

## Reference

https://www.thehumblelab.com/kind-and-metallb-on-mac/  Use this as a detailed reference.   
Below we are highlighting the process to follow

### Required for Docker on mac osx
This section is neede to run metallb on mac osx

1) install tuntap
   brew tap homebrew/cask   
   brew install --cask tuntap   
    This might require enable permissions Systems Preferences -> Security & Privacy (1st Tab - General) you will see an additional button near the Allow apps downloaded from: (xxxxxxx)
   
2) Download https://github.com/AlmirKadric-Published/docker-tuntap-osx. Extract and run   

   
```bash
~/development » cd < directory of extracted zip file or git clone of docker-tuntap-osx >
~/development »  ./sbin/docker_tap_install.sh
~/development »  ./sbin/docker_tap_up.sh
# verify installation of tap1 interface
~/development » ifconfig

# look for this interface
tap1: flags=8843<UP,BROADCAST,RUNNING,SIMPLEX,MULTICAST> mtu 1500
	ether 5a:c9:9b:9d:15:07
	inet 10.0.75.1 netmask 0xfffffffc broadcast 10.0.75.3
	media: autoselect
	status: active
	open (pid 12174)
```

```bash
kubectl get nodes -o wide

~/development » kubectl get nodes -o wide                                                                  1 ↵ 
NAME                STATUS   ROLES    AGE    VERSION   INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                                     KERNEL-VERSION      CONTAINER-RUNTIME
dev-control-plane   Ready    master   3d2h   v1.19.1   172.18.0.3    <none>        Ubuntu Groovy Gorilla (development branch)   4.19.121-linuxkit   containerd://1.4.0
dev-worker          Ready    <none>   3d2h   v1.19.1   172.18.0.5    <none>        Ubuntu Groovy Gorilla (development branch)   4.19.121-linuxkit   containerd://1.4.0
dev-worker2         Ready    <none>   3d2h   v1.19.1   172.18.0.4    <none>        Ubuntu Groovy Gorilla (development branch)   4.19.121-linuxkit   containerd://1.4.0
dev-worker3         Ready    <none>   3d2h   v1.19.1   172.18.0.2    <none>        Ubuntu Groovy Gorilla (development branch)   4.19.121-linuxkit   containerd://1.4.0

```

As you can see, our nodes deployed onto a 172.18.x.x network. To use the gateway on the tap interface we created earlier, we'll add a static route into this network. This will allow us to (soon) route to our MetalLB load balancers. You'll want to validate the network KinD deployed the nodes onto in your environment. This can be done by using the docker network ls and docker network inspect commands to check your network. Kind creates a Docker network aptly called “kind”, so the command you would run is docker network inspect kind, and look for the “Subnet” entry. In my environment, at the time of writing, it's 172.18.0.0/16 for example.

Using this information, we can create our static route with the command below,

```bash
~/development » sudo route -v add -net 172.18.0.1 -netmask 255.255.0.0 10.0.75.2
# verify route
~/development » netstat -r
Routing tables

Internet:
Destination        Gateway            Flags        Netif Expire
default            192.168.102.1      UGSc           en0
10.0.75/30         link#22            UC            tap1      !
10.0.75.2          0:a0:98:bc:f5:d7   UHLWIi        tap1   1010
127                localhost          UCS            lo0
localhost          localhost          UH             lo0
169.254            link#6             UCS            en0      !
169.254.169.254    link#6             UHRLSW         en0      !
172.18             10.0.75.2          UGSc          tap1     <<<<<<<<<<<<<<<<<<<<<
# to delete a route if needed to change above
~/development » sudo route  delete -net 172.18 -ifp tap1
```
## Configure MetalLB

MetalLB has a great set of documentation for getting started. If running on a mac osx please make sure to    
configure the tuntap interface first BEFORE proceeding.

We'll simply execute the following command to deploy out the necessary manifests for MetalLB

```bash
~/development » kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/namespace.yaml
~/development » kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
~/development » kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.9.3/manifests/metallb.yaml


~/development » kubectl create -f metallb-config.yaml
```

Show the output now with a valid external IP for LoadBalancer
### Before applying metallb config
LoadBalancer stays in ***pending state***
```bash
~/development » kubectl get services                                                                           
NAME                         TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                       AGE
demo                         LoadBalancer   10.96.210.245   <pending>      8080:30327/TCP                70m
kubernetes                   ClusterIP      10.96.0.1       <none>         443/TCP                       5h24m
whoami                       ClusterIP      10.96.185.153   <none>         80/TCP                        4h51m
```
### After applying metallb config
```bash
~/development  » kubectl get services                                                                                                                                                                                     chesterpressler@SVUSLP00196
NAME                         TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                       AGE
demo                         LoadBalancer   10.96.210.245   172.18.0.152   8080:30327/TCP                70m
kubernetes                   ClusterIP      10.96.0.1       <none>         443/TCP                       5h24m
whoami                       ClusterIP      10.96.185.153   <none>         80/TCP                        4h51m
```

Access to the cluster service is now available via ip address 172.18.0.152
```bash
~/development  » » curl http://172.18.0.152:8080/hello-world         
                                                                         
{"id":12,"content":"Hello, Stranger!"}
```


