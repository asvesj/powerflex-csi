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
<br>yum install -y kubeadm-1.19.2 kubelet-1.19.2 kubectl-1.19.2 kubernetes-cni-0.8.7-0

## Files Needed

Once you have completed the above steps then all you need are the following files in your folder:
1.	master.yml
2.	csi-vxflex-install.yml
3.	hosts
4.	get_helm.sh
5.	config.yaml

## Instructions

1. Download the files into your local machine<br>

2. Modify the var.tf file with your vSphere credentials<br>

3. Modify the main.tf file that reflects your current vSphere environment, eg. datacenter name, VM template name, datastore name, network IPs, etc<br>

4. The files that you need to modify are below:
<br>a. 'hosts'
<br>    - enter the IP addresses of the Kubernetes Master and Worker hosts<br>
<br>b. 'master.yml'
<br>    - make sure you change all 'jono' references to your username
<br>    - change the directory name as well
<br>    - under the PowerFlex SDC installation section make sure you enter your MDM IPs and verified the binary location<br>
<br>c. 'csi-vxflex-install.yml'
<br>    - make sure you change all 'jono' references to your username
<br>    - change the directory name as well
<br>    - when modifying 'secret.yaml' you need to change the username and password to base64. To do that run this command: <br> echo -n USERNAME | base64 <br> echo -n PASSWORD | base64
<br>    - Under the 'myvalues.yaml' section replace the existing PowerFlex parameters with your PowerFlex system, eg. MDM IPs, storage pool name, etc <br>

5.	Zip all the files under the /demo/ directory named demo.zip
6.	Run 'terraform init' so it will download the vsphere provider to execute the code
7.	If you want to test your Terraform code you can run 'terraform plan' and if there any errors, it will tell you what you need to do to correct them
8.	When ready run ‘terraform apply -auto-approve’ and Terraform will build the VMs and upload the demo.zip file to the Rancher host
9.	Once you have unzipped the demo.zip file, change to the demo folder, install Rancher by running: 'docker run -d --restart=unless-stopped   -p 80:80 -p 443:443   rancher/rancher:latest'. To login, go to your browser and enter the IP address of the Rancher host: https://HOSTIP:443
10.	When that is complete, you can run the ansible playbooks individually or you can combine all the playbooks under one yml file <br>To run all the playbooks, execute the following: 'ansible-playbook -i hosts deployment.yml'
11.	When the csi-vxflex-install playbook has successfully finished, next step is to log in to the Kubernetes Master host <br>Switch from root to your user and run this command in the csi-vxflexos/dell-csi-helm-installer folder:<br> ./csi-install.sh --namespace=vxflexos --values=../helm/myvalues.yaml --skip-verify-node --snapshot-crd<br>
12. To add the Kubernetes cluster to Rancher, click 'Add Cluster' -> 'Import an existing cluster' -> give it a name under 'Cluster Name' -> 'hit Create' -> copy the last curl command to your Kubernetes Master host (you'll have to do this twice as i'm not sure how to correct that error, could be a bug?)    
13.	Once the plugin is installed, next step is to create a Cassandra pod
14.	Execute the following commands on the Kubernetes Master host as your user:
<br>a.	helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
<br>b.	helm repo update
<br>c.	helm install incubator/cassandra --generate-name <br>
15.	Next you can check the deployment in Kubernetes by running the following command (it will take about 10 minutes for the containers to be spun up on the Worker hosts so be patient)
<br>a.	kubectl get pods -o wide <br>
16.	To check for persistent volumes run the following:
<br>a.	kubectl get pvc <br>
17.	To delete a pod run the following:
<br>a.	kubectl delete pod cassandra-1xxxxxxxx <br>
18.	Check if the container is getting spun up again by running:
<br>a.	kubectl get pods -o wide <br>
19.	When finished with the pod run the following:
<br>a.	helm uninstall cassandra-1xxxxxxxx
<br>b.	This will go ahead and delete the pods but not the pvc so you'll have to manually delete them <br>This will change with the release of Helm 4 (currently running Helm 3)
<br>c.	To delete the pvc run ‘kubectl delete pvc data-cassandra-1xxxxxxxx’ <br>
20.	When you are finished with the demo return to the command prompt and run 'terraform destroy -auto-approve' <br>This will destroy all your VMs that were provisioned earlier.
