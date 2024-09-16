# INSTALL kind
# For AMD64 / x86_64
[ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
# For ARM64
[ $(uname -m) = aarch64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-arm64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# CREATE CLUSTER
kind create cluster --config /home/ker/kind-confs/cluster-ingress.yml

# INSTALL kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm kubectl

# ENABLE INGRESS NGINX FOR KIND; SIMILAR SETUP TO CLOUD
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# VERIFY INGRESS NGINX SETUP
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

kubectl apply -f k8s-ingress/
kubectl delete -f k8s-ingress/

kubectl apply -f simple-ingress/nginx.yml
kubectl apply -f simple-ingress/tomcat.yml
kubectl apply -f simple-ingress/ingress.yml
kubectl delete -f simple-ingress/ingress.yml
kubectl delete -f /home/ker/kind-confs/k8s-ingress


watch kubectl get pods
watch kubectl get deploy
kubectl logs -f deploy/actuator-deploy
watch kubectl get svc
watch kubectl get ingress
kubectl describe ingress actuator-ingress

kubectl port-forward svc/nginx-svc 8080:80
kubectl port-forward svc/tomcat-svc 8080:8080
kubectl port-forward svc/timeserver-svc 8080:8080

kubectl explain ingress.spec.rules.http.paths.backend.service.port

curl localhost/demo/actuator
curl localhost/nginx/