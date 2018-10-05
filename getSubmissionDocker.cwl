#!/usr/bin/env cwl-runner
#
# Extract the submitted Docker repository and Docker digest
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: python

inputs:
  - id: submissionId
    type: int
  - id: synapseConfig
    type: File

arguments:
  - valueFrom: getSubmissionDocker.py
  - valueFrom: $(inputs.submissionId)
    prefix: -s
  - valueFrom: results.json
    prefix: -r
  - valueFrom: $(inputs.synapseConfig.path)
    prefix: -c

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: getSubmissionDocker.py
        entry: |
          #!/usr/bin/env python
          import synapseclient
          import argparse
          import json
          import os
          parser = argparse.ArgumentParser()
          parser.add_argument("-s", "--submissionId", required=True, help="Submission ID")
          parser.add_argument("-r", "--results", required=True, help="download results info")
          parser.add_argument("-c", "--synapseConfig", required=True, help="credentials file")
          args = parser.parse_args()
          syn = synapseclient.Synapse(configPath=args.synapseConfig)
          syn.login()
          sub = syn.getSubmission(args.submissionId, downloadLocation=".")
          if sub.entity.entityType!='org.sagebionetworks.repo.model.docker.DockerRepository':
            raise Exception('Expected DockerRepository type but found '+sub.entity.entityType)
          result = {'dockerRepository':sub.get("dockerRepositoryName",""),'dockerDigest':sub.get("dockerDigest",""),'entityId':sub.entity.id}
          with open(args.results, 'w') as o:
            o.write(json.dumps(result))
     
outputs:
  - id: dockerRepository
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['dockerRepository'])
  - id: dockerDigest
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['dockerDigest'])
  - id: entityId
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['entityId'])
