#!/usr/bin/env bash

function parse_https_url() {
  if [[ "$1" =~ https://([^\.]+)\.s3-([^\.]+)\.amazonaws\.com/(.*) ]]; then # Virtual Hosted-Style
    BUCKET_NAME=${BASH_REMATCH[1]} 
    BUCKET_REGION=${BASH_REMATCH[2]} 
    OBJECT_PATH=${BASH_REMATCH[3]}
  elif [[ "$1" =~ https://s3.([^\.]+).amazonaws.com/([^/]+)/(.*) ]]; then # Path-Style
    BUCKET_NAME=${BASH_REMATCH[2]} 
    BUCKET_REGION=${BASH_REMATCH[1]} 
    OBJECT_PATH=${BASH_REMATCH[3]} 
  else
    echo "unable to parse https address"
    exit 1
  fi
  echo "BUCKET_NAME: $BUCKET_NAME"
  echo "BUCKET_REGION: $BUCKET_REGION"
  echo "OBJECT_PATH: $OBJECT_PATH"
}

function assign_s3_url() {
  S3_URL="s3://${BUCKET_NAME}/${OBJECT_PATH}"
  echo "S3_URL: $S3_URL"
}

function set_up_chart_locally() {
  export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY
  export AWS_DEFAULT_REGION="${BUCKET_REGION}" 
  echo "aws s3 cp ${S3_LOCATION} chart.tgz"
  aws s3 cp "${S3_LOCATION}" chart.tgz
  mkdir chart 
  tar -zxvf chart.tgz -C chart --strip-components=1 
}

function run_helm() {
  HELM_ARGS=( "$@" )
  HELM_ARGS[2]="./chart"
  echo "/bin/helm {HELM_ARGS[@]}"
  helm "${HELM_ARGS[@]}" 
}

parse_https_url $3
assign_s3_url
set_up_chart_locally
run_helm "$@"