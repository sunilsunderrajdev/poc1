import json

def lambda_handler(event, context):
    response = {}
    print("Message from SQS to Lambda")
    print(event)

    statusCode = 200
    response["statusCode"] = statusCode
    response["body"] = json.dumps(event)

    return response
