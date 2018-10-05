#!/usr/bin/env cwl-runner
#
# Example score emails to participants
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: python

inputs:
  - id: submissionId
    type: int
  - id: synapseConfig
    type: File
  - id: results
    type: File

arguments:
  - valueFrom: validationEmail.py
  - valueFrom: $(inputs.submissionId)
    prefix: -s
  - valueFrom: $(inputs.synapseConfig.path)
    prefix: -c
  - valueFrom: $(inputs.results)
    prefix: -r


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
          parser.add_argument("-r","--results", required=True, help="Resulting scores")

          args = parser.parse_args()
          syn = synapseclient.Synapse(configPath=args.synapseConfig)
          syn.login()

          sub = syn.getSubmission(args.submissionId)
          userId = sub.userId
          evaluation = syn.getEvaluation(sub.evaluationId)
          with open(args.results) as json_data:
            annots = json.load(json_data)
          if annots.get('predictionFileStatus') is None:
            raise Exception("score.cwl must return predictionFileStatus as a json key")
          status = annots['predictionFileStatus']
          del annots['predictionFileStatus']
          if status == "SCORED":
            subject = "Submission to '%s' scored!" % evaluation.name
            message = ["Hello %s,\n\n" % syn.getUserProfile(userId)['userName'],
                       "Your submission (%s) is scored, below are your results:\n\n" % sub.name,
                       "\n".join([i + " : " + str(annots[i]) for i in annots]),
                       "\n\nSincerely,\nChallenge Administrator"]
            syn.sendMessage(
              userIds=[userId],
              messageSubject=subject,
              messageBody="".join(message),
              contentType="text/html")
          
outputs: []
