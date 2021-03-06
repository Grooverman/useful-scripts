### Script to monitor relevant issues on Jira

Whenever you run the `get-jira-issues.sh` script it will:
1. execute the query specified in the "config" file in the same directory, 
2. generate an html document with a table showing the results of your query, and
3. open it on your favorite browser.

It does nothing, however, if your query returns empty. 

If what you want is to be regularly reminded of issues that you're responsible for, 
then you can add this script to your crontab so it's run every 15 minutes, for example:
```bash
*/15 * * * * export DISPLAY=:0 && /path/to/this/repo/get-jira-issues/get-jira-issues.sh
```

Another crontab example – run every 5 minutes, from 11:00 up to 17:59, but only on week days:
```bash
*/5 11-17 * * 1-5 export DISPLAY=:0 && /path/to/this/repo/get-jira-issues/get-jira-issues.sh
```

### Configuration
For these scripts to work you will need your Jira API token. 

![image](https://user-images.githubusercontent.com/87875608/128429786-920c135a-af0e-43e7-9b64-bfd8bdbecd3e.png)

How to get it:

https://support.atlassian.com/atlassian-account/docs/manage-api-tokens-for-your-atlassian-account/

Once you got your API token, make sure to copy the "config.example" file to a new "config" file, and edit it.
```bash
cp config.example config
vim config
```
