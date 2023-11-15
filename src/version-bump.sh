#!/bin/bash

# Script directory
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

#
# Takes a version number, and the mode to bump it, and increments/resets the proper components so that the result is placed in the variable `NEW_VERSION`.
#
# $1 = mode (major, minor, patch)
# $2 = current version (x.y.z)
#
function bump {
  local mode="$1"
  local current="$2"
  IFS='.' read -r -a parts <<< "$current"

  case "$mode" in
    major)
      NEW_VERSION="$((parts[0] + 1)).0.0"
      ;;
    minor)
      NEW_VERSION="${parts[0]}.$((parts[1] + 1)).0"
      ;;
    patch)
      NEW_VERSION="${parts[0]}.${parts[1]}.$((parts[2] + 1))"
      ;;
  esac
}

# Check for dry-run or mode flag
DRY_RUN=false
BUMP_MODE="patch"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --mode)
      shift
      BUMP_MODE="$1"
      shift
      ;;
    *)
      echo "Unknown flag: $1"
      shift
      ;;
  esac
done

# Check for mode environment variable
if [[ -n "$MODE" ]]; then
  BUMP_MODE="$MODE"
fi

echo "Bump mode: $BUMP_MODE"
echo "Dry run: $DRY_RUN"

OLD_VERSION=$($DIR/get-version.sh)
bump "$BUMP_MODE" "$OLD_VERSION"
echo "Version will be bumped from $OLD_VERSION to $NEW_VERSION"

if [[ "$DRY_RUN" == "false" ]]; then
  if [[ -f gradle.properties ]] && grep -E -q "version=${OLD_VERSION}" gradle.properties; then
    BUILD_FILE=./gradle.properties
  elif [[ -f ./build.gradle ]]; then
    BUILD_FILE=./build.gradle
  elif [[ -f ./build.gradle.kts ]]; then
    BUILD_FILE=./build.gradle.kts
  else
    echo "Build file not found."
    exit 1
  fi
  sed -i "s/\(version *= *['\"]*\)${OLD_VERSION}\(['\"]*\)/\1${NEW_VERSION}\2/" "${BUILD_FILE}"

  git config --local user.email $EMAIL
  git config --local user.name $NAME
  git add "$BUILD_FILE"
  git commit -m "Version bump from $OLD_VERSION to $NEW_VERSION"

  REPO="https://$GITHUB_ACTOR:$TOKEN@github.com/$GITHUB_REPOSITORY.git"
  if [[ "${RELEASE}" == "false" ]]; then
    git push "$REPO"
  else
    git tag "$NEW_VERSION"
    git push "$REPO" --follow-tags
    echo "Tagged new version"
  fi
fi
