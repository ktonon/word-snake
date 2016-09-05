#!/usr/bin/env bash
set -e

source "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/env.sh

USAGE="
Usage: ./deploy.sh

You also need to define the following environment variables:
    ENV_NAME     - AWS EB environment name
    S3_BUCKET    - AWS S3 bucket to which the Dockerrun file will be copied
    DOCKER_USER  - Credentials for logging into docker hub
    DOCKER_PASS  - Credentials for logging into docker hub
    DOCKER_EMAIL - Credentials for logging into docker hub
"

[ ! $ENV_NAME = "" ] || (echo "$USAGE" && exit 1)
[ ! $S3_BUCKET = "" ] || (echo "$USAGE" && exit 1)
[ ! $DOCKER_USER = "" ] || (echo "$USAGE" && exit 1)
[ ! $DOCKER_PASS = "" ] || (echo "$USAGE" && exit 1)
[ ! $DOCKER_EMAIL = "" ] || (echo "$USAGE" && exit 1)

# -----------------------------------------------------------------------------
# Push to artifactory
# -----------------------------------------------------------------------------

docker login \
  --username=$DOCKER_USER \
  --password=$DOCKER_PASS \
  --email=$DOCKER_EMAIL

docker push $DOCKER_IMAGE

# -----------------------------------------------------------------------------
# Deploy to AWS
# -----------------------------------------------------------------------------

DOCKER_RUN_FILE=Dockerrun.aws.json
DOCKER_RUN_TEMPLATE=Dockerrun.aws.template.json
VERSION=$(date +%s)-$CIRCLE_SHA1
ZIP_FILE=$SERVICE-$VERSION-Package.zip
ZIP_FILE_PATH=$SERVICE/deployments/$ZIP_FILE

# Prepare Dockerrun for AWS
sed -e "s|<TAG>|${DOCKER_TAG}|" $DOCKER_RUN_TEMPLATE > ./$DOCKER_RUN_FILE
zip -r $ZIP_FILE $DOCKER_RUN_FILE

# Upload Dockerrun to S3
aws s3 \
  cp $ZIP_FILE s3://$S3_BUCKET/$ZIP_FILE_PATH \
  --region us-east-1

# Update eb instance
aws elasticbeanstalk \
  create-application-version \
  --region us-east-1 \
  --application-name $SERVICE \
    --version-label $VERSION \
    --source-bundle S3Bucket=$S3_BUCKET,S3Key=$ZIP_FILE_PATH

aws elasticbeanstalk \
  update-environment \
  --region us-east-1 \
  --environment-name $ENV_NAME \
  --version-label $VERSION
