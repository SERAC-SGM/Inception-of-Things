#!/bin/bash

echo -e "\nCreating scripts...\n"

cat << 'EOF' > argo-application.yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: wil-playground-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: 'https://github.com/SERAC-SGM/lletourn-iot'
    targetRevision: HEAD
    path: . 
  destination:
    server: 'https://kubernetes.default.svc'
    namespace: dev
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
EOF

cat << 'SCRIPT' > portforward.sh
#!/bin/bash

echo -e "Starting port-forwarding...\n"

./kubectl port-forward svc/argocd-server -n argocd 8080:443 &>/dev/null &
ARGOC_PID=$!

./kubectl port-forward svc/wil-playground -n dev 8888:8888 &>/dev/null &
PLAYGROUND_PID=$!
echo -e "wil-playground :\thttp://localhost:8888"
echo -e "argocd :\t\thttp://localhost:8080\n| user:\t\tadmin\n| password:\t$(./kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)\n\n"


cleanup() {
  echo "Stopping port-forwarding..."
  kill $ARGOC_PID $PLAYGROUND_PID
  wait $ARGOC_PID $PLAYGROUND_PID 2>/dev/null
  echo "Port-forwarding stopped."
}

# Set trap to call cleanup on script exit
trap cleanup EXIT

# Keep script running
while :; do
  sleep 1
done
SCRIPT

cat << 'SCRIPT' > clean.sh
#!/bin/bash

rm -f kubectl portforward.sh argo-application.yaml 

k3d cluster delete p3

rm -- "$0"
SCRIPT

chmod +x portforward.sh clean.sh

# Add Docker's official GPG key:
sudo apt-get update -y
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo chmod 777 /var/run/docker.sock

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update -y
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# kubectl install
curl -LO https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl

# k3d install
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Cluster creation
k3d cluster create p3 --api-port 6550 --port 8081:80

./kubectl create namespace argocd
./kubectl create namespace dev
./kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for argocd components to be ready
echo -e "\nWaiting for argocd deployment...\n"
./kubectl wait --for=condition=available --timeout 60s deployment -l app.kubernetes.io/name=argocd-server -n argocd 
./kubectl wait --for=condition=available --timeout 60s deployment -l app.kubernetes.io/name=argocd-repo-server -n argocd 
./kubectl wait --for=condition=available --timeout 60s deployment -l app.kubernetes.io/name=argocd-application-controller -n argocd 

./kubectl apply -f argo-application.yaml
echo -e "\nargo login:\n  user: admin\n  password: $(./kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)\n\n"
