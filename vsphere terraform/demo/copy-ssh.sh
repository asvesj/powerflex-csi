ssh-keygen -f $HOME/.ssh/id_rsa -t rsa -N ''
#enter the password of the root user
sshpass -p "PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no 10.10.10.191
sshpass -p "PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no 10.10.10.192
sshpass -p "PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no 10.10.10.193
sshpass -p "PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no 10.10.10.194
