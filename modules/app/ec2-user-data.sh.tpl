#!/bin/bash
sudo yum update -y && yum install -y git
curl -O https://bootstrap.pypa.io/get-pip.py
python3 get-pip.py --user
export TC_DYNAMO_TABLE="${dynamo_table}"
mkdir ~/flask
git clone https://${git_username}:${git_token}@github.com/uturndata/tech-challenge-flask-app.git ~/flask
cd ~/flask
python3 -m pip install -r requirements.txt
gunicorn -b 0.0.0.0 app:candidates_app -w 4 --log-file ~/flask/gunicorn_logs.log