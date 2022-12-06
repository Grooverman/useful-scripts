#!/usr/bin/env python3
import requests
import json
import sys

fields_to_remove = [
        'responders',
        'teams',
        'ownerTeamId',
        'seen',
        'owner',
        'report',
        'description',
        'snoozed',
        'actions',
        'tinyId']

if len(sys.argv) < 3:
    print(
            "Usage:\n" +
            "\t" + "./report.py [token id] [timestamp to start from]" +
            " > [output file]\n\n" +
            "Example:\n" +
            "\t" + "./report.py " +
            "1f00dd7a-574f-4427-847e-f283865ac535 1667271600000 > /tmp/result.json")
    sys.exit(0)

token = sys.argv[1]
createdAt = sys.argv[2]
query = "integration.name:Dynatrace* AND createdAt>=" + createdAt
url = 'https://api.opsgenie.com/v2/alerts' 
headers = {"Authorization": "GenieKey " + token}

params = { 
        "query": query,
        "offset": 0,
        "limit": 100,
        "sort": "createdAt",
        "order": "asc",
        "entity": True,
        "details": True}
try:
    r = requests.get(
        url,
        headers=headers,
        params=params)
    rdata = json.loads(r.text)
except Exception as e:
    print("Could not request data from Opsgenie.")
    print(e)
    sys.exit(1)

all_data = []
paginate = True
while paginate == True:
    try:
        all_data += rdata['data']
        paging_next_url = rdata['paging']['next']
        r = requests.get(paging_next_url, headers=headers)
        rdata = json.loads(r.text)
    except:
        paginate = False

ids = []
for i,v in enumerate(all_data):
    ids.append(v['id'])

alerts = []
for aid in ids:
    alert_url = url + '/' + aid
    params = {"identifierType": "id"}
    try:
        r = requests.get(
                alert_url,
                headers=headers,
                params=params)
        rdata = json.loads(r.text)
        alerts.append(rdata['data'])
    except Exception as e:
        print("Could not request data from Opsgenie.")
        print(e)
        sys.exit(1)

for i,v in enumerate(alerts):
    for f in fields_to_remove:
        del alerts[i][f]
    alerts[i]['integration'] = alerts[i]['integration']['name']
    alerts[i]['tags'] = str(alerts[i]['tags'])[1:-1]


print(json.dumps(alerts))
