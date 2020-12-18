# Read Me First

# Getting Started

Requires
1) docker desktop
2) kubectl      
   brew install kubectl-cli  
3) KinD or k3d. We are using KinD here    
   brew install kind

## Kind setup
Mac os
```
brew install kind

# create a single node cluster named ev

kind create cluster --name dev
```
Optional create a multi node cluster
```bash
kind create cluster --name dev --config ./1cp-3workers.yaml
```
1cp-3workers.yaml
```yaml  
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
  - role: control-plane
  - role: worker
  - role: worker
  - role: worker
```
```bash
kubectl get nodes

~ » kubectl get nodes                                                                 chesterpressler@SVUSLP00196
NAME                STATUS   ROLES    AGE     VERSION
dev-control-plane   Ready    master   3m15s   v1.19.1
dev-worker          Ready    <none>   2m46s   v1.19.1
dev-worker2         Ready    <none>   2m46s   v1.19.1
dev-worker3         Ready    <none>   2m46s   v1.19.1
```


## Building App


```bash
mvn clean compile
# to build via Jib
mvn jib:build

# to build a docker build
mvn jib:dockerBuild
```

## Running app

### Running via command line
```bash

# optional 
kubectl create ns test
skaffold dev --port-forward <-n test> 

skaffold debug --port-forward <-n test> 
```
