#!/bin/bash

# Log in to ECR using the AWS CLI and Docker
aws ecr get-login-password --region af-south-1 | docker login --username AWS --password-stdin ${ECR_REPO}

# Build the Docker image
docker build -t kitecam-nginx-rtmp --build-arg RTMP_USER=$RTMP_USER --build-arg RTMP_PASSWORD=$RTMP_PASSWORD --build-arg STREAM_URL=$STREAM_URL .

# Tag the Docker image with the ECR repository and latest tag
docker tag kitecam-rtmp:latest ${ECR_REPO}/kitecam-rtmp:latest

# Push the Docker image to the ECR repository
docker push ${ECR_REPO}/kitecam-rtmp:latest
