#!/usr/bin/env bash

set -e

VERSION=$(node --print --eval "require('./package.json').version")
USAGE_MSG='Usage: BRANCH=[BRANCH] calculate_version.sh'

if [ -z "$BRANCH" ]
then
    (>&2 echo 'You should provide branch')
    echo "$USAGE_MSG"
    exit 1
fi

BRANCH=$(echo $BRANCH | tr [:upper:] [:lower:] | tr -d [:space:])

if [ -z "$VERSION" ]; then
      echo "The base version is not set."
      exit 1
fi

git fetch --tags > /dev/null

for (( NUMBER=0; ; NUMBER++ ))
do
    FULL_VERSION="$VERSION-$BRANCH.$NUMBER"
    if ! [[ $(git tag -l | grep "$FULL_VERSION") ]]
    then
        echo "$FULL_VERSION" | tr / -
        break
    fi
done
