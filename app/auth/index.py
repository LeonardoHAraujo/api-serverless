# Copyright (C) LA Sistemas - All Rights Reserved.
#
# Written by Leonardo Araújo - ledharaujo@gmail.com, May 2022.

# Unauthorized copying of this file, via any medium, is strictly prohibited.
# Proprietary and confidential.


# Project.
import auth


def handler(event, context):
    '''Main auth function.'''

    if event['authorizationToken'] and event['authorizationToken'] == 'opa':
        return auth.generate_policy('slsAuth', 'Allow', event['methodArn'])

    return auth.generate_policy(None, 'Deny', event['methodArn'])

