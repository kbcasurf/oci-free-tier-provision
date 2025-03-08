#!/bin/bash

# Navigate to network directory and apply Terraform
cd network
terraform init
terraform apply -auto-approve

# Get network outputs and format them
vcn_id=$(terraform output -raw vcn_id | sed 's/ *= */=/g')
subnet_id=$(terraform output -raw subnet_id | sed 's/ *= */=/g')
security_list_id=$(terraform output -raw security_list_id | sed 's/ *= */=/g')

cd ..

# Navigate to compute directory and apply Terraform
cd compute
terraform init
terraform apply -auto-approve

# Get compute outputs and format them
instance_display_name=$(terraform output -raw instance_display_name | sed 's/ *= */=/g')
instance_id=$(terraform output -raw instance_id | sed 's/ *= */=/g')
instance_private_ip=$(terraform output -raw instance_private_ip | sed 's/ *= */=/g')
instance_public_ip=$(terraform output -raw instance_public_ip | sed 's/ *= */=/g')

cd ..

# Create a temporary file
tmp_file=$(mktemp)

# Process the .env file - keep only the manual configurations
while IFS= read -r line || [[ -n "$line" ]]; do
    if [[ ! $line =~ ^(instance_|export TF_VAR_vcn_|export TF_VAR_subnet_|export TF_VAR_security_list_) ]]; then
        echo "$line" >> "$tmp_file"
    fi
done < .env

# Add the new network values with proper format
echo "export TF_VAR_vcn_id=\"${vcn_id#*=}\"" >> "$tmp_file"
echo "export TF_VAR_subnet_id=\"${subnet_id#*=}\"" >> "$tmp_file"
echo "export TF_VAR_security_list_id=\"${security_list_id#*=}\"" >> "$tmp_file"

# Add the new instance values with proper format
echo "export TF_VAR_instance_display_name=\"${instance_display_name#*=}\"" >> "$tmp_file"
echo "export TF_VAR_instance_id=\"${instance_id#*=}\"" >> "$tmp_file"
echo "export TF_VAR_instance_private_ip=\"${instance_private_ip#*=}\"" >> "$tmp_file"
echo "export TF_VAR_instance_public_ip=\"${instance_public_ip#*=}\"" >> "$tmp_file"

# Replace the original file
mv "$tmp_file" .env

# Make sure the file has correct permissions
chmod 600 .env

echo "Deployment complete and environment file updated successfully!"