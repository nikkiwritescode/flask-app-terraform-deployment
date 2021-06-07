# Terraform Deployment Project

## About

[![Build Status](https://travis-ci.com/nikkiwritescode/flask-app-terraform-deployment.svg?token=HxJqzgGvydWVotX8yscS&branch=main)](https://travis-ci.com/nikkiwritescode/flask-app-terraform-deployment)

This is a Terraform deployment for a small Flask app. It runs on port 8000 on the instances themselves but is served on port 80 through the load balancer. The application is preloaded onto an AMI, so no additional configuration is needed to load it. It supports up to three subnets and as many instances in a spread placement group across those subnets as you would like. The traffic is also load balanced across those instances, so it is a self-healing, highly-available infrastructure.

## CI/CD with Travis CI
This project comes equipped with a **.travis.yml** file, which allows it to plug into a Travis CI pipeline with minimal effort. To set this up, first ensure your Travis CI account is linked with your GitHub account and can read the repository with the code. If you do not want to grant Travis CI permission to see all your repositories, you can grant it permission to see only this one. Perform that initial configuration as you see fit, then see the next step to begin setting the environment variables.

### Reviewing or editing the initial configuration
The **.travis.yml** file contains the initial configuration for the application and other important values. At the bottom of the file, under `env: global:` live the variables for this application's configuration. Most notably, the `asg` variables are all set to 2, so two instances are being spun up. Accordingly, if you change these values to 3, three instances would be built instead. At the top of the file, under `jobs: include:` you can see the stages of `terraform plan` and `terraform apply`. These tell Travis CI how to validate and deploy our application to AWS, and as such, this is where you would make edits if you'd like to change the behavior of the pipeline.

### Setting environment variables
Once your Travis CI and GitHub accounts have been linked, click back over to Travis CI and find the associated listing for your repository. Click the **Settings button** to the right of it, then click the **Settings tab** and scroll down to **Environment Variables**. You will need to enter credentials for an AWS user that has, at a minimum, permissions to *create, modify, and destroy* **VPCs**, **subnets**, **route tables**, **instances**, and **autoscaling groups**. The user will also need *read* permission to the **S3 bucket** we'll be creating in the next step. These environment variables will need to be `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

### Creating an S3 bucket for the Terraform state file
Once the Environment Variables have been set, we will need to create an S3 bucket to store our Terraform state file. This state file handles the current state of the infrastructure -- whether it is built, or destroyed, or in some halfway state of existence. By having this file in an S3 bucket, we can ensure that no matter where our Terraform commands are being run, we will read and update the same state. Create this bucket in the same region as the application: `us-east-2` is the default region for this deployment. You can name this bucket anything you would like, but remember the name as we will need to plug it into our program in a moment. I recommend that you block all public access to this bucket and enable versioning on files inside the bucket. However, enabling versioning will increase the cost and thus the number of files in the bucket. So if you enable versioning, I highly recommend that you also enable an [S3 lifecycle rule](https://docs.aws.amazon.com/AmazonS3/latest/userguide/object-lifecycle-mgmt.html) to remove the old versions of the file after a specified time period -- for example, six months.

### Updating the application backend to point to the S3 bucket
When this has been sorted, it is time to plug the information into our app. At the top of **main.tf** in the root of this project, enter your Bucket name from above. This will complete your configuration for Travis CI; now, when a Pull Request is created, `terraform init` and `terraform plan` are run. And when that Pull Request is merged into the main branch, `terraform apply` will be run as well. (Please note that direct commits to the `main` branch will also cause `terraform apply` to be run. If you do not want this behavior, it can be removed from the .travis.yml file easily.) For each build in Travis CI, a log is created that, at the very bottom, will have your `application_endpoint`. When the build has successfully completed, find and remember this endpoint for use in the [Testing](#testing) module below.

Because the state file is stored in S3, you can run `terraform apply`, `terraform destroy`, or any other state-changing command locally and Terraform will know how to lead your infrastructure to your desired state.

## Manual Deployment
If you would prefer not to set up a CI/CD pipeline, you can work with Terraform manually as well. But I do not recommend this for anything more than simple testing.

### Local configuration
Create a file in the root of the directory called **terraform.tfvars**. Use the following as a template for this file -- no changes should be required, but you are welcome to change anything as you see fit. *(Please note, though, that the higher you set desired capacity, the more expensive your infrastructure will be to run!)*

#### .tfvars Template
```
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
avail_zone_1  = "us-east-2a"
avail_zone_2  = "us-east-2b"
avail_zone_3  = "us-east-2c"
ami_id        = "ami-0f9c27d16302904d1"
instance_type = "t4g.nano"

#---------------------------------#
# Network Configuration Variables #
#---------------------------------#
subnet_cidr_block_1 = "10.0.10.0/24"
subnet_cidr_block_2 = "10.0.20.0/24"
subnet_cidr_block_3 = "10.0.30.0/24"
vpc_cidr_block      = "10.0.0.0/16"
```

Once this file has been populated, click **Save**. Open your Terminal to your project folder and type `terraform init`. Once that has completed, type `terraform apply`. Now, you should see a preview of infrastructure to be created. If you like what you see, type `yes` when prompted to confirm. Once the deployment completes, you should see an output labeled `application_endpoint`. Use this value in the next step to test your API.

## Testing
You can use [Insomnia](https://insomnia.rest/) to test the resulting Flask app. When you first open Insomnia, you'll see a splash screen that prompts you to "Import an OpenAPI spec to get started." Click **Skip**, then click **Create > New Request Collection**. You can name this Collection anything you'd like, but I recommend calling it something like `Flask API Testing.` Click **New Request**, and name that request anything you would like. The resulting screen should look like this:

![BlankInsomniaWindow](https://i.imgur.com/pKTZX7F.png)

Type the `application_endpoint` that Terraform showed once it completed the `apply` command into the field in the top-center of the window above the Body/Auth/Query/Header/Docs tabs are. Add `/` followed by the Route you would like to test, as listed below. So for example, your full path may look something like this: `app-lb-36342133.us-east-2.elb.amazonaws.com/gtg?details`. Please note that your application endpoint will differ from mine, as that value is unique to your infrastructure. These examples are only given to illustrate the proper format these values should be in.

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

## Destroying
When you are finished, go back to your terminal and type `terraform destroy` to tear all of the infrastructure back down. This will ensure that your costs to run the environment will be minimal.