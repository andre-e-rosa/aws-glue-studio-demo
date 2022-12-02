#!/bin/bash
#######################################################
# Demo........: AWS Glue Studio
#######################################################
# Script Purpose: 
# ---------------
# 
# Setup Demo environment, launching the corresponding
# CloudFormation stack
#######################################################
# Execution:
# -----------
# 
# > ./deploy-demo.sh
#######################################################
# Author...........: anrosa@
# Created..........: 01st-November-2022
#######################################################
export OUTPUT_DIR=`pwd`

# START #
echo "********************" > ${OUTPUT_DIR}/deploy_output.txt
echo "  DEPLOY START:  " >> ${OUTPUT_DIR}/deploy_output.txt
date +"%F %T" >> ${OUTPUT_DIR}/deploy_output.txt
echo "********************" >> ${OUTPUT_DIR}/deploy_output.txt
#########

# Deploy cloudFormation stack with Demo environment:
#******************************************************
echo "#############################################################"
echo ' Deploying AWS CloudFormation stack "aws-glue-studio-demo"...'
echo "#############################################################"

STACK_ID=$(aws cloudformation create-stack --stack-name aws-glue-studio-demo --template-body file://../../cfn-template/aws-glue-studio-demo.yaml --capabilities CAPABILITY_NAMED_IAM --output text)

echo "#############################################################"
echo ' Waiting for stack "aws-glue-studio-demo" creation...'
echo "#############################################################"

aws cloudformation wait stack-create-complete --stack-name ${STACK_ID}

STACK_STATUS=$(aws cloudformation describe-stacks --stack-name aws-glue-studio-demo --query 'Stacks[*].StackStatus' --output text)

if test "$STACK_STATUS" == "CREATE_COMPLETE"
then
    echo "###################################################"
    echo ' Stack "aws-glue-studio-demo" creation successful!'
    echo "###################################################"
else
    echo "###############################################"
    echo ' Stack "aws-glue-studio-demo" creation failed!'
    echo ${STACK_STATUS}
    echo "###############################################"
    exit 1
fi
#******************************************************

# END #
echo "********************" >> ${OUTPUT_DIR}/deploy_output.txt
echo "  DEPLOY END:  " >> ${OUTPUT_DIR}/deploy_output.txt
date +"%F %T" >> ${OUTPUT_DIR}/deploy_output.txt
echo "********************" >> ${OUTPUT_DIR}/deploy_output.txt
#######
