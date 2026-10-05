#!/bin/bash

if [ ! -f .env ]; then
  echo "Error: .env file not found."
  exit 1
fi

CURRENT_DIR=$(pwd)

sed -i '/^ENV_FILE=/d' .env
sed -i '/^GLOBAL_ENV_FILE=/d' .env
printf "\nENV_FILE=%s/.env\nGLOBAL_ENV_FILE=%s/envs/global.env\n" "$CURRENT_DIR" "$CURRENT_DIR" >> .env

echo "Check Finish."
