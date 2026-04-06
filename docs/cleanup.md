# Cleanup 


## 🧹 Cleanup (Optional)

To remove all resources after lab completion:

```bash
# Destroy infrastructure
cd terraform
terraform destroy -auto-approve

# Remove SSH key from IBM Cloud
ibmcloud is key-delete logistics-ssh-key

# Clean local files
rm -f ~/.kube/config
rm -f terraform.tfstate*
```


