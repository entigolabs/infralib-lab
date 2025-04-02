#!/bin/bash

# Source user's AWS credentials file
if [ -f "$HOME/aws-credentials" ]; then
    source "$HOME/aws-credentials"
    echo "AWS credentials loaded successfully."

# Set environment variables
export AWS_ACCOUNT=$AWS_ACCOUNT
export AWS_REGION=$AWS_REGION
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY
export AWS_ROUTE53_PARENT_ZONE=$AWS_ROUTE53_PARENT_ZONE
# Print welcome text
echo "========================================"
echo "Welcome to the server, $USER!"
echo "Log into the AWS console at https://$AWS_ACCOUNT.signin.aws.amazon.com/console using the same credentials as for the SSH to this server."
echo "The following env variables are already set for you!"
echo "AWS_ACCOUNT=$AWS_ACCOUNT"
echo "AWS_REGION=$AWS_REGION"
echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"
echo "AWS_ROUTE53_PARENT_ZONE=$AWS_ROUTE53_PARENT_ZONE"
echo "Follow the guide at https://infralib-quickstart.dev.entigo.dev/1"
echo "========================================"
else
    echo "AWS credentials file not found at $HOME/aws-credentials"
fi

