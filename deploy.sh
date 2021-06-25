#!/usr/bin/env bash
echo "running deploy.sh"
re='https://([^\.]+)\.s3\.([^\.]+)\.amazonaws.com/([^[:space:]]*)'
if ! [[ "$3" =~ $re ]]; then
  exit 1
fi

BUCKET_NAME=${BASH_REMATCH[1]}
BUCKET_REGION=${BASH_REMATCH[2]}
OBJECT_PATH=${BASH_REMATCH[3]}

S3_LOCATION="s3://${BUCKET_NAME}/${OBJECT_PATH}"

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