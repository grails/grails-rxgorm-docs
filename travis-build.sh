EXIT_STATUS=0
./gradlew docs || EXIT_STATUS=$?

git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global credential.helper "store --file=~/.git-credentials"
echo "https://$GH_TOKEN:@github.com" > ~/.git-credentials

git clone https://${GH_TOKEN}@github.com/grails/grails-data-mapping.git -b gh-pages gh-pages --single-branch > /dev/null
cd gh-pages

mkdir -p rx
cd rx

if [[ $TRAVIS_REPO_SLUG == "grails/grails-rxgorm-docs" && $TRAVIS_PULL_REQUEST == 'false' && $EXIT_STATUS -eq 0 ]]; then
    if [[ $TRAVIS_TAG =~ ^v[[:digit:]] ]]; then
        version="$TRAVIS_TAG"
        version=${version:1}

        mkdir -p latest
        cp -r ../../build/docs/. ./latest/
        git add latest/*

        majorVersion=${version:0:4}
        majorVersion="${majorVersion}x"

        mkdir -p "$version"
        cp -r ../../build/docs/. "./$version/"
        git add "$version/*"

        git commit -a -m "Updating docs for Travis build: https://travis-ci.org/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"
        git push origin HEAD        
    else
        if [[ $TRAVIS_BRANCH == 'master' ]]; then
            mkdir -p snapshot
            cp -r ../../build/docs/. ./snapshot/

            git add snapshot/*
            git commit -a -m "Updating docs for Travis build: https://travis-ci.org/$TRAVIS_REPO_SLUG/builds/$TRAVIS_BUILD_ID"
            git push origin HEAD        
            
        fi
    fi
fi  