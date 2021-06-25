#!/usr/bin/env bash
echo "running deploy.sh"
echo "3: $3"
re='https://([^\.]+)\.s3-([^\.]+)\.amazonaws.com/([^[:space:]]*)'
if ! [[ "$3" =~ $re ]]; then
  echo "does not match regex"
  exit 1
fi

BUCKET_NAME=${BASH_REMATCH[1]}
echo "BUCKET_NAME: $BUCKET_NAME"
BUCKET_REGION=${BASH_REMATCH[2]}
echo "BUCKET_REGION: $BUCKET_REGION"
OBJECT_PATH=${BASH_REMATCH[3]}
echo "OBJECT_PATH: $OBJECT_PATH"
S3_LOCATION="s3://${BUCKET_NAME}/${OBJECT_PATH}"
echo "S3_LOCATION: $S3_LOCATION"

export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
export AWS_DEFAULT_REGION="${BUCKET_REGION}" 
echo "aws s3 cp ${S3_LOCATION} chart.tgz"
aws s3 cp "${S3_LOCATION}" chart.tgz
mkdir chart 
tar -zxvf chart.tgz -C chart --strip-components=1
HELM_ARGS=( "$@" )
HELM_ARGS[2]="./chart"
echo "/bin/helm {HELM_ARGS[@]}"
helm "${HELM_ARGS[@]}"