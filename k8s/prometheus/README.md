

# Deploy Prometheus & Grafana To Monitor Cluster

## Prerequisite
Kubectl - Kubernetes client to interact with the cluster   
Helm 3 available


## Setup

1) Creating Monitor Namespace
```bash
kubectl create namespace monitoring
```
2) Installation Of Prometheus Operator   
   use the Helm chart of Prometheus operator to deploy Prometheus Grafana and many services that have been used to monitor kubernetes clusters. For details visit https://github.com/helm/charts/tree/master/stable/prometheus-operator
```bash
# add the repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
# show latest version
helm search repo prometheus-community/kube-prometheus-stack
#install
helm install lastest prometheus-community/kube-prometheus-stack --namespace monitoring
```
validate Prometheus installation   

```bash
kubectl get pods -n monitoring

NAME                                                                                      READY   STATUS    RESTARTS   AGE
Alertmanager-prometheus-prometheus-oper-alertmanager     2/2        Running      0                 16m
prometheus-grafana-xxxxxxxxxx-yyyy                                   2/2        Running      0                 19m
prometheus-kube-state-metrics-6967c9fd67-zsw6c                 1/1        Running      0                 19m
prometheus-prometheus-node-exporter-jj6wq                          1/1        Running     0                  19m
prometheus-prometheus-oper-operator-77cbbc55f5-6btf2       2/2        Running      0                 19m
prometheus-prometheus-prometheus-oper-prometheus-0       3/3        Running      1                 15m

# now enable the proxy
kubectl port-forward -n prometheus prometheus-prometheus-prometheus-oper-prometheus-0 9090

 in a browser http://localhost:9090, you will see Prometheus dashboard
```
3) Configure Grafana Dashboard

```bash
kubectl port-forward -n prometheus prometheus-grafana-xxxxxxxxxx-yyyy 3000
```
Now you can access Grafana dashboard at localhost:3000

You will get the Grafana dashboard username and password from getting a secret from prometheus-grafana.    

```bash
kubectl get secret --namespace prometheus prometheus-grafana -o yaml

# results
```
```yaml
apiVersion: v1
data:
  admin-password: cHJvbS1vcGVyYXRvcg==
  admin-user: YWRtaW4=
  ldap-toml: ""
kind: Secret
type: Opaque

// with some other metadata
```

Decode the secrets
```bash
~ » echo `echo QWxhZGRpbjpvcGVuIHNlc2FtZQ== | base64 --decode`                                                                 chesterpressler@SVUSLP00196
Aladdin:open sesame
-----------------------------------------------------------------------------------------------------------------------------------------------------------
~ » echo `echo cHJvbS1vcGVyYXRvcg== | base64 --decode`                                                                         chesterpressler@SVUSLP00196
prom-operator
-----------------------------------------------------------------------------------------------------------------------------------------------------------
~ » echo `echo YWRtaW4= | base64 --decode`                                                                                     chesterpressler@SVUSLP00196
admin
```




#### Reference 
https://www.magalix.com/blog/monitoring-of-kubernetes-cluster-through-prometheus-and-grafana
https://doc.lucidworks.com/how-to/prometheus-grafana.html

https://koudingspawn.de/kubernetes-monitoring-prometheus/
https://koudingspawn.de/spring-boot-cloud-ready-part-ii/


