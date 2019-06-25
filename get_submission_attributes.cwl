#!/usr/bin/env cwl-runner
#
# Example sends validation emails to participants
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: 
  - python 
  - get_submission_attributes.py

inputs:

  - id: submissionid
    type: int
    inputBinding:
      prefix: -s

  - id: synapse_config
    type: File
    inputBinding:
      prefix: -c


requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: get_submission_attributes.py
        entry: |
          #!/usr/bin/env python
          import synapseclient
          import argparse
          import json
          import os
          parser = argparse.ArgumentParser()
          parser.add_argument("-s", "--submissionid", required=True, help="Submission ID")
          parser.add_argument("-c", "--synapse_config", required=True, help="credentials file")

          args = parser.parse_args()
          syn = synapseclient.Synapse(configPath=args.synapse_config)
          syn.login()

          sub = syn.getSubmission(args.submissionid, downloadFile = False)
 
          result = {'userid':sub.userId,
                    'submission_name': sub.name,
                    'evaluationid': sub.evaluationId
          }
          with open("results.json", 'w') as o:
            o.write(json.dumps(result))
     
outputs:

  - id: userid
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['userid'])

  - id: submission_name
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['submission_name'])

  - id: evaluationid
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['evaluationid'])

