#!/usr/bin/env cwl-runner
#
# upload a file to Synapse and return the ID
# param's include the parentId (project or folder) to which the file is to be uploaded
# and the provenance information for the file
#
cwlVersion: v1.0
class: CommandLineTool
baseCommand: python

inputs:
  - id: infile
    type: File
  - id: parentId
    type: string
  - id: usedEntity
    type: string
  - id: executedEntity
    type: string
  - id: synapseConfig
    type: File

arguments:
  - valueFrom: uploadFile.py
  - valueFrom: $(inputs.infile)
    prefix: -f
  - valueFrom: $(inputs.parentId)
    prefix: -p
  - valueFrom: $(inputs.usedEntity)
    prefix: -ui
  - valueFrom: $(inputs.executedEntity)
    prefix: -e
  - valueFrom: results.json
    prefix: -r
  - valueFrom: $(inputs.synapseConfig.path)
    prefix: -c

requirements:
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - entryname: uploadFile.py
        entry: |
          #!/usr/bin/env python
          import synapseclient
          import argparse
          import json
          if __name__ == '__main__':
            parser = argparse.ArgumentParser()
            parser.add_argument("-f", "--infile", required=True, help="file to upload")
            parser.add_argument("-p", "--parentId", required=True, help="Synapse parent for file")
            parser.add_argument("-ui", "--usedEntityId", required=False, help="id of entity 'used' as input")
            parser.add_argument("-uv", "--usedEntityVersion", required=False, help="version of entity 'used' as input")
            parser.add_argument("-e", "--executedEntity", required=False, help="Syn ID of workflow which was executed")
            parser.add_argument("-r", "--results", required=True, help="Results of file upload")
            parser.add_argument("-c", "--synapseConfig", required=True, help="credentials file")
            args = parser.parse_args()
            syn = synapseclient.Synapse(configPath=args.synapseConfig)
            syn.login()
            file=synapseclient.File(path=args.infile, parent=args.parentId)
            file = syn.store(file, used={'reference':{'targetId':args.usedEntityId, 'targetVersionNumber':args.usedEntityVersion}}, executed=args.executedEntity)
            results = {'predictionFileId':file.id,'predictionFileVersion':file.versionNumber}
            with open(args.results, 'w') as o:
              o.write(json.dumps(results))
     
outputs:
  - id: uploadedFileId
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['predictionFileId'])
  
  - id: uploadedFileVersion
    type: int
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['predictionFileVersion'])
  
  - id: results
    type: File
    outputBinding:
      glob: results.json   
