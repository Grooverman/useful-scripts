#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
source $SCRIPT_DIR/config
jira_url=$(echo ${jira_url%/})
temp_file=$temp_dir/jira-wiki.html

# handle arguments
if [ $# -lt 1 ]; then
  echo "No arguments given." >&2
  # TODO: add usage
  exit
fi
open=true
while true; do
  case "$1" in
    -d)
      open=false
      echo "Downloading to file: $temp_file"
      shift
      ;;
    -o)
      open=true
      shift
      ;;
    -*)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
    *)
      break
      ;;
  esac
done

curl -s "$1" \
  --compressed \
  --user $user:$token \
  -H "Referer: $jira_url" \
  -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' \
  -H '__amdModuleName: jira/issue/utils/xsrf-token-header' \
  -H 'X-Requested-With: XMLHttpRequest' \
  -H "X-Atlassian-Token: no-check" \
  -H "Origin: $jira_url" \
  | sed -E 's/<script/<!-- <script/g' | sed -E 's/<\/script>/<\/script> -->/g' \
  | sed -E 's/src="([^"]+\.js)"/src=""/g' | sed -E 's/src=\\"([^"]+\.js)\\"/src=\\"\\"/g' \
  | sed -E 's/<hr\/?>//' \
  | sed -E 's/id="AkTopNav"/id="AkTopNav" hidden /' \
  | sed -E 's/topNavigationHeight:56px/topNavigationHeight:0px/' \
  | sed -E 's/--leftSidebarWidth:240px/--leftSidebarWidth:0px/g' \
  | sed -E 's/><div id="content-header-container"/ hidden><div id="content-header-container"/' \
  | sed -E 's/id="likes-and-labels-container"/id="likes-and-labels-container" hidden/' \
  > $temp_file

if [[ $open == 'true' ]]; then
  sensible-browser "$temp_file";
fi

exit
