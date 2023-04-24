#!/bin/bash


# Create a policy that allows access to your ECR repository, assign it to a Role
# Apply that Role to the EC2 instance 

# Authenticate with AWS ECR and pull the nginx-rtmp image
aws ecr get-login-password --region af-south-1 | docker login --username AWS --password-stdin 215371600831.dkr.ecr.af-south-1.amazonaws.com
docker image pull 215371600831.dkr.ecr.af-south-1.amazonaws.com/nginx-rtmp:latest

