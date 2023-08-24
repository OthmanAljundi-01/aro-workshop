This directory contains different setup for Quota/Limits that can be applied on the namespace level along with deployments that will trigger this quota/limits 




In OpenShift (and Kubernetes in general), `ResourceQuota` objects can be used to set limits on a variety of resources. Below are some of the primary resources you can set quotas and limits on:

1. Compute Resources:
   - pods: Total count of pods in the namespace.
   - requests.cpu: Total CPU request across all pods.
   - limits.cpu: Total CPU limits across all pods.
   - requests.memory: Total memory request across all pods.
   - limits.memory: Total memory limits across all pods.

2. Storage Resources:
   - persistentvolumeclaims (PVCs): Count of PVCs.
   - requests.storage: Combined storage request across all PVCs.
   - persistentvolumeclaim.size: Allows you to restrict the size of PVC's based on storage class.

3. Object Count Quotas:
   - configmaps: Count of ConfigMaps.
   - services: Count of services.
   - secrets: Count of secrets.
   - service.loadbalancers: Count of load balancer services.
   - services.nodeports: Count of node port services.

4. Network Resources (specific to some network plugins):
   - services.loadbalancers: Count of load-balanced services.
   - services.nodeports: Count of services using node ports.

5. Project Quotas:
   - count/projects: Maximum number of projects a user can create.

6. Other Resources:
   - count/deployments.apps: Count of deployments.
   - count/replicasets.apps: Count of replica sets.
   - count/statefulsets.apps: Count of stateful sets.
   - count/daemonsets.apps: Count of daemon sets.
   - count/jobs.batch: Count of batch jobs.
   - count/cronjobs.batch: Count of cron jobs.
   - count/persistentvolumeclaims: Count of persistent volume claims.
   - count/ingresses.extensions: Count of ingresses.

7. OpenShift-Specific Resources:
   - count/buildconfigs.build.openshift.io: Count of build configurations.
   - count/builds.build.openshift.io: Count of builds.
   - count/deploymentconfigs.apps.openshift.io: Count of deployment configurations.
   - count/imagestreams.image.openshift.io: Count of image streams.
   - count/images.image.openshift.io: Count of images.
   - count/routes.route.openshift.io: Count of routes.

8. API Request Rate Limits (not traditionally part of ResourceQuota, but another form of limiting resources):
   - You can set limits on the rate at which API requests are made.
