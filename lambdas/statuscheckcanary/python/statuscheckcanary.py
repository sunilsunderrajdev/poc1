import boto3
import json
import time
from botocore.exceptions import ClientError

def basic_custom_script():
    returnValue = True
    callResponse = {}
    
    try:
        dynamodb = boto3.resource('dynamodb')
        # table name 
        table = dynamodb.Table('canarytable') 
        # inserting values into table
        
        for minute in range(10):
            response = table.get_item(Key={"minute": "%s" % minute})
    
            ecpoch10minutesBack = int(time.time()) - 660
            
            if response['Item']['updatedepoch'] < ecpoch10minutesBack:
                returnValue = False
                break
    except Exception as e:
        returnValue = False
        callResponse["statusCode"] = 500
        callResponse["body"] = "Failed userstatus canary check with exception %s" % e
        print(callResponse["body"])

    if not returnValue:
        raise Exception(f"This canary completeness check failed")

    # TODO implement
    return {
        'statusCode': 200,
        'body': json.dumps('Completness check successful')
    }

def handler(event, context):
    return basic_custom_script()
