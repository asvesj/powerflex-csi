#install and send sshkeys from Rancher host to remote kubernetes hosts
yum install sshpass -y
ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''
#enter the "PASSWORD" of your root user
sshpass -p "PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no 10.10.10.191
sshpass -p "PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no 10.10.10.192
sshpass -p "PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no 10.10.10.193
sshpass -p "PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no 10.10.10.194
#install ansible
yum install epel-release -y
yum install ansible -y
sed -i '/remote_tmp/s/^#//g' /etc/ansible/ansible.cfg
sed -i '/host_key_checking/s/^#//g' /etc/ansible/ansible.cfg
#install rancher
curl -k https://releases.rancher.com/install-docker/18.09.9.sh | sh
systemctl enable docker
docker run -d --privileged --restart=unless-stopped   -p 80:80 -p 443:443   rancher/rancher:latest
