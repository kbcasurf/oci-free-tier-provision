#!/bin/bash

# Navigate to network directory and apply Terraform
source .env
terraform init
terraform apply -auto-approve

# Get network outputs and format them
public_subnet_id=$(terraform output -raw public_subnet_id | sed 's/ *= */=/g')
security_list_id=$(terraform output -raw security_list_id | sed 's/ *= */=/g')
availability_domain_name=$(terraform output -raw availability_domain_name | sed 's/ *= */=/g')

# Create a temporary file
tmp_file=$(mktemp)

# Process the .env file - keep only the manual configurations
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ ! $line =~ ^(instance_|export TF_VAR_availability_domain_name|export TF_VAR_vcn_public_subnet|export TF_VAR_security_list_id) ]]; then
        echo "$line" >> "$tmp_file"
    fi
done < .env

# Add the new network values with proper format
echo "export TF_VAR_vcn_public_subnet=\"${public_subnet_id#*=}\"" >> "$tmp_file"
echo "export TF_VAR_security_list_id=\"${security_list_id#*=}\"" >> "$tmp_file"
echo "export TF_VAR_availability_domain_name=\"${availability_domain_name#*=}\"" >> "$tmp_file"

# Replace the original file
mv "$tmp_file" .env

# Make sure the file has correct permissions
chmod 600 .env

echo "Deployment complete and environment file updated successfully!"