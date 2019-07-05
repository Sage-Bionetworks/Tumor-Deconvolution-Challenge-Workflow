#!/usr/bin/env python
import synapseclient
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-c", "--synapse_config", required=True)
parser.add_argument("-u", "--userid", required=True)
parser.add_argument("-s", "--subject", required=True)
parser.add_argument("-b", "--body", required=True)
parser.add_argument("-t", "--content_type", default="text")

args = parser.parse_args()
syn = synapseclient.Synapse(configPath=args.synapse_config)
syn.login()

syn.sendMessage(
    userIds=[args.userid],
    messageSubject=args.subject,
    messageBody=args.body,
    contentType=args.content_type)
