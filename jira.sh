#!/bin/bash

# GITHUB_TOKEN is a GitHub private access token configured for repo:status scope
GITHUB_API=https://api.github.com/repos/$REPO_FULL_NAME

status () {
  if [ "$SHIPPABLE" = "true" ]; then
    if [ "$IS_PULL_REQUEST" = "true" ]; then
      DESCRIPTION=`echo $2 | cut -b -100`
      DATA="{ \"state\": \"$1\", \"target_url\": \"$BUILD_URL\", \"description\": \"$DESCRIPTION\", \"context\": \"jira\"}"
      curl -H "Content-Type: application/json" -H "Authorization: token $GITHUB_TOKEN" -H "User-Agent: bangolufsen/jira" -X POST -d "$DATA" $GITHUB_API/statuses/$COMMIT 1>/dev/null 2>&1
    fi
 fi
}

pull_request_title() {
  if [ "$SHIPPABLE" = "true" ]; then
    if [ "$IS_PULL_REQUEST" = "true" ]; then
      curl -H "Content-Type: application/json" -H "Authorization: token $GITHUB_TOKEN" -H "User-Agent: bangolufsen/jira" -X GET $GITHUB_API/pulls/$PULL_REQUEST | grep -Po '"title":(\d*?,|.*?[^\\]")' | cut -d : -f2
    fi
  fi
}

JIRA_NUMBER=`pull_request_title | grep -o -E '[A-Z]+-[0-9]+'`

if [ "$JIRA_NUMBER" != "" ]; then
  status "success" "JIRA number $JIRA_NUMBER found in pull request title"
else
  status "failure" "No JIRA number found in pull request title"
fi
