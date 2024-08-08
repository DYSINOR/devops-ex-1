#!/bin/bash
# Check if no arguments are provided
if [ $# -eq 0 ]; then
    echo "Error: No arguments provided."
    echo "Usage: ./script.sh <arg1> <arg2> ..."
    exit 1
fi

key_name=$1
key_file=$key_name".pem"

# Create key
awslocal ec2 create-key-pair \
    --key-name $key_name \
    --query 'KeyMaterial' \
    --output text | tee $key_file 
# Add read permission to key
chmod 400 $key_file

# Add rule to security group
awslocal ec2 authorize-security-group-ingress \
    --group-id default \
    --protocol tcp \
    --port 8000 \
    --cidr 0.0.0.0/0 | cat

# Run instance
awslocal ec2 run-instances \
    --image-id ami-ff0fea8310f3 \
    --count 1 \
    --instance-type t3.nano \
    --key-name $key_name \
    --security-groups 'default' \
    --user-data "#!/bin/bash -xeu
        apt update
        apt install curl -y
        apt install git -y
        # Install NVM
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
        . ~/.nvm/nvm.sh
        # Install Node.js 18
        nvm install 18
        # Install PM2
        npm install pm2 -g
        # Clone Node.js repository
        git clone https://github.com/DYSINOR/devops-ex-1.git /root/devops-ex
        # Navigate to the repository and start the app with PM2
        cd /root/devops-ex
        npm install
        pm2 start app.js --name node-app -- -p 8000
        " | cat