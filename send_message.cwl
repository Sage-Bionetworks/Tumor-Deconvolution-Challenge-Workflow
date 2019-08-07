#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

baseCommand: 
- python
- /usr/local/bin/send_message.py

hints:
- class:  DockerRequirement
  dockerPull: quay.io/andrewelamb/tumor_deconvolution_challenge_python:1.0

inputs:

- id: synapse_config
  type: File
  inputBinding:
    prefix: -c

- id: userid
  type: string
  inputBinding:
    prefix: -u

- id: subject
  type: string
  inputBinding:
    prefix: -s

- id: body
  type: string
  inputBinding:
    prefix: -b
          
outputs: []

$namespaces:
  s: https://schema.org/

s:author:
  - class: s:Person
    s:identifier: https://orcid.org/0000-0002-0326-7494
    s:email: andrew.lamb@sagebase.org

s:name: Andrew Lamb

