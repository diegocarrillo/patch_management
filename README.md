# patch_management
Patch Management sample with terraform


Here we have deployed a sample app (nginx) that is helping us in order to create our infra as part of one stack, and then our ASG as part of application stack, after this we have a pipeline that help us in order to make a patching for our systems and generate an AMI for later deployments (security awarenss)

# Procedure

1. You need to create a bucket, this will be the place where our state file it is
2. You need to generate a key-pair in AWS
3.