#!/usr/bin/env python
import synapseclient
import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument("-s", "--submissionid", required=True, help="Submission ID")
parser.add_argument("-c", "--synapse_config", required=True, help="credentials file")

args = parser.parse_args()
syn = synapseclient.Synapse(configPath=args.synapse_config)
syn.login()

sub = syn.getSubmission(args.submissionid, downloadFile = False)
 
result = {
    'userid':sub.userId,
    'name': sub.name,
    'evaluationid': sub.evaluationId
}

with open("results.json", 'w') as o:
    o.write(json.dumps(result))
