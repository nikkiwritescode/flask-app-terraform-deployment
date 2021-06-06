# Terraform Flask Project

## Description
This is a Terraform deployment for a small Flask app. It runs on port 8000 on the instances themselves but is served on port 80 through the load balancer. The application is pulled from a private repository, so a github account with permissions to access the repository is needed to use this code.

## Configuration
Clone this repository into a directory of your choice, then create a file in the root of the directory called `terraform.tfvars`. Use the following as a template for this file -- the only required change is to supply your public IP in the `my_ip` field, so you can SSH into your instances:

```
#-------------------------#
# User-Specific Variables #
#-------------------------#
my_ip                  = "1.234.56.78/32"
my_public_key_location = "~/.ssh/id_rsa.pub"

#-------------------------------# 
# General Application Variables #
#-------------------------------# 
app_name   = "demo_flask_app"
env_prefix = "dev"

#---------------------------------#
# Network Configuration Variables #
#---------------------------------#
subnet_cidr_block_1 = "10.0.10.0/24"
subnet_cidr_block_2 = "10.0.20.0/24"
vpc_cidr_block      = "10.0.0.0/16"

#--------------------------------#
# Server Configuration Variables #
#--------------------------------#
avail_zone_1  = "us-east-2a"
avail_zone_2  = "us-east-2b"
instance_type = "t4g.nano"
```

## Deployment
Once this file has been populated, click Save. Go to your terminal and type `terraform init`. Once completed, type `terraform apply`. Now, you should see a preview of infrastructure to be created. If you like what you see, type yes when prompted to confirm. Once the deployment completes, you should see an output labeled `elb_public_dns`. Use this value in the next step to test your API.

## Testing
You can use [Insomnia](https://insomnia.rest/) to test the resulting Flask app. 

[ TODO: Finish this section of the readme! ]

## Routes
`[GET] /gtg`
Simple healthcheck - returns HTTP 200 OK if everything is working and nothing else.

`[GET] /gtg?details`
Advanced healthcheck - returns HTTP 200 OK if everything is working along with some service details in JSON format.

`[POST] /candidate/str:name`
Adds a new string (candidate name) to a list, returns HTTP 200 OK if working, along with data in JSON format. Optional parameter `?party=` will assign to a political party. `empty/unsupplied` or `ind`: none/independent (default); `dem`: democratic; `rep`: republican. This will error if supplied with something other than the these three parameters.

`[GET] /candidate/str:name`
Gets candidate name from the list, returns HTTP 200 OK and data in JSON format.

`[GET] /candidates`
Gets list of all candidates from a list, returns HTTP 200 OK and data in JSON format.