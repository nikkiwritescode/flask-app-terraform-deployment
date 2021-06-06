# Terraform Flask Project

## About
This is a Terraform deployment for a small Flask app. It runs on port 8000 on the instances themselves but is served on port 80 through the load balancer. The application is preloaded onto an AMI, so no additional configuration is needed to load it.

## Configuration
Clone this repository into a directory of your choice, then create a file in the root of the directory called `terraform.tfvars`. Use the following as a template for this file -- the only required change is to supply your public IP in the `my_ip` field, so you can SSH into your instances:

```
#--------------------------#
#      User Variables      #
#--------------------------#
my_ip                  = "1.234.56.78/32"
my_public_key_location = "~/.ssh/id_rsa.pub"

#-------------------------------#
# General Application Variables #
#-------------------------------#
app_name   = "demo_flask_app"
env_prefix = "dev"

#--------------------------------#
#     Auto-Scaling Variables     #
#--------------------------------#
asg_desired_capacity = 2
asg_max_size         = 2
asg_min_size         = 2

#--------------------------------#
# Server Configuration Variables #
#--------------------------------#
avail_zones   = ["us-east-2a", "us-east-2b", "us-east-2c"]
ami_id        = "ami-0f9c27d16302904d1"
instance_type = "t4g.nano"

#---------------------------------#
# Network Configuration Variables #
#---------------------------------#
subnet_cidr_blocks = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
vpc_cidr_block     = "10.0.0.0/16"
```

## Deployment
Once this file has been populated, click Save. Open your Terminal to your project folder and type `terraform init`. Once that has completed, type `terraform apply`. Now, you should see a preview of infrastructure to be created. If you like what you see, type `yes` when prompted to confirm. Once the deployment completes, you should see an output labeled `application_endpoint`. Use this value in the next step to test your API.

## Testing
You can use [Insomnia](https://insomnia.rest/) to test the resulting Flask app. When you first open Insomnia, you'll see a splash screen that prompts you to "Import an OpenAPI spec to get started." Click Skip, then click Create > New Request Collection. You can name this Collection anything you'd like, but I recommend calling it something like `Flask API Testing.` Click New Request, and name that request anything you would like. The resulting screen should look like this:

![BlankInsomniaWindow](https://i.imgur.com/pKTZX7F.png)

Type the `application_endpoint` that Terraform showed once it completed the `apply` command into the field in the top-center of the window above the Body/Auth/Query/Header/Docs tabs are. Add `/` followed by the Route you would like to test, as listed below. So for example, your full path may look something like this: `app-lb-36342133.us-east-2.elb.amazonaws.com/gtg?details`. Please note that your application endpoint will different from mine, as that value is unique to your infrastructure. These examples are only given to illustrate the proper format these values should be in.

## Routes
`[GET] /gtg`
Simple health check - returns HTTP 200 OK if everything is working and nothing else.

`[GET] /gtg?details`
Advanced health check - returns HTTP 200 OK if everything is working along with some service details in JSON format.

`[POST] /candidate/<name>?party=<party>`
Adds a new string (candidate name) to a list, returns HTTP 200 OK if working, along with data in JSON format. Optional parameter `?party=` will assign to a political party. `empty/unsupplied` or `ind`: none/independent (default); `dem`: democratic; `rep`: republican. This will error if supplied with something other than the these three parameters.

`[GET] /candidate/<name>`
Gets candidate name from the list, returns HTTP 200 OK and data in JSON format.

`[GET] /candidates`
Gets list of all candidates from a list, returns HTTP 200 OK and data in JSON format.