#!/bin/bash
set -e

# GITHUB_TOKEN is a GitHub private access token configured for repo:status scope

if [ "$GITHUB_ACTIONS" = "true" ]; then
  REPO_FULL_NAME=$GITHUB_REPOSITORY
  PULL_REQUEST=$(echo "$GITHUB_REF" | cut -d '/' -f3)
fi

GITHUB_API=https://api.github.com/repos/$REPO_FULL_NAME

status() {
  DATA="{ \"state\": \"$1\", \"description\": \"$2\", \"context\": \"github / jira\"}"
  curl -s -H "Content-Type: application/json" -H "Authorization: token $GITHUB_TOKEN" -H "User-Agent: $REPO_FULL_NAME" -X POST -d "$DATA" "$3" 1>/dev/null
}

PULL_REQUEST_STATUS=$(curl -s -H "Content-Type: application/json" -H "Authorization: token $GITHUB_TOKEN" -H "User-Agent: $REPO_FULL_NAME" -X GET "$GITHUB_API/pulls/$PULL_REQUEST")
JIRA_NUMBER=$(echo "$PULL_REQUEST_STATUS" | jq -r '.title' | grep -Po '[A-Z]+-[0-9]+' || true)
STATUSES_URL=$(echo "$PULL_REQUEST_STATUS" | jq -r '.statuses_url')

if [ "$JIRA_NUMBER" != "" ]; then
  status "success" "JIRA number found in pull request title" "$STATUSES_URL" 
else
  status "failure" "JIRA number missing in start of pull request title e.g. 'ABC-123 <JIRA title>'" "$STATUSES_URL"
fi
