#!/usr/bin/env cwl-runner
#
# Example validate submission file
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: python

inputs:
  - id: inputfile
    type: File

arguments:
  - valueFrom: validate.py
  - valueFrom: $(inputs.inputfile)
    prefix: -s
  - valueFrom: results.json
    prefix: -r

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: validate.py
        entry: |
          #!/usr/bin/env python
          import synapseclient
          import argparse
          import os
          import json
          parser = argparse.ArgumentParser()
          parser.add_argument("-s", "--submissionFile", required=True, help="Submission File")
          parser.add_argument("-r", "--results", required=True, help="validation results")

          args = parser.parse_args()
          with open(args.submissionFile,"r") as subFile:
            message = subFile.read()
          invalidReasons = []
          status = "VALIDATED"
          if not message.startswith("test"):
            invalidReasons.append("Submission must have test column")
            status = "INVALID"
          result = {'invalidReasons':"\n".join(invalidReasons),'status':status}
          with open(args.results, 'w') as o:
            o.write(json.dumps(result))
     
outputs:

  - id: results
    type: File
    outputBinding:
      glob: results.json   

  - id: status
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['status'])

  - id: invalidReasons
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['invalidReasons'])
