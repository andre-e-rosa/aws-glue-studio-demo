#!/bin/bash
#######################################################
# Demo........: AWS Glue Studio
#######################################################
# Script Purpose: 
# ---------------
# 
# Undeploy Demo environment, created by bash shell
# script "./deploy-demo.sh"
#********************************************************
# Execution:
# -----------
# 
# > ./undeploy-demo.sh
#********************************************************
export OUTPUT_DIR=`pwd`

# START #
echo "********************" > ${OUTPUT_DIR}/undeploy_output.txt
echo "  UNDEPLOY START:  " >> ${OUTPUT_DIR}/undeploy_output.txt
date +"%F %T" >> ${OUTPUT_DIR}/undeploy_output.txt
echo "********************" >> ${OUTPUT_DIR}/undeploy_output.txt

# Deleting the objects on deployed S3 buckets
# --------------------------------------------------------
echo "############################################"
echo " Deleting objects on deployed S3 buckets..."
echo "############################################"

# Get bucket names
DATA_LAKE_BUCKET_NAME=`aws s3api list-buckets --query "Buckets[].Name" --output=yaml | grep datalake-bucket | cut --delimiter=" " --fields=2`
TEMP_BUCKET_NAME=`aws s3api list-buckets --query "Buckets[].Name" --output=yaml | grep temp-bucket | cut --delimiter=" " --fields=2`

# Deleting objects on S3 buckets
aws s3 rm s3://${DATA_LAKE_BUCKET_NAME} --recursive
aws s3 rm s3://${TEMP_BUCKET_NAME} --recursive
# --------------------------------------------------------

# Delet the Cloudformation stack, using the AWS SAM CLI
# --------------------------------------------------------
echo "###############################################################"
echo ' Undeploying AWS CloudFormation stack "aws-glue-studio-demo"...'
echo "###############################################################"

STACK_ID=$(aws cloudformation describe-stacks --stack-name aws-glue-studio-demo --query 'Stacks[*].StackId' --output text)
aws cloudformation delete-stack --stack-name aws-glue-studio-demo

echo "#############################################################"
echo ' Waiting for stack "aws-glue-studio-demo" deletion...'
echo "#############################################################"

aws cloudformation wait stack-delete-complete --stack-name ${STACK_ID}

STACK_STATUS=$(aws cloudformation describe-stacks --stack-name ${STACK_ID} --query 'Stacks[*].StackStatus' --output text)

if test "$STACK_STATUS" == "DELETE_COMPLETE"
then
    echo "###################################################"
    echo ' Stack "aws-glue-studio-demo" deletion successful!'
    echo "###################################################"
else
    echo "###############################################"
    echo ' Stack "aws-glue-studio-demo" deletion failed!'
    echo ${STACK_STATUS}
    echo "###############################################"
    exit 1
fi
# --------------------------------------------------------

# END #
echo "********************" >> ${OUTPUT_DIR}/undeploy_output.txt
echo "  UNDEPLOY END:  " >> ${OUTPUT_DIR}/undeploy_output.txt
date +"%F %T" >> ${OUTPUT_DIR}/undeploy_output.txt
echo "********************" >> ${OUTPUT_DIR}/undeploy_output.txt
