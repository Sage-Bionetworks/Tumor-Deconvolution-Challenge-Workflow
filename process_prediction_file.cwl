#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
baseCommand: 
- Rscript
- /usr/local/bin/process_submission_cl.R

requirements:
- class: InlineJavascriptRequirement

hints:
- class:  DockerRequirement
  dockerPull: quay.io/andrewelamb/tumor_deconvolution_challenge:1.0

inputs:

- id: submission_file
  type: File
  inputBinding:
    prefix: --submission_file
  
- id: validation_file
  type: File
  inputBinding:
    prefix: --validation_file

- id: score_submission
  type: boolean
  default: false
  inputBinding:
    prefix: --score_submission

outputs:

- id: annotation_json
  type: File
  outputBinding:
    glob: "annotation.json"

- id: status
  type: string
  outputBinding:
    glob: results.json
    loadContents: true
    outputEval: $(JSON.parse(self[0].contents)['status'])

- id: invalid_reason_string
  type: string
  outputBinding:
    glob: results.json
    loadContents: true
    outputEval: $(JSON.parse(self[0].contents)['invalid_reason_string'])

- id: annotation_string
  type: string
  outputBinding:
    glob: results.json
    loadContents: true
    outputEval: $(JSON.parse(self[0].contents)['annotation_string'])



