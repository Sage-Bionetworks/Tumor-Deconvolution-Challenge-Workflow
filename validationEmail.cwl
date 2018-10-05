#!/usr/bin/env cwl-runner
#
# Example sends validation emails to participants
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: python

inputs:
  - id: submissionId
    type: int
  - id: synapseConfig
    type: File
  - id: status
    type: string
  - id: invalidReasons
    type: string

arguments:
  - valueFrom: validationEmail.py
  - valueFrom: $(inputs.submissionId)
    prefix: -s
  - valueFrom: $(inputs.synapseConfig.path)
    prefix: -c
  - valueFrom: $(inputs.status)
    prefix: --status
  - valueFrom: $(inputs.invalidReasons)
    prefix: -i


requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: validationEmail.py
        entry: |
          #!/usr/bin/env python
          import synapseclient
          import argparse
          import json
          import os
          parser = argparse.ArgumentParser()
          parser.add_argument("-s", "--submissionId", required=True, help="Submission ID")
          parser.add_argument("-c", "--synapseConfig", required=True, help="credentials file")
          parser.add_argument("--status", required=True, help="Prediction File Status")
          parser.add_argument("-i","--invalid", required=True, help="Invalid reasons")

          args = parser.parse_args()
          syn = synapseclient.Synapse(configPath=args.synapseConfig)
          syn.login()

          sub = syn.getSubmission(args.submissionId)
          userId = sub.userId
          evaluation = syn.getEvaluation(sub.evaluationId)
          if args.status == "INVALID":
            subject = "Submission to '%s' invalid!" % evaluation.name
            message = ["Hello %s,\n\n" % syn.getUserProfile(userId)['userName'],
                       "Your submission (%s) is invalid, below are the invalid reasons:\n\n" % sub.name,
                       args.invalid,
                       "\n\nSincerely,\nChallenge Administrator"]
          else:
            subject = "Submission to '%s' accepted!" % evaluation.name
            message = ["Hello %s,\n\n" % syn.getUserProfile(userId)['userName'],
                       "Your submission (%s) is valid!\n\n" % sub.name,
                       "\nSincerely,\nChallenge Administrator"]
          syn.sendMessage(
            userIds=[userId],
            messageSubject=subject,
            messageBody="".join(message),
            contentType="text/html")
          
outputs: []
