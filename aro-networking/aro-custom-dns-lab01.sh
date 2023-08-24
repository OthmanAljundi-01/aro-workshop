
# Public Documentation Link : https://learn.microsoft.com/en-us/azure/openshift/howto-custom-dns

# Define Variables :


	resourceGroup=<ARO-Cluster-RG>
	location="westeurope"
	vmName="ARO-DNS-Server"
	dnsServerName="arodnssrv01"
	vnetName=<ARO-Cluster-VNET-RG>
	subnetName="aro-dns-subnet"
	dnssubnetprefix="10.0.1.0/24"




# Create DNS Subnet :

	az network vnet subnet create --resource-group $resourceGroup --vnet-name $vnetName --name $subnetName --address-prefixes $dnssubnetprefix --service-endpoints Microsoft.ContainerRegistry



# Create VM :

	az vm create \
	  --resource-group $resourceGroup \
	  --name $vmName \
	  --image UbuntuLTS \
	  --admin-username azureuser \
	  --generate-ssh-keys



# Get Network Interface

	nicName=$(az vm show --resource-group $resourceGroup --name $vmName --query 'networkProfile.networkInterfaces[0].id' -o tsv | cut -d"/" -f9)



# Get Private IP Address

	privateIpAddress=$(az network nic ip-config list --nic-name $nicName --resource-group $resourceGroup --query '[].privateIPAddress' -o tsv)


# Install DNS Server in VM :

	az vm run-command invoke \
	  --resource-group $resourceGroup \
	  --name $vmName \
	  --command-id RunShellScript \
	  --scripts \
		"sudo apt-get -y update" \
		"sudo apt-get -y install bind9 bind9utils bind9-doc" \
		"sudo systemctl enable bind9" \
		"sudo systemctl start bind9"




# Configure DNS with A records :

	az vm run-command invoke \
	  --resource-group $resourceGroup \
	  --name $vmName \
	  --command-id RunShellScript \
	  --scripts \
		"sudo apt-get update && sudo apt-get install -y bind9" \
		"echo 'zone \"arodnssrv01.com\" { type master; file \"/etc/bind/db.arodnssrv01\"; };' | sudo tee -a /etc/bind/named.conf.local" \
		"echo '\$TTL 604800
	\$ORIGIN arodnssrv01.com.
	@ IN SOA arodnssrv01. root.arodnssrv01. (
		2         ; Serial
		604800    ; Refresh
		86400     ; Retry
		2419200   ; Expire
		604800 )  ; Negative Cache TTL
	;
	@       IN  NS  arodnssrv01.
	api     IN  A   10.0.0.2' | sudo tee /etc/bind/db.arodnssrv01" \
		"sudo ufw allow 53" \
		"sudo systemctl restart bind9"



	az vm run-command invoke \
	  --resource-group $resourceGroup \
	  --name $vmName \
	  --command-id RunShellScript \
	  --scripts "sudo ufw allow 53/tcp" "sudo ufw allow 53/udp"




# Update VNET to use custom DNS (this VM)
	
	az network vnet update --resource-group $resourceGroup --name $vnetName --dns-servers $privateIpAddress



# gracfully restart the ARO cluster nodes :

	cat << EOF > worker-restarts.yml
	apiVersion: machineconfiguration.openshift.io/v1
	kind: MachineConfig
	metadata:
	  labels:
		machineconfiguration.openshift.io/role: worker
	  name: 25-machineconfig-worker-reboot
	spec:
	  config:
		ignition:
		  version: 2.2.0
		storage:
		  files:
		  - contents:
			  source: data:text/plain;charset=utf-8;base64,cmVzdGFydAo=
			filesystem: root
			mode: 0644
			path: /etc/mco-noop-worker-restart.txt
	EOF

	oc apply -f worker-restarts.yml



	cat << EOF > master-restarts.yml
	apiVersion: machineconfiguration.openshift.io/v1
	kind: MachineConfig
	metadata:
	  labels:
		machineconfiguration.openshift.io/role: master
	  name: 25-machineconfig-master-reboot
	spec:
	  config:
		ignition:
		  version: 2.2.0
		storage:
		  files:
		  - contents:
			  source: data:text/plain;charset=utf-8;base64,cmVzdGFydAo=
			filesystem: root
			mode: 0644
			path: /etc/mco-master-noop-restart.txt
	EOF

	oc apply -f master-restarts.yml




# Check DNS Resolution from inside one of the worker nodes :

	oc debug node/<node-name> -- chroot /host nslookup api.arodnssrv01.com





