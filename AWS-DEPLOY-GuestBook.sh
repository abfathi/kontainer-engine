#/bin/bash!
echo $PWD

kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubernetes/v1.10.3/examples/guestbook-go/redis-master-controller.json

kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubernetes/v1.10.3/examples/guestbook-go/redis-master-service.json

kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubernetes/v1.10.3/examples/guestbook-go/redis-slave-controller.json

kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubernetes/v1.10.3/examples/guestbook-go/guestbook-controller.json

kubectl apply -f https://raw.githubusercontent.com/kubernetes/kubernetes/v1.10.3/examples/guestbook-go/guestbook-service.json

external_ip='<pending>'
sleep_time=60

while [[ $external_ip == '<pending>' ]];do
sleep $sleep_time
external_ip=$(kubectl get services -o wide |grep -w  guestbook|awk '{print $4}')
port=$(kubectl get services -o wide |grep -w  guestbook|awk '{print $5}'|cut -f1 -d ':') 
done
echo -e "external-ip=$external_ip"
echo -e "port=$port"
#sleep $sleep_time
#resp=$(curl -v http://$external_ip:$port)
#echo -e "resp=$resp"