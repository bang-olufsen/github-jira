#!/bin/bash

# GITHUB_TOKEN is a GitHub private access token configured for repo:status scope
GITHUB_API=https://api.github.com/repos/$REPO_FULL_NAME

status () {
  if [ "$SHIPPABLE" = "true" ]; then
    if [ "$IS_PULL_REQUEST" = "true" ]; then
      DESCRIPTION=`echo $2 | cut -b -100`
      DATA="{ \"state\": \"$1\", \"target_url\": \"$BUILD_URL\", \"description\": \"$DESCRIPTION\", \"context\": \"jira\"}"
      curl -s -H "Content-Type: application/json" -H "Authorization: token $GITHUB_TOKEN" -H "User-Agent: bangolufsen/jira" -X POST -d "$DATA" $GITHUB_API/statuses/$COMMIT 1>/dev/null
    fi
 fi
}

jira_number() {
  if [ "$SHIPPABLE" = "true" ]; then
    if [ "$IS_PULL_REQUEST" = "true" ]; then
      curl -s -H "Content-Type: application/json" -H "Authorization: token $GITHUB_TOKEN" -H "User-Agent: bangolufsen/jira" -X GET $GITHUB_API/pulls/$PULL_REQUEST | grep -Po '"title":"[A-Z]+-[0-9]+' | cut -f4 -d '"'
    fi
  fi
}

if [ "`jira_number`" != "" ]; then
  status "success" "JIRA number found in pull request title"
else
  status "failure" "JIRA number missing in start of pull request title e.g. 'ABC-123 <title>'"
fi
