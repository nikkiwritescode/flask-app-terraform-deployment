#!/bin/bash
sudo yum update -y && sudo yum install -y docker
sudo systemctl start docker
sudo usermod -aG docker ec2-user
git clone https://github.com/uturndata/tech-challenge-flask-app.git --depth 1 --branch=main ~/flask
cd flask
docker build .
docker run -dp 8000:80