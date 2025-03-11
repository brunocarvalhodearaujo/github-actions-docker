#!/bin/bash

cd /home/docker/actions-runner

./config.sh --token ${TOKEN}

cleanup() {
  echo "Removing runner..."
  ./config.sh remove --unattended --token ${TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!