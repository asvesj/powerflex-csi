# Advanced Users

For those users who are more advanced you can preload most of the software in your template VM and the Kubernetes implementation will run a lot quicker. <br> 
<br>To make this happen follow the below steps in your template VM: <br>
1.	Generate ssh keys for both root and user and add the keys to their authorized_keys file
2.	Modify /etc/ssh/ssh_config and change the line to 'StrictHostKeyChecking no'
3.	Create a non root user using 'useradd -m USERNAME'
4.	Change the password of the new user using 'passwd USERNAME'
5.	Add user to sudoers: echo 'USERNAME ALL=(ALL) NOPASSWD=ALL' >> /etc/sudoers
6.	Stop and disable firewalld 
7.	Modify SELINUX=permissive by editing /etc/selinux/config
8.	Run swapoff -a
9.	Remove any /etc/fstab entries (if any)
10.	Install the following packages:
<br>-	yum install -y yum-utils device-mapper-persistent-data lvm2
<br>- yum install -y epel-release 
<br>-	yum install -y ansible
11.	modify /etc/ansible/ansible.cfg with the following:
<br>-	uncomment 'remote_tmp'
<br>-	uncomment 'host_key_checking = false'
12.	Add docker repo
<br>-	yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
<br>-	yum install -y docker-ce-18.09.9 docker-ce-cli-18.09.9 containerd.io
13.	enable docker service: systemctl enable docker
14.	modify docker service by editing /etc/system/multi-user.target.wants/docker.service
<br>- after 'KillMode=process' insert 'MountFlags=shared'
15.	change from cgroups to systemd
<br>	cat > /etc/docker/daemon.json <<EOF
<br>{
<br>  "exec-opts": ["native.cgroupdriver=systemd"],
<br>  "log-driver": "json-file",
<br>  "log-opts": {
<br>    "max-size": "100m"
<br>  },
<br>  "storage-driver": "overlay2",
<br>  "storage-opts": [
<br>    "overlay2.override_kernel_check=true"
<br>  ]
<br>}
<br>EOF

<br>  - mkdir -p /etc/systemd/system/docker.service.d
<br>  - systemctl daemon-reload && systemctl restart docker <br>

16.	Letting iptables see bridged traffic:
<br>cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
<br>net.bridge.bridge-nf-call-ip6tables = 1
<br>net.bridge.bridge-nf-call-iptables = 1
<br>EOF
<br>sysctl --system <br>
17.	Set up Kubernetes repo:
<br>cat <<EOF > /etc/yum.repos.d/kubernetes.repo
<br>[kubernetes]
<br>name=Kubernetes
<br>baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
<br>enabled=1
<br>gpgcheck=1
<br>repo_gpgcheck=1
<br>gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
<br>EOF
<br>yum install -y kubeadm-1.16.0 kubelet-1.16.0 kubectl-1.16.0 kubernetes-cni-0.8.6-0

## Files Needed

Once you have completed the above steps then all you need are the following files in your folder:
1.	master.yml
2.	csi-vxflex-install.yml
3.	hosts
4.	verify.kubernetes
5.	get_helm.sh
6.	config.yaml

## Rancher

To get Rancher up run the following command: docker run -d --restart=unless-stopped   -p 80:80 -p 443:443   rancher/rancher:latest
To login, go to your browser and enter the IP address of the Rancher host: https://HOSTIP:443
