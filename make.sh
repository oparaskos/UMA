#!/bin/bash
PACKAGE_GIT="git@github.com:oparaskos/com.github.umasteeringgroup.uma.uma.git"

ROOTDIR=$(pwd)
SRC_PATH="$ROOTDIR/UMAProject"
OUT_PATH="$ROOTDIR/UnityPackage"
DOCS_PATH="$OUT_PATH/Documentation~"
VERSION=$(git describe --tag | sed s/v// | sed s/-.*//)
PACKAGE_REPO=$(echo $PACKAGE_GIT | sed 's/\:/\//' | sed 's/\.git//' | sed 's=git@=https://=')
GIT_REMOTE=$(git remote get-url origin)
GIT_REPO=$(git remote get-url origin | sed 's/\:/\//' | sed 's/\.git//' | sed 's=git@=https://=')
BRANCH=$(git branch --show-current)

## Clean and then clone the target repo (Where the unity package will live as a package)
if [ -z "$1" ] || [ "$1" == 'CHECKOUT' ]
then
    if [ -d $OUT_PATH ]
    then 
        cd $OUT_PATH
        git fetch || exit 1
        git checkout $BRANCH || git checkout master || git checkout main || exit 1
        git reset --hard origin/$BRANCH  || git reset --hard origin/master || git reset --hard origin/main || exit 1
        git pull || exit 1
        git checkout -b $BRANCH || git checkout $BRANCH exit 1
    else
        git clone -b $BRANCH --depth=1 $PACKAGE_GIT $OUT_PATH || \
            git clone --depth=1 $PACKAGE_GIT $OUT_PATH || exit 1
    fi
    cd $ROOTDIR
fi

# Populate and override the contents of the package path with new contents
if [ -z "$1" ] || [ "$1" == "PACKAGE" ]
then
    rm -rf $OUT_PATH/* || exit 1
    ## Examples~
    cp -r $SRC_PATH/Assets/UMA/Examples $OUT_PATH/Examples~/ || exit 1
    cp -r $SRC_PATH/Assets/UMA/Getting\ Started $OUT_PATH/Examples~/ || exit 1

    ## package.json
    DEPENDENCIES=$(cat UMAProject/Packages/manifest.json | jq .dependencies)
    echo "{" > $OUT_PATH/_package.json || exit 1
    echo '  "name": "com.secretanorak.uma",' >> $OUT_PATH/_package.json || exit 1
    echo '  "displayName": "UMA",' >> $OUT_PATH/_package.json || exit 1
    echo '  "description": "Unity Multipurpose Avatar",' >> $OUT_PATH/_package.json || exit 1
    echo '  "licenseSpdxId": "MIT",' >> $OUT_PATH/_package.json || exit 1
    echo '  "licenseName": "MIT License",' >> $OUT_PATH/_package.json || exit 1
    echo "  \"parentRepoUrl\": \"$GIT_REPO\"," >> $OUT_PATH/_package.json || exit 1
    echo "  \"repoUrl\": \"$PACKAGE_REPO\"," >> $OUT_PATH/_package.json || exit 1
    echo "  \"version\": \"$VERSION\"," >> $OUT_PATH/_package.json || exit 1 || exit 1
    echo "  \"dependencies\": $DEPENDENCIES" >> $OUT_PATH/_package.json || exit 1
    echo "}" >> $OUT_PATH/_package.json || exit 1
    cat $OUT_PATH/_package.json | jq > $OUT_PATH/package.json || exit 1
    rm $OUT_PATH/_package.json || exit 1

    ## Documentation~
    mkdir -p $DOCS_PATH || exit 1
    find $SRC_PATH -name *.pdf | xargs -I '{}' cp {} $DOCS_PATH || exit 1

    ## Editor
    mkdir -p $OUT_PATH/Editor || exit 1
    cp -r $SRC_PATH/Assets/UMA/Editor $OUT_PATH/Editor || exit 1

    ## Runtime
    mkdir -p $OUT_PATH/Runtime || exit 1
    cp -r $SRC_PATH/Assets/UMA/Core $OUT_PATH/Runtime/ || exit 1
    cp -r $SRC_PATH/Assets/UMA/Content $OUT_PATH/Runtime/ || exit 1
    cp -r $SRC_PATH/Assets/UMA/InternalDataStore $OUT_PATH/Runtime/ || exit 1


    ## Tests
    mkdir -p $OUT_PATH/Tests/Editor $OUT_PATH/Tests/Runtime || exit 1


    ## CHANGELOG.md
    cat "$SRC_PATH/Assets/UMA/Whats New in UMA.txt" | sed "s/What/# What/g" > $OUT_PATH/CHANGELOG.md || exit 1

    ## LICENSE.md
    cp $ROOTDIR/LICENSE $OUT_PATH/LICENSE.md || exit 1

    # README.md
    cp *.md $OUT_PATH || exit 1
    cp *.png $OUT_PATH || exit 1

fi

## Prepare to commit
if [ -z "$1" ] || [ "$1" == "INDEX" ]
then
    cd $OUT_PATH
    git add -A
    git status
    cd $ROOTDIR
fi


# Commit and push to package repo
if [ -z "$1" ] || [ "$1" == "PUSH" ]
then
    cd $OUT_PATH
    git commit
    git push -f -u origin HEAD || exit 1
    cd $ROOTDIR
fi