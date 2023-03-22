"""
DynamoDB Stream handler
"""


def lambda_handler(event, context):
    print(context)

    for record in event['Records']:
        print(f"EventID:  {record['eventID']} EventName: {record['eventName']}")
        newImage = record.get("dynamodb", {}).get("NewImage", {})
        oldImage = record.get("dynamodb", {}).get("OldImage", {})
        print(f"newImage: {newImage}")
        print(f"oldImage: {oldImage}")

    print('Successfully processed %s records.' % str(len(event['Records'])))
