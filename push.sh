#!/bin/bash

# Check if the commit message argument is provided
if [ $# -eq 0 ]; then
    echo "Error: No commit message provided."
    echo "Usage: ./push.sh <commit-message>"
    exit 1
fi

# Assign the commit message to a variable
commit_message="$1"

# Perform git add, commit, and push
git add .
git commit -m "$commit_message"
git push
act -s EC2_HOST=127.0.0.1 -s EC2_USER=root -s EC2_SSH_PORT=30856 -s EC2_KEY="$(cat ec2-key-2.pem)"

# Check the exit status of git push to confirm if it was successful
if [ $? -eq 0 ]; then
    echo "Changes successfully pushed to the repository."
else
    echo "Failed to push changes to the repository."
fi