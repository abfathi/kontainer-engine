#/bin/bash!
echo $PWD

cd ./build/bin/

if [ "$#" -ne "1" ]; then
    echo -e "Please provide cluster name"
    exit 1
fi

cluster_name=$1

endpoint=$(./kontainer-engine_darwin-amd64 inspect $cluster_name |jq .endpoint|cut -f2 -d '"')
#aws eks describe-cluster --name devel  --query cluster.endpoint
echo "endpoint=$endpoint"

certificateAuthority=$(aws eks describe-cluster --name $cluster_name  --query cluster.certificateAuthority.data|cut -f2 -d '"')
echo "certificateAuthority=$certificateAuthority"

cat << EOF > config-eks
apiVersion: v1
clusters:
- cluster:
    server: $endpoint
    certificate-authority-data: $certificateAuthority
  name: kubernetes
contexts:
- context:
    cluster: kubernetes
    user: aws
  name: aws
current-context: aws
kind: Config
preferences: {}
users:
- name: aws
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1alpha1
      command: heptio-authenticator-aws
      args:
        - "token"
        - "-i"
        - $cluster_name
EOF

mv ./config-eks ~/.kube/config