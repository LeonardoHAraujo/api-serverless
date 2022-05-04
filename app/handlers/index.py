# Copyright (C) LA Sistemas - All Rights Reserved.
#
# Written by Leonardo Araújo - ledharaujo@gmail.com, May 2022.

# Unauthorized copying of this file, via any medium, is strictly prohibited.
# Proprietary and confidential.


# Core.
import json


def handler(event, context):
    '''Main function.'''

    rep = {'headers': {}}

    rep['statusCode'] = 200
    rep['body'] = json.dumps(event)

    rep['headers']['Content-Type'] = 'application/json'

    return rep
