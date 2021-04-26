# patch_management
Patch Management sample with terraform

Here we have deployed a sample app (nginx) that is helping us in order to create our infra as part of one stack, and then our ASG as part of the application stack, after this we have a pipeline that helps us in order to make patching for our systems and generate an AMI for later deployments (security awareness)


The application consist of 3 stacks

1. Infrastructure
2. application
3. patching manager

# Procedure

1. Create a bucket in order to save there our state file remotely
2. Create and import into AWS a ssh key-pair
3. Deploy the first Stack for infrastructure
4. Deploy the second stack for the application layer
5. Deploy the third stack for patching and creation of the AMI
   
   Principal Actors for the patching and AMI creation
   * AWS codepipeline
   * AWS Code Build
   * AWS System manager