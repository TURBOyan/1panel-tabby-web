#!/bin/bash

if [ ! -f .env ]; then
  echo "Error: .env file not found."
  exit 1
fi

CURRENT_DIR=$(pwd)

sed -i '/^ENV_FILE=/d' .env
sed -i '/^GLOBAL_ENV_FILE=/d' .env
printf "\nENV_FILE=%s/.env\nGLOBAL_ENV_FILE=%s/envs/global.env\n" "$CURRENT_DIR" "$CURRENT_DIR" >> .env

# shellcheck disable=SC1091
. ./.env

case "$SOCIAL_AUTH_PROVIDER" in
  github)    PREFIX=SOCIAL_AUTH_GITHUB ;;
  gitlab)    PREFIX=SOCIAL_AUTH_GITLAB ;;
  google)    PREFIX=SOCIAL_AUTH_GOOGLE_OAUTH2 ;;
  microsoft) PREFIX=SOCIAL_AUTH_MICROSOFT_GRAPH ;;
  azuread)   PREFIX=SOCIAL_AUTH_AZUREAD_TENANT_OAUTH2 ;;
  oidc)      PREFIX=SOCIAL_AUTH_OIDC ;;
  *)         PREFIX="" ;;
esac

sed -i '/^SOCIAL_AUTH_.*_KEY=/d' .env
sed -i '/^SOCIAL_AUTH_.*_SECRET=/d' .env
sed -i '/^SOCIAL_AUTH_OIDC_OIDC_ENDPOINT=/d' .env
sed -i '/^SOCIAL_AUTH_AZUREAD_TENANT_OAUTH2_TENANT_ID=/d' .env

if [ -n "$PREFIX" ] && [ -n "$SOCIAL_AUTH_KEY" ]; then
  printf "%s_KEY=%s\n%s_SECRET=%s\n" \
    "$PREFIX" "$SOCIAL_AUTH_KEY" "$PREFIX" "$SOCIAL_AUTH_SECRET" >> .env
fi

if [ -n "$SOCIAL_AUTH_EXTRA" ]; then
  case "$SOCIAL_AUTH_PROVIDER" in
    oidc)
      printf "SOCIAL_AUTH_OIDC_OIDC_ENDPOINT=%s\n" "$SOCIAL_AUTH_EXTRA" >> .env
      ;;
    azuread)
      printf "SOCIAL_AUTH_AZUREAD_TENANT_OAUTH2_TENANT_ID=%s\n" "$SOCIAL_AUTH_EXTRA" >> .env
      ;;
  esac
fi

echo "Check Finish."
