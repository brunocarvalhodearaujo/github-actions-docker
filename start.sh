#!/bin/bash

cd /home/docker/actions-runner

./config.sh --url "${GITHUB_URL}" --token "${GITHUB_TOKEN}" --unattended

cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token "${GITHUB_TOKEN}"
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
