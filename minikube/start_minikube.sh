# Starts minikube service
minikube start
minikube addons enable metrics-server
minikube status
# Additional if you need to open the proxy to the machine (for dns):
sudo fuser -k 41825/tcp 2>/dev/null; sleep 1; nohup kubectl proxy --port=41825 --address='127.0.0.1' --accept-hosts='.*' > ~/proxy.log 2>&1 & # Comment this command if you are using a local machine instead of a real server
