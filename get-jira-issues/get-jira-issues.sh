#!/usr/bin/env bash

html_code='''
<html>
  <head>
    <style>

html {
  --text-color-normal: #0a244d;
  --text-color-light: #8cabd9;
}

html[data-theme='dark'] {
  --text-color-normal: hsl(210, 10%, 62%);
  --text-color-light: hsl(210, 15%, 35%);
  --text-color-richer: hsl(210, 50%, 72%);
  --text-color-highlight: hsl(25, 70%, 45%);
}

body {
  background-color: #1c1c1c;
  color: #cccccc;
}
@media screen and (prefers-color-scheme: light) {
  body {
    background-color: #1c1c1c;
    color: #cccccc;
  }
}
a:link {
  color: #cccccc;
}

table {
        border-collapse:collapse;
}
tr {
        border:none;
}
th, td {
        border-collapse:collapse;
        border: 1px solid black;
        padding-top:0;
        padding-bottom:0;
}
.verticalSplit {
        border-top:none;
        border-bottom:none;
}
.verticalSplit:first-of-type {
        border-left:none;
}
.verticalSplit:last-of-type {
        border-right:none;
}

    </style>
  </head>
  <body>
''' 

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/config

jira_url=$(echo ${jira_url%/})

temp_file=$temp_dir/jira-search.html

curl -s "$jira_url/rest/issueNav/1/issueTable" \
  --compressed \
  --user $user:$token \
  -H "Referer: $jira_url/issues/?jql=$query" \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  -H '__amdModuleName: jira/issue/utils/xsrf-token-header' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H "X-Atlassian-Token: no-check" \
  -H "Origin: $jira_url" \
  --data-raw "startIndex=0&jql=$query&layoutKey=list-view" \
  | jq -r '.issueTable.table' | sed -e 's/\\n//g' | sed "s|href=\"|href=\"$jira_url|g" \
  > $temp_file

if [[ $(cat $temp_file) == "null" ]]; then
  echo Nothing new here.
else
  echo $(echo "$html_code" | cat - $temp_file) > $temp_file;
  sensible-browser "$temp_file";
fi

exit
