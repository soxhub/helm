#!/usr/bin/env bash

set -e

DEFAULT_BUCKET_REGION="us-west-2" # can be overridden via env or parsed from an https endpoint

function parse_location() {
  if [[ "$1" =~ s3://([^/]+)/(.+) ]]; then
    BUCKET_NAME=${BASH_REMATCH[1]} 
    OBJECT_PATH=${BASH_REMATCH[2]}
    if [  -z "$BUCKET_REGION" ]; then
       BUCKET_REGION="${DEFAULT_BUCKET_REGION}"
    fi 
  elif [[ "$1" =~ https://([^.]+)\.s3-([^.]+)\.amazonaws\.com/(.*) ]]; then # Virtual Hosted-Style
    BUCKET_NAME=${BASH_REMATCH[1]}
    BUCKET_REGION=${BASH_REMATCH[2]}
    OBJECT_PATH=${BASH_REMATCH[3]}
  elif [[ "$1" =~ https://s3.([^.]+).amazonaws.com/([^/]+)/(.*) ]]; then # Path-Style
    BUCKET_NAME=${BASH_REMATCH[2]}
    BUCKET_REGION=${BASH_REMATCH[1]}
    OBJECT_PATH=${BASH_REMATCH[3]}
  else
    echo "unable to parse address"
    exit 1
  fi
  echo "BUCKET_NAME: $BUCKET_NAME"
  echo "BUCKET_REGION: $BUCKET_REGION"
  echo "OBJECT_PATH: $OBJECT_PATH"
}

function assign_s3_location() {
  S3_LOCATION="s3://${BUCKET_NAME}/${OBJECT_PATH}"
  echo "S3_LOCATION: $S3_LOCATION"
}

function set_up_chart_locally() {
  export AWS_DEFAULT_REGION="${BUCKET_REGION}" 
  echo "aws s3 cp ${S3_LOCATION} chart.tgz"
  aws s3 cp "${S3_LOCATION}" chart.tgz
}

function run_helm() {
  HELM_ARGS=( "$@" )
  HELM_ARGS[2]="./chart.tgz"
  echo "/bin/helm ${HELM_ARGS[*]}"
  helm "${HELM_ARGS[@]}" 
}

parse_location $3
assign_s3_location
set_up_chart_locally
run_helm "$@"
