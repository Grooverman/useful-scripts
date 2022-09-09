#!/usr/bin/env python3
import boto3
import os
from pprint import pformat

sns_2b_add = os.environ['sns_2b_add']
region_name = os.environ['region_name']

cloudwatch = boto3.client('cloudwatch', region_name=region_name)
alarms_paginator = cloudwatch.get_paginator('describe_alarms')
alarms_paginated = alarms_paginator.paginate()

metric_alarms = []
for i in alarms_paginated:
    metric_alarms = metric_alarms + i['MetricAlarms']


def add_sns(array, sns):
    existent = False
    for i in array:
        if i == sns:
            existent = True
    if not existent:
        array.append(sns)
    return(array)


count = 0
for i in metric_alarms:
    count += 1
    del i['StateReason']
    del i['StateReasonData']
    del i['StateUpdatedTimestamp']
    del i['StateValue']
    del i['AlarmArn']
    del i['AlarmConfigurationUpdatedTimestamp']
    metric = i
    metric['AlarmActions'] = add_sns(metric['AlarmActions'], sns_2b_add)
    metric['OKActions'] = add_sns(metric['OKActions'], sns_2b_add)
    metric['InsufficientDataActions'] = add_sns(metric['InsufficientDataActions'], sns_2b_add)
    print("\n", pformat(metric))
    result = cloudwatch.put_metric_alarm(**metric)
    print(pformat(result))

print("\nProcessed:", count)
exit()


