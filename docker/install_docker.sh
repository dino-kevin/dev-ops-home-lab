# Update your package lists
sudo apt-get update

# Install prerequisites
sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# Add the Docker repository
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
# Update and install Docker
sudo apt-get update
sudo apt-get install docker-ce
# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker
# Add your user to the docker group
# sudo usermod -aG docker $USER
