#!/usr/bin/env python
import synapseclient
import argparse
import json

parser = argparse.ArgumentParser()
parser.add_argument("-e", "--evaluationid", required=True, help="evaluationid")
parser.add_argument("-c", "--synapse_config", required=True, help="credentials file")

args = parser.parse_args()
syn = synapseclient.Synapse(configPath=args.synapse_config)
syn.login()

eval = syn.getEvaluation(args.evaluationid)

result = {
    "content_source":eval.contentSource,
    "created_on": eval.createdOn,
    "description": eval.description,
    "etag": eval.etag,
    "id": eval.id,
    "name": eval.name,
    "ownerid": eval.ownerId,
    "status": eval.status,
    "submission_instructions_message": eval.submissionInstructionsMessage,
    "submission_receipt_message": eval.submissionReceiptMessage
}

with open("results.json", 'w') as o:
    o.write(json.dumps(result))
