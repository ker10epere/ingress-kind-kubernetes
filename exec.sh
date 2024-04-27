kind create cluster --config /home/ker/kind-confs/cluster-ingress.yml

kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

kubectl apply -f /home/ker/kind-confs/k8s-ingress
kubectl delete -f /home/ker/kind-confs/k8s-ingress

curl localhost/demo/actuator