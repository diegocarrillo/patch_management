#!/bin/bash



echo "Press enter 3 times"

ssh-keygen

aws ec2 import-key-pair --key-name "nginx-demo-key" --public-key-material fileb://~/.ssh/id_rsa.pub

echo "Key imported!"

