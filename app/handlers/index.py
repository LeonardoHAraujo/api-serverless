import json


def handler(event, context):
    '''Main function.'''

    rep = {'headers': {}}

    rep['statusCode'] = 200
    rep['body'] = json.dumps(event)

    rep['headers']['Content-Type'] = 'application/json'

    return rep
