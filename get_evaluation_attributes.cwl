#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: 
- python 
- /usr/local/bin/get_evaluation_attributes.py

hints:
- class:  DockerRequirement
  dockerPull: quay.io/andrewelamb/tumor_deconvolution_challenge_python:1.0

requirements:
- class: InlineJavascriptRequirement

inputs:

  - id: evaluationid
    type: string
    inputBinding:
      prefix: -e

  - id: synapse_config
    type: File
    inputBinding:
      prefix: -c

outputs:

  - id: content_source
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['content_source'])

  - id: created_on
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['created_on'])

  - id: description
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['description'])

  - id: etag
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['etag'])

  - id: id
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['id'])

  - id: name
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['name'])

  - id: ownerid
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['ownerid'])

  - id: status
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['status'])

  - id: submission_instructions_message
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['submission_instructions_message'])


  - id: submission_receipt_message
    type: string
    outputBinding:
      glob: results.json
      loadContents: true
      outputEval: $(JSON.parse(self[0].contents)['submission_receipt_message'])

$namespaces:
  s: https://schema.org/

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0002-0326-7494
    s:email: andrew.lamb@sagebase.org

s:name: Andrew Lamb

