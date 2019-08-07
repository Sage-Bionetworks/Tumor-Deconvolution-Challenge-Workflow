#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: 
- python 
- /usr/local/bin/get_submission_attributes.py

hints:
- class:  DockerRequirement
  dockerPull: quay.io/andrewelamb/tumor_deconvolution_challenge_python:1.0

requirements:
- class: InlineJavascriptRequirement

inputs:

  - id: submissionid
    type: int
    inputBinding:
      prefix: -s

  - id: synapse_config
    type: File
    inputBinding:
      prefix: -c

outputs:

  - id: userid
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['userid'])

  - id: name
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['name'])

  - id: evaluationid
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['evaluationid'])

$namespaces:
  s: https://schema.org/

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0002-0326-7494
    s:email: andrew.lamb@sagebase.org

s:name: Andrew Lamb

