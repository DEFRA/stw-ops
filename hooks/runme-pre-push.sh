#!/bin/bash
# Copy the pre-push hook for Trufflehog into the right place and remind the user
# to set the env variable

if [ ! -d "../.git/hooks" ]; then
    echo "creating .git/hooks directory"
    mkdir ../.git/hooks
fi
cp ./pre-push ../.git/hooks/
chmod u+x ../.git/hooks/pre-push
echo "pre-push hook copied"

# remind the user to set DEFRA_WORKSPACE
dir=../..
parentdir=$(builtin cd $dir; pwd)
echo $parentdir
echo "Remember to set the DEFRA_WORKSPACE=/path/to/workspace value in your environment,"
echo "Add the following to your .zshrc or similar:"
echo "export DEFRA_WORKSPACE=$parentdir"
