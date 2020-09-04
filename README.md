# powerflex-csi
Terraform-Ansible-Rancher-PowerFlex-CSI-Kubernetes-Cassandra Demo

## Description

This demo is designed to show how you can use multiple automation tools to build a Kubernetes environment from scratch. It will modify the Kubernetes system to allow integration with the PowerFlex CSI plugin and will create persistent volumes for a Cassandra database. Lastly, you can use Rancher to monitor and manage the entire Kubernetes cluster.

## Requirements

This demo assumes the existence of the following:
<br> •	Dell Technologies PowerFlex 3.x, 3.5.x
<br> •	VMware vSphere environment 6.5, 6.7
<br> •	CentOS 7.5, 7.6, 7.7


## Instructions

1.	Download all the files into your local machine
2.	Modify the var.tf file with your vSphere credentials
3.	Modify the main.tf file that reflects your current vSphere environment
4.	The files that you need to modify are below:
<br> a.	‘startup.sh’
<br>   - modify the password of the root user and change the IPs
<br>   - This script is run on the Rancher host so it can communicate with the Kubernetes hosts and execute the Ansible playbook <br>
<br> b. ‘hosts’ 
<br>   - enter the IP addresses of the Kubernetes Master and Worker hosts <br>
<br> c. ‘initial.yml’ 
<br>   - change the user from ‘jono’ to a username of your choice
<br>   - when changing the username, make sure you change other parts of the file as well, eg. “home/jono/” -> “/home/USERNAME/”
<br>   - change the password from ‘jono’ to a password of your choice. <br>
<br> d. ‘copy-ssh.sh’
<br>   - change the password of the root user and change the IPs
<br>   - this is so the Kubernetes Master host can communicate with the Kubernetes Workers hosts <br>
<br> e. ‘jono-copy-ssh.sh’ 
<br>   - change the password of your user and change the IPs
<br>   - when running Kubernetes it is highly recommended that you run as non-root user <br>
<br> f. ‘master.yml’
<br>   - make sure you change all ‘jono’ references to your username 
<br>   - change the directory name as well
<br>   - under the PowerFlex SDC installation section make sure you enter your MDM IPs and verified the binary location <br>
<br> g.	‘csi-vxflex-install.yml’
<br>   - make sure you change all ‘jono’ references to your username. 
<br>   - change the directory name as well
<br>   - when modifying ‘secret.yaml’ you need to change the username and password to base64 <br>To do that run this command: echo -n <USERNAME> | base64 and echo -n <PASSWORD> | base64 and replace the output. <br>
<br>  h. ‘myvalues.yaml’ 
<br>   - replace the existing PowerFlex parameters with your PowerFlex system. <br>

5.	Zip all the files under the /demo/ directory named demo.zip.
6.	Run ‘terraform init’ so it will download the right provider to execute the code.
7.	If you want to test your Terraform code you can run ‘terraform plan’ and if there any errors, it will tell you what you need to do to correct them.
8.	When ready run ‘terraform apply -auto-approve’ and Terraform will build the VMs and upload the demo.zip file to the Rancher host.
9.	Once you have unzipped the demo.zip file, change to the demo folder and run ‘sh startup.sh’.
10.	When that is complete, you can run the ansible playbooks individually or you can combine all the playbooks under one yml file <br>To run all the playbooks, execute the following: ‘ansible-playbook -i hosts deployment.yml’
11.	If the playbook has successfully finished, next step is to log in to the Kubernetes Master host <br>Switch from root to your user <br>Go to the /csi-vxflex/helm/ directory and run ‘./install.vxflex’ 
12.	Once the plugin is installed, next step is to create a Cassandra pod
13.	Execute the following commands on the Kubernetes Master host as your user:
<br>a.	helm repo add incubator https://kubernetes-charts-incubator.storage.googleapis.com/
<br>b.	helm repo update
<br>c.	helm install incubator/cassandra --generate-name <br>
14.	Next you can check the deployment in Kubernetes by running the following command (it will take about 10 minutes for the containers to be spun up on the Worker hosts so be patient)
<br>a.	kubectl get pods -o wide <br>
<br>15.	To check for persistent volumes run the following:
<br>a.	kubectl get pvc <br>
16.	To delete a pod run the following:
<br>a.	kubectl delete pod cassandra-1xxxxxxxx <br>
17.	Check if the container is getting spun up again by running:
<br>a.	kubectl get pods -o wide <br>
18.	When finished with the pod run the following:
<br>a.	helm uninstall cassandra-1xxxxxxxx
<br>b.	This will go ahead and delete the pods but not the pvc so you’ll have to manually delete them <br>This will change with the release of Helm 4 (currently running Helm 3)
<br>c.	To delete the pvc run ‘kubectl delete pvc data-cassandra-1xxxxxxxx’ <br>
19.	When you are finished the demo return to the command prompt and run terraform destroy -auto-approve <br>This will destroy all your VMs but you’ll have to manually remove the SDC’s in the PowerFlex GUI.
