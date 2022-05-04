# Copyright (C) LA Sistemas - All Rights Reserved.
#
# Written by Leonardo Araújo - ledharaujo@gmail.com, May 2022.

# Unauthorized copying of this file, via any medium, is strictly prohibited.
# Proprietary and confidential.


def generate_policy(principal_id, effect, method_arn):
    '''Genetate policy for authorizer.'''

    rep = {}
    rep['principalId'] = principal_id

    if effect and method_arn:
        policy_document = {'Statement': []}
        obj = {}

        obj['Action'] = 'execute-api:Invoke'
        obj['Effect'] = effect
        obj['Resource'] = method_arn

        policy_document['Version'] = '2012-10-17'
        policy_document['Statement'].append(obj)

        rep['policyDocument'] = policy_document

    return rep
