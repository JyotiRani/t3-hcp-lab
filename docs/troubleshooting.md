# Troubleshooting Guide

Common issues and solutions for the Logistics Application labs.

## Table of Contents

- [Lab 1: Infrastructure and Deployment Issues](#lab-1-infrastructure-and-deployment-issues)
- [Lab 2: Observability Issues](#lab-2-observability-issues)
- [Lab 3: Integration Issues](#lab-3-integration-issues)
- [General Issues](#general-issues)
- [Debug Commands](#debug-commands)

---

## Lab 1: Infrastructure and Deployment Issues

### Terraform Issues

#### Issue: "Error: No valid credential sources found"

**Symptoms:**
```
Error: No valid credential sources found for IBM Cloud Provider
```

**Solution:**
```bash
# Set IBM Cloud API key
export IBMCLOUD_API_KEY="your-api-key"

# Or add to terraform.tfvars
echo 'ibmcloud_api_key = "your-api-key"' >> terraform.tfvars

# Verify
terraform plan
```

---

#### Issue: "Error: VPC not found"

**Symptoms:**
```
Error: VPC with name 'logistics-vpc' not found
```

**Solution:**
```bash
# List existing VPCs
ibmcloud is vpcs

# If VPC exists with different name, update terraform.tfvars
# If VPC doesn't exist, ensure Terraform creates it
terraform apply -target=ibm_is_vpc.logistics_vpc
```

---

#### Issue: "Error: Insufficient quota"

**Symptoms:**
```
Error: Quota exceeded for resource type 'floating_ip'
```

**Solution:**
```bash
# Check current quotas
ibmcloud is quotas

# Request quota increase or clean up unused resources
ibmcloud is floating-ips
ibmcloud is floating-ip-delete <floating-ip-id>
```

---

#### Issue: Terraform state lock

**Symptoms:**
```
Error: Error acquiring the state lock
```

**Solution:**
```bash
# Force unlock (use with caution)
terraform force-unlock <lock-id>

# Or remove local state lock
rm -f .terraform.tfstate.lock.info
```

---

### K3s Installation Issues

#### Issue: K3s installation fails

**Symptoms:**
```
TASK [Install K3s] *****
fatal: [vsi]: FAILED! => {"msg": "Connection timed out"}
```

**Solution:**
```bash
# Verify SSH connectivity
ssh -i ~/.ssh/logistics-key root@<vsi-ip>

# Check security group rules
ibmcloud is security-group-rules <sg-id>

# Ensure port 22 is open
ibmcloud is security-group-rule-add <sg-id> inbound tcp --port-min 22 --port-max 22

# Retry Ansible playbook
ansible-playbook -i inventory ansible/k3s-install.yml
```

---

#### Issue: K3s service not starting

**Symptoms:**
```
● k3s.service - Lightweight Kubernetes
   Loaded: loaded
   Active: failed
```

**Solution:**
```bash
# SSH to VSI
ssh -i ~/.ssh/logistics-key root@<vsi-ip>

# Check K3s logs
journalctl -u k3s -n 100

# Common fix: Restart with clean state
systemctl stop k3s
rm -rf /var/lib/rancher/k3s/server/db
systemctl start k3s

# Verify
systemctl status k3s
```

---

#### Issue: kubectl cannot connect

**Symptoms:**
```
The connection to the server localhost:8080 was refused
```

**Solution:**
```bash
# Copy kubeconfig from VSI
scp -i ~/.ssh/logistics-key root@<vsi-ip>:/etc/rancher/k3s/k3s.yaml ~/.kube/config

# Update server address in kubeconfig
sed -i 's/127.0.0.1/<vsi-public-ip>/g' ~/.kube/config

# Verify
kubectl get nodes
```

---

### Application Deployment Issues

#### Issue: Pods stuck in "ImagePullBackOff"

**Symptoms:**
```
NAME                    READY   STATUS             RESTARTS   AGE
auth-service-xxx        0/1     ImagePullBackOff   0          5m
```

**Solution:**
```bash
# Check pod events
kubectl describe pod auth-service-xxx -n logistics

# Common causes:
# 1. Image doesn't exist
kubectl get pod auth-service-xxx -n logistics -o jsonpath='{.spec.containers[0].image}'

# 2. Registry authentication (if private)
kubectl create secret docker-registry regcred \
  --docker-server=<registry> \
  --docker-username=<username> \
  --docker-password=<password> \
  -n logistics

# Update deployment to use secret
kubectl patch deployment auth-service -n logistics \
  -p '{"spec":{"template":{"spec":{"imagePullSecrets":[{"name":"regcred"}]}}}}'
```

---

#### Issue: Pods in "CrashLoopBackOff"

**Symptoms:**
```
NAME                    READY   STATUS             RESTARTS   AGE
order-service-xxx       0/1     CrashLoopBackOff   5          10m
```

**Solution:**
```bash
# Check pod logs
kubectl logs order-service-xxx -n logistics

# Common causes:
# 1. Database connection failure
kubectl get secret logistics-secrets -n logistics -o jsonpath='{.data.DATABASE_URL}' | base64 -d

# 2. Missing environment variables
kubectl describe pod order-service-xxx -n logistics | grep -A 10 "Environment:"

# 3. Application error
kubectl logs order-service-xxx -n logistics --previous

# Fix: Update ConfigMap or Secret
kubectl edit configmap logistics-config -n logistics
kubectl edit secret logistics-secrets -n logistics

# Restart pods
kubectl rollout restart deployment order-service -n logistics
```

---

#### Issue: Database connection refused

**Symptoms:**
```
psycopg2.OperationalError: could not connect to server: Connection refused
```

**Solution:**
```bash
# Check PostgreSQL pod
kubectl get pods -n logistics | grep postgres

# Check PostgreSQL logs
kubectl logs postgres-xxx -n logistics

# Verify service
kubectl get svc postgres-service -n logistics

# Test connection from another pod
kubectl run -it --rm debug --image=postgres:15 --restart=Never -n logistics -- \
  psql -h postgres-service -U logistics_user -d logistics_db

# If PostgreSQL pod is not running, check PVC
kubectl get pvc -n logistics
```

---

#### Issue: Services not accessible

**Symptoms:**
```
curl: (7) Failed to connect to frontend-service port 8000: Connection refused
```

**Solution:**
```bash
# Check service endpoints
kubectl get endpoints -n logistics

# Check if pods are ready
kubectl get pods -n logistics

# Port forward for testing
kubectl port-forward svc/frontend-service 8000:8000 -n logistics

# Access via browser: http://localhost:8000

# For external access, check NodePort or LoadBalancer
kubectl get svc -n logistics
```

---

### Instana Agent Issues

#### Issue: Instana agent not reporting

**Symptoms:**
- No data in Instana UI
- Agent pod running but no metrics

**Solution:**
```bash
# Check agent pod logs
kubectl logs -n instana-agent -l app.kubernetes.io/name=instana-agent

# Verify agent key
kubectl get secret instana-agent -n instana-agent -o jsonpath='{.data.key}' | base64 -d

# Check agent configuration
kubectl get configmap instana-agent -n instana-agent -o yaml

# Restart agent
kubectl rollout restart daemonset instana-agent -n instana-agent

# Verify connectivity to Instana backend
kubectl exec -it -n instana-agent <agent-pod> -- curl -v https://<tenant>.instana.io
```

---

## Lab 2: Observability Issues

### Instana UI Issues

#### Issue: Application Perspective not showing services

**Symptoms:**
- Empty Application Perspective
- Services not appearing in map

**Solution:**
1. Wait 2-3 minutes for data collection
2. Verify agent is running:
   ```bash
   kubectl get pods -n instana-agent
   ```
3. Check service labels match Application Perspective filters
4. Verify services are receiving traffic:
   ```bash
   kubectl top pods -n logistics
   ```
5. Generate traffic:
   ```bash
   # Create test orders
   curl -X POST http://<vsi-ip>:8000/api/orders \
     -H "Authorization: Bearer <token>" \
     -d '{"items": ["item1"], "total": 100}'
   ```

---

#### Issue: AI agent traces not visible

**Symptoms:**
- No AI agent activity in Instana
- Missing LangFlow traces

**Solution:**
```bash
# Check AI agent logs
kubectl logs -n logistics -l app=ai-agent-service

# Verify AI agent is making requests
kubectl exec -it -n logistics <ai-agent-pod> -- curl http://shipment-service:8003/shipments

# Check Instana agent configuration for Python tracing
kubectl get configmap instana-agent -n instana-agent -o yaml | grep -A 5 python

# Ensure AI agent has Instana SDK
kubectl exec -it -n logistics <ai-agent-pod> -- pip list | grep instana
```

---

#### Issue: High latency not showing in analytics

**Symptoms:**
- Known slow requests not appearing in analytics
- Latency metrics seem incorrect

**Solution:**
1. Verify time range in Instana UI
2. Check if services are instrumented:
   ```bash
   kubectl logs -n instana-agent <agent-pod> | grep "Monitoring"
   ```
3. Generate consistent load:
   ```bash
   # Use load testing tool
   for i in {1..100}; do
     curl http://<vsi-ip>:8000/api/orders
     sleep 1
   done
   ```
4. Wait 5-10 minutes for analytics aggregation

---

## Lab 3: Integration Issues

### webMethods Issues

#### Issue: Cannot access webMethods tenant

**Symptoms:**
```
Connection refused to webmethods.io
```

**Solution:**
1. Verify tenant URL is correct
2. Check credentials:
   ```bash
   echo $WEBMETHODS_USERNAME
   echo $WEBMETHODS_URL
   ```
3. Test connectivity:
   ```bash
   curl -v https://<tenant>.webmethods.io
   ```
4. Ensure trial is still active

---

#### Issue: Workflow execution fails

**Symptoms:**
- Workflow shows error status
- API returns 500 error

**Solution:**
1. Check workflow logs in webMethods UI
2. Verify input schema matches expected format
3. Test with minimal payload:
   ```bash
   curl -X POST https://<tenant>.webmethods.io/api/workflow \
     -H "Content-Type: application/json" \
     -d '{"test": "data"}'
   ```
4. Check for missing required fields

---

#### Issue: AI agent cannot call webMethods API

**Symptoms:**
```
ConnectionError: Failed to establish connection to webMethods
```

**Solution:**
```bash
# Check AI agent can reach webMethods
kubectl exec -it -n logistics <ai-agent-pod> -- \
  curl -v https://<tenant>.webmethods.io/api/workflow

# Verify API credentials in AI agent config
kubectl get configmap ai-agent-config -n logistics -o yaml

# Check for network policies blocking egress
kubectl get networkpolicies -n logistics

# Test with direct curl from VSI
ssh -i ~/.ssh/logistics-key root@<vsi-ip>
curl https://<tenant>.webmethods.io/api/workflow
```

---

### API Testing Issues

#### Issue: Postman collection import fails

**Symptoms:**
- Invalid collection format
- Missing environment variables

**Solution:**
1. Verify collection file is valid JSON
2. Import environment separately
3. Update variables:
   - `base_url`: http://<vsi-ip>:8000
   - `api_key`: your-api-key
   - `token`: (obtain from login)

---

## General Issues

### Network Connectivity

#### Issue: Cannot SSH to VSI

**Symptoms:**
```
ssh: connect to host <ip> port 22: Connection timed out
```

**Solution:**
```bash
# Check VSI status
ibmcloud is instances

# Verify security group rules
ibmcloud is security-group-rules <sg-id>

# Add SSH rule if missing
ibmcloud is security-group-rule-add <sg-id> inbound tcp \
  --port-min 22 --port-max 22 --remote 0.0.0.0/0

# Check floating IP
ibmcloud is floating-ips

# Verify SSH key
ssh-keygen -l -f ~/.ssh/logistics-key.pub
```

---

### Resource Constraints

#### Issue: Pods evicted due to memory pressure

**Symptoms:**
```
NAME                    READY   STATUS    RESTARTS   AGE
order-service-xxx       0/1     Evicted   0          1h
```

**Solution:**
```bash
# Check node resources
kubectl top nodes

# Check pod resource usage
kubectl top pods -n logistics

# Increase VSI size or reduce pod resource requests
# Edit deployment:
kubectl edit deployment order-service -n logistics

# Reduce replicas temporarily
kubectl scale deployment order-service --replicas=0 -n logistics
kubectl scale deployment order-service --replicas=1 -n logistics
```

---

### Authentication Issues

#### Issue: JWT token expired

**Symptoms:**
```
{"detail": "Token has expired"}
```

**Solution:**
```bash
# Get new token
curl -X POST http://<vsi-ip>:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username": "admin", "password": "password"}'

# Use refresh token
curl -X POST http://<vsi-ip>:8000/api/auth/refresh \
  -H "Authorization: Bearer <refresh-token>"
```

---

## Debug Commands

### Kubernetes Debugging

```bash
# Get all resources in namespace
kubectl get all -n logistics

# Describe resource for events
kubectl describe pod <pod-name> -n logistics

# Get logs
kubectl logs <pod-name> -n logistics
kubectl logs <pod-name> -n logistics --previous  # Previous container

# Follow logs
kubectl logs -f <pod-name> -n logistics

# Execute command in pod
kubectl exec -it <pod-name> -n logistics -- /bin/bash

# Port forward
kubectl port-forward <pod-name> 8080:8080 -n logistics

# Get pod YAML
kubectl get pod <pod-name> -n logistics -o yaml

# Check resource usage
kubectl top pods -n logistics
kubectl top nodes

# Get events
kubectl get events -n logistics --sort-by='.lastTimestamp'
```

---

### Network Debugging

```bash
# Test DNS resolution
kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup auth-service.logistics.svc.cluster.local

# Test service connectivity
kubectl run -it --rm debug --image=curlimages/curl --restart=Never -- \
  curl http://auth-service.logistics.svc.cluster.local:8001/health

# Check network policies
kubectl get networkpolicies -n logistics

# Describe service
kubectl describe svc auth-service -n logistics
```

---

### Database Debugging

```bash
# Connect to PostgreSQL
kubectl exec -it <postgres-pod> -n logistics -- \
  psql -U logistics_user -d logistics_db

# Check tables
\dt

# Check connections
SELECT * FROM pg_stat_activity;

# Check database size
SELECT pg_size_pretty(pg_database_size('logistics_db'));
```

---

### Instana Debugging

```bash
# Check agent status
kubectl get pods -n instana-agent

# View agent logs
kubectl logs -n instana-agent -l app.kubernetes.io/name=instana-agent

# Check agent configuration
kubectl get configmap instana-agent -n instana-agent -o yaml

# Verify agent key
kubectl get secret instana-agent -n instana-agent -o jsonpath='{.data.key}' | base64 -d

# Test connectivity
kubectl exec -it -n instana-agent <agent-pod> -- \
  curl -v https://<tenant>.instana.io
```

---

### Application Debugging

```bash
# Check application logs
kubectl logs -n logistics <pod-name>

# Check environment variables
kubectl exec -it -n logistics <pod-name> -- env

# Test health endpoint
kubectl exec -it -n logistics <pod-name> -- \
  curl http://localhost:8001/health

# Check database connectivity
kubectl exec -it -n logistics <pod-name> -- \
  python -c "import psycopg2; conn = psycopg2.connect('$DATABASE_URL'); print('Connected')"
```

---

## Getting Help

If issues persist:

1. **Check logs systematically:**
   - Application logs
   - Kubernetes events
   - Instana agent logs
   - System logs on VSI

2. **Verify prerequisites:**
   - All tools installed
   - Credentials configured
   - Network connectivity

3. **Review documentation:**
   - [Prerequisites](./prerequisites.md)
   - [Architecture](./architecture.md)
   - Lab-specific READMEs

4. **Clean slate approach:**
   ```bash
   # Destroy and recreate
   terraform destroy -auto-approve
   terraform apply -auto-approve
   ```

5. **Collect diagnostic information:**
   ```bash
   # Create diagnostic bundle
   kubectl cluster-info dump -n logistics > cluster-dump.txt
   kubectl get all -n logistics -o yaml > logistics-resources.yaml
   kubectl logs -n logistics --all-containers=true > app-logs.txt
   ```

---

## Prevention Tips

1. **Always validate before proceeding:**
   - Run health checks after each step
   - Verify resources are created
   - Test connectivity

2. **Use version control:**
   - Commit working configurations
   - Tag stable versions

3. **Monitor resources:**
   - Set up alerts for resource usage
   - Regular cleanup of unused resources

4. **Document changes:**
   - Keep notes of modifications
   - Track configuration changes

5. **Test in isolation:**
   - Test components individually
   - Validate before integration

---


## 🔍 Troubleshooting

### Issue: Terraform fails to provision

**Check:**
```bash
# Verify API key
echo $IBMCLOUD_API_KEY

# Check IBM Cloud CLI
ibmcloud login --apikey $IBMCLOUD_API_KEY

# Review Terraform logs
terraform apply -debug
```

### Issue: K3s installation fails

**Check:**
```bash
# SSH to VSI
ssh -i ~/.ssh/logistics-key root@<vsi-ip>

# Check K3s service
systemctl status k3s

# View logs
journalctl -u k3s -n 100
```

### Issue: Pods not starting

**Check:**
```bash
# Describe pod
kubectl describe pod <pod-name> -n logistics

# Check events
kubectl get events -n logistics --sort-by='.lastTimestamp'

# View logs
kubectl logs <pod-name> -n logistics
```

For more troubleshooting, see [Troubleshooting Guide](../docs/troubleshooting.md).

---

## 🔍 Troubleshooting for Lab 2

### Agent Not Reporting Data
```bash
# Check agent pod status
kubectl get pods -n instana-agent

# View agent logs for errors
kubectl logs -n instana-agent -l app.kubernetes.io/name=instana-agent --tail=200

# Verify agent configuration
kubectl get configmap -n instana-agent instana-agent -o yaml
```

### Services Not Appearing in Instana
- Verify application pods are running: `kubectl get pods -n logistics-app`
- Check if services have proper labels
- Ensure network connectivity between agent and services
- Wait 2-3 minutes for discovery to complete

### Missing Traces
- Verify trace context propagation in application code
- Check if services are instrumented correctly
- Review Instana agent configuration for trace collection
- Ensure sampling rate is appropriate

### AI Agent Not Monitored
- Verify LangFlow service is running
- Check if watsonx.ai API calls are being made
- Review custom instrumentation for AI agent
- Ensure proper tagging for AI components

---


## 🆘 Troubleshooting Lab2

### Agent Not Reporting

```bash
# Check agent status
kubectl get pods -n instana-agent

# View logs
kubectl logs -n instana-agent -l app.kubernetes.io/name=instana-agent --tail=200

# Restart agent if needed
kubectl rollout restart daemonset/instana-agent -n instana-agent
```

### Services Not Appearing

```bash
# Verify pods are running
kubectl get pods -n logistics-app

# Check service labels
kubectl get svc -n logistics-app --show-labels

# Wait 2-3 minutes for discovery
```

### No Traces Captured

- Verify traffic was generated successfully
- Check if services are instrumented
- Review Instana agent configuration
- Ensure sampling rate is appropriate

### AI Agent Not Visible

- Verify LangFlow service is running
- Check if delay simulation API works
- Review custom instrumentation
- Ensure proper tagging for AI components
