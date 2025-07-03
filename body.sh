#!/bin/sh -ex

BASE_DOWNLOAD_URL="https://github.com/Eden-CI/PR/releases/download"
if [ "$NO_SHA" = "true" ]; then
  TAG=${FORGEJO_NUMBER}
else
  TAG=${FORGEJO_NUMBER}-${FORGEJO_REF}
fi

if [ "$FORGEJO_TOKEN" = "" ]; then
  echo "You must supply a Forgejo API Token via the FORGEJO_TOKEN environment variable."
  exit 1
fi

linux() {
  ARCH="$1"
  PRETTY_ARCH="$2"
  DESCRIPTION="$3"

  echo -n "| "
  echo -n "[$PRETTY_ARCH](${BASE_DOWNLOAD_URL}/${TAG}/Eden-Linux-${FORGEJO_NUMBER}-${FORGEJO_REF}-${ARCH}.AppImage) | "
  echo -n "$DESCRIPTION |"
  echo
}

win() {
  ARCH="$1"
  PRETTY_ARCH="$2"
  DESCRIPTION="$3"

  echo -n "| "
  echo -n "[$PRETTY_ARCH](${BASE_DOWNLOAD_URL}/${TAG}/Eden-Windows-${FORGEJO_NUMBER}-${FORGEJO_REF}-${ARCH}.zip) | "
  echo -n "$DESCRIPTION |"
  echo
}

PR_API_URL="https://git.eden-emu.dev/api/v1/repos/eden-emu/eden/pulls"

get_pr_json() {
  curl "${PR_API_URL}/${FORGEJO_NUMBER}" -H "Authorization: token $FORGEJO_TOKEN"
}

PR_JSON="$(get_pr_json)"

get_pr_description() {
  echo $PR_JSON | jq -r '.body' || echo ""
}

get_pr_title() {
  echo $PR_JSON | jq -r '.title' || echo $FORGEJO_TITLE
}

get_pr_url() {
  echo $PR_JSON | jq -r '.html_url' || echo $FORGEJO_PR_URL
}

changelog() {
  echo "## Changelog"
  echo
  get_pr_description
  echo
}

if [ "$GITHUB_ENV" != "" ]; then
  echo "FORGEJO_TITLE=$(get_pr_title)" >> $GITHUB_ENV
fi

echo "This is pull request number $FORGEJO_NUMBER, ref \`$FORGEJO_REF\` of Eden."
echo "The original PR can be found [here]($(get_pr_url))."
echo
changelog
echo "## Notice"
echo
echo "These builds are provided **as-is**. They are intended for testers and developers ONLY."
echo "They are made available to the public in the interest of maximizing user freedom, but you"
echo "**will NOT receive support** while using these builds, *unless* you have useful debug/testing"
echo "info to share."
echo
echo "Furthermore, sharing these builds and claiming they are the \"official\" or \"release\""
echo "builds is **STRICTLY FORBIDDEN** and may result in further action from the Eden development team."
echo
echo "## Packages"
echo
echo "### Linux"
echo
echo "Linux packages are distributed via AppImage. Each build is optimized for a specific architecture."
echo "See the *Description* column for more info. Note that legacy builds will always work on newer systems."
echo
echo "| Build | Description |"
echo "| ----- | ----------- |"
linux legacy "amd64 (legacy)" "For CPUs older than 2013 or so"
linux amd64 "amd64" "For any modern AMD or Intel CPU"
linux steamdeck "Steam Deck" "For Steam Deck and other >= Zen 2 AMD CPUs"
linux rog-ally "ROG Ally X" "For ROG Ally X and other >= Zen 4 AMD CPUs"
linux aarch64 "armv8-a" "For ARM CPUs made in mid-2021 or earlier"
linux armv9 "armv9-a" "For ARM CPUs made in late 2021 or later"
echo
echo "### Windows"
echo
echo "Windows packages are in-place zip files."
echo
echo "| Build | Description |"
echo "| ----- | ----------- |"
win amd64 amd64 "For any Windows machine running an AMD or Intel CPU"
echo "| arm64 (WIP) | For any Windows machine running a Qualcomm or other ARM-based SoC. Currently a work-in-progress."
# win arm64 aarch64 "For any Windows machine running a Qualcomm or other ARM-based SoC"
echo
echo "### Android"
echo
echo "Android comes in a single APK."
echo
echo "[Android APK](${BASE_DOWNLOAD_URL}/${TAG}/Eden-Android-${FORGEJO_NUMBER}-${FORGEJO_REF}.apk)"
echo
