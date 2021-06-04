#!/bin/bash
sudo yum update -y && sudo yum install -y docker && sudo yum install -y git && sudo yum install -y python37
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
sudo systemctl start docker
sudo usermod -aG docker ec2-user
export TC_DYNAMO_TABLE="${dynamo_table}"
mkdir ~/flask
git clone https://github.com/uturndata/tech-challenge-flask-app.git ~/flask
${git_username}
${git_token}
cd ~/flask
pip install -r requirements.txt
gunicorn app:candidates_app