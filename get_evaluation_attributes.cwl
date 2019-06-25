#!/usr/bin/env cwl-runner
#
# Example sends validation emails to participants
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: 
  - python 
  - get_evaluation_attributes.py

inputs:

  - id: evaluationid
    type: string
    inputBinding:
      prefix: -e

  - id: synapse_config
    type: File
    inputBinding:
      prefix: -c


requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: get_evaluation_attributes.py
        entry: |
          #!/usr/bin/env python
          import synapseclient
          import argparse
          import json
          import os
          parser = argparse.ArgumentParser()
          parser.add_argument("-e", "--evaluationid", required=True, help="evaluationid")
          parser.add_argument("-c", "--synapse_config", required=True, help="credentials file")

          args = parser.parse_args()
          syn = synapseclient.Synapse(configPath=args.synapse_config)
          syn.login()

          eval = syn.getEvaluation(args.evaluationid)

          result = {'evaluation_name': eval.name}

          with open("results.json", 'w') as o:
            o.write(json.dumps(result))
     
outputs:

  - id: evaluation_name
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['evaluation_name'])

