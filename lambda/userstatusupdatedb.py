import boto3
import time
import json
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    response = {}

    print(event)
    print(json.loads(event['Records'][0]['body'])['minute'])
    print("print complete")
    
    response["statusCode"] = 200
    response["body"] = "Successfully completed userstatus canary inserts."

    try:
        dynamodb = boto3.resource('dynamodb')
        #table name 
        table = dynamodb.Table('canarytable') 
        #inserting values into table 
        dbResponse = table.put_item( 
            Item = {"minute" : json.loads(event['Records'][0]['body'])['minute'], "updatedepoch": int(time.time())}
        )
    except Exception as e:
        response["statusCode"] = 500
        response["body"] = "Failed userstatus canary check with exception %s" % e

    print(response)

    return response
