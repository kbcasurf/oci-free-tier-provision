#!/bin/bash

# Load .env variables and apply Terraform
source .env
terraform init
terraform apply -auto-approve

# Get vmoutputs and format them
instance_display_name=$(terraform output -raw instance_display_name | sed 's/ *= */=/g')
instance_id=$(terraform output -raw instance_id | sed 's/ *= */=/g')
instance_private_ip=$(terraform output -raw instance_private_ip | sed 's/ *= */=/g')
instance_public_ip=$(terraform output -raw instance_public_ip | sed 's/ *= */=/g')

# Create a temporary file
tmp_file=$(mktemp)

# Process the .env file - keep only the manual configurations
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ ! $line =~ ^(instance_|export TF_VAR_instance_public_ip|export TF_VAR_instance_private_ip|export TF_VAR_instance_display_name|export TF_VAR_instance_id) ]]; then
        echo "$line" >> "$tmp_file"
    fi
done < .env

# Add the new vm values with proper format
echo "export TF_VAR_instance_display_name=\"${instance_display_name#*=}\"" >> "$tmp_file"
echo "export TF_VAR_instance_id=\"${instance_id#*=}\"" >> "$tmp_file"
echo "export TF_VAR_instance_private_ip=\"${instance_private_ip#*=}\"" >> "$tmp_file"
echo "export TF_VAR_instance_public_ip=\"${instance_public_ip#*=}\"" >> "$tmp_file"

# Replace the original file
mv "$tmp_file" .env

# Make sure the file has correct permissions
chmod 600 .env

echo "Deployment complete and environment file updated successfully!"