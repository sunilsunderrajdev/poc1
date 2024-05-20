import boto3
import json
from botocore.exceptions import ClientError

def lambda_handler(event, context):
    response = {}
    
    response["statusCode"] = 200
    response["body"] = "Successfully completed userstatus canary inserts."

    try:
        dynamodb = boto3.resource('dynamodb')
        #table name 
        table = dynamodb.Table('canarytable') 
        #inserting values into table 
        response = table.put_item( 
            Item = {"minute" : event['Records'][0]['body']}
        )
    except Exception as e:
        response["statusCode"] = 500
        response["body"] = "Failed userstatus canary check with exception %s" % e

    return response
