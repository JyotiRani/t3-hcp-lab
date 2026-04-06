# Terraform Variables for SSH Key Creation (Step 1)
# Copy this file to terraform.tfvars and fill in your values

# IBM Cloud Configuration
ibmcloud_api_key    = "##IBM_CLOUD_API_KEY##"
region              = "us-south"
resource_group_name = "apac-ce-t3-26"

# SSH Key Configuration
ssh_key_name   = "##SSH_KEY_NAME##"
ssh_public_key = "##SSH_PUBLIC_KEY##"


# Tags
tags = ["t3-lab-ssh-##LAB_USER_ID##"]