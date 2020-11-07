#!/bin/sh
SRC_PATH="./UMAProject"
OUT_PATH="./UnityPackage"
DOCS_PATH="$OUT_PATH/Documentation~"
VERSION=$(git describe --tag | sed s/v// | sed s/-.*//)
GIT_REMOTE=$(git remote get-url origin)
GIT_REPO=$(git remote get-url origin | sed 's/\:/\//' | sed 's/\.git//' | sed 's=git@=https://=')

mkdir -p $OUT_PATH


## Examples~
cp -r $SRC_PATH/Assets/UMA/Examples $OUT_PATH/Examples~/
cp -r $SRC_PATH/Assets/UMA/Getting\ Started $OUT_PATH/Examples~/

## package.json
DEPENDENCIES=$(cat UMAProject/Packages/manifest.json | jq .dependencies)
echo "{" > $OUT_PATH/_package.json
echo '  "name": "com.secretanorak.uma",' >> $OUT_PATH/_package.json
echo '  "displayName": "UMA",' >> $OUT_PATH/_package.json
echo '  "description": "Unity Multipurpose Avatar",' >> $OUT_PATH/_package.json
echo '  "licenseSpdxId": "MIT",' >> $OUT_PATH/_package.json
echo '  "licenseName": "MIT License",' >> $OUT_PATH/_package.json
echo '  "parentRepoUrl": "https://github.com/umasteeringgroup/UMA",' >> $OUT_PATH/_package.json
echo "  \"repoUrl\": \"$GIT_REPO\"," >> $OUT_PATH/_package.json
echo "  \"version\": \"$VERSION\"," >> $OUT_PATH/_package.json
echo "  \"dependencies\": $DEPENDENCIES" >> $OUT_PATH/_package.json
echo "}" >> $OUT_PATH/_package.json
cat $OUT_PATH/_package.json | jq > $OUT_PATH/package.json
rm $OUT_PATH/_package.json

## Documentation~
mkdir -p $DOCS_PATH
find $SRC_PATH -name *.pdf | xargs -I '{}' cp {} $DOCS_PATH

## Editor
mkdir -p $OUT_PATH/Editor
cp -r $SRC_PATH/Assets/UMA/Editor $OUT_PATH/Editor

## Runtime
mkdir -p $OUT_PATH/Runtime
cp -r $SRC_PATH/Assets/UMA/Core $OUT_PATH/Runtime/
cp -r $SRC_PATH/Assets/UMA/Content $OUT_PATH/Runtime/
cp -r $SRC_PATH/Assets/UMA/InternalDataStore $OUT_PATH/Runtime/


## Tests
mkdir -p $OUT_PATH/Tests/Editor $OUT_PATH/Tests/Runtime


## CHANGELOG.md
cat "./$SRC_PATH/Assets/UMA/Whats New in UMA.txt" | sed "s/What/# What/g" > $OUT_PATH/CHANGELOG.md

## LICENSE.md
cp ./LICENSE $OUT_PATH/LICENSE.md

# README.md
cp *.md $OUT_PATH
cp *.png $OUT_PATH

